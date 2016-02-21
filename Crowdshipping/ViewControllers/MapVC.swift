//
//  ViewController.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 13/02/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit
import MapKit
import QuartzCore

class MapVC: ConnectionAwareVC, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource,
    GMSMapViewDelegate, GMSIndoorDisplayDelegate, UIAlertViewDelegate
{

    // TODO: move to separate file
    enum MapType: String {
        case Pickup = "Pickup", Destination = "Destination"
    }

    @IBOutlet weak var guaranteedLabel : UILabel?
    @IBOutlet weak var guaranteedLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var footerHeight: NSLayoutConstraint!
    
    @IBOutlet var menuButton : MenuButton?
    
    @IBOutlet weak var autocompleteTableview : UITableView?
    //@IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var mapAnchorView: UIView!
    @IBOutlet weak var mapTargetPin: UIImageView!
    
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var detailsTextField: UITextField!

    @IBOutlet weak var nextButton: UIButton!
    
    var googleMapView: GMSMapView?
    
    var mapType: MapType = .Pickup
    var isInTransitionBetweenMapTypes = false
    
    var tempCurrentOrder: OrderModel?
    
    // MapKit
    weak var fromAnnotation: MKPointAnnotation?
    weak var toAnnotation: MKPointAnnotation?
    
    // Google maps
    weak var fromMarker: GMSMarker?
    weak var toMarker: GMSMarker?
   
    var previousLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(Config.autoSuggestLatitude as CLLocationDegrees, Config.autoSuggestLongitude as CLLocationDegrees)
    
    var alreadyShownUserLocation : Bool = false
    
    var fromCoordinate: CLLocationCoordinate2D? = nil
    var toCoordinate: CLLocationCoordinate2D? = nil
    
    var autocompleteSuggestions = [AnyObject]()
    var setFromMapTimer: NSTimer?
    
    // Courier stuff
    var couriers = Array<CourierTrackModel>()
    var courierPins = Array<GMSMarker>()
    var courierTimer: NSTimer?
    
    var shouldResetMap = false
    
    var shouldShowSplashScreen = true
    
    var poligon: MKPolygon?
    var googlePolygon: GMSMutablePath = GMSMutablePath()
    
    deinit {
        if googleMapView != nil {
            googleMapView?.removeObserver(self, forKeyPath: "myLocation")
        }

        if courierTimer != nil {
            courierTimer?.invalidate()
            courierTimer = nil
        }

        if setFromMapTimer != nil {
            setFromMapTimer?.invalidate()
            setFromMapTimer = nil
        }
        
        NotificationManager.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.addBackgroundRecognizer()
        
        self.resetMenuButton()
        autocompleteTableview!.registerNib(UINib(nibName: "GenericTVC", bundle: nil), forCellReuseIdentifier: "generic cell")
        
        
        let keyboardToolbar = KeyboardToolbar(parentView: self.view)
        
        addressTextField.inputAccessoryView = keyboardToolbar
        detailsTextField.inputAccessoryView = keyboardToolbar
        
        addressTextField.delegate = self
        addressTextField.returnKeyType = .Next
        
        detailsTextField.delegate = self
        detailsTextField.returnKeyType = .Done
        
        self.guaranteedLabelHeight.constant = 0.0//45.0
        self.footerHeight.constant = 108.0//153.0
        
        self.addressTextField.placeholder = "Pick-up address"
        
        self.view.layoutIfNeeded()
        
        let path = NSBundle.mainBundle().pathForResource("GEO", ofType: "json")
        let jsonData = NSData(contentsOfFile: path!)
        var coordinates: [AnyObject]!
        do {
            if let jsonResult = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers) as? [String : AnyObject] {
                coordinates = jsonResult["coordinates"] as! [AnyObject]
            }
        } catch {
            print(error)
        }

        coordinates = coordinates[0] as? [AnyObject]
        
        var points: Array<CLLocationCoordinate2D> = []
        for locationArray in coordinates
        {
            if let locationCoordinates: [CLLocationDegrees] = locationArray as? [CLLocationDegrees]
            {
                let latitude = locationCoordinates[1] as CLLocationDegrees
                let longitude = locationCoordinates[0] as CLLocationDegrees
                var location = CLLocationCoordinate2DMake(latitude, longitude)
                
                googlePolygon.addCoordinate(location)
                points.append(location)
            }
        }

        
        poligon = MKPolygon(coordinates: &points, count: points.count)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        indicatorView.layer.cornerRadius = indicatorView.frame.size.width/2
        indicatorView.layer.masksToBounds = true
        indicatorView.backgroundColor = (self.mapType == .Pickup) ? Config.Visuals.color_blue : Config.Visuals.color_green
        
        // Google map
        if googleMapView == nil {
            let camera = GMSCameraPosition.cameraWithLatitude(previousLocation.latitude,
                longitude:previousLocation.longitude,
                zoom:Config.defaultGoogleMapsZoom)

            
            googleMapView = GMSMapView.mapWithFrame(mapAnchorView.bounds, camera:camera)
            
            if googleMapView != nil {
                googleMapView!.delegate = self
                
                mapAnchorView.insertSubview(googleMapView!, belowSubview: mapTargetPin)
                
                googleMapView!.translatesAutoresizingMaskIntoConstraints = false
                let views = ["googleMapView": googleMapView!]
                mapAnchorView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[googleMapView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
                mapAnchorView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[googleMapView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
                //self.view.insertSubview(googleMapView!, belowSubview: mapAnchorView)
                
                /*
                let colorOverlay = UIView(frame: self.view.bounds)
                colorOverlay.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.1)
                colorOverlay.userInteractionEnabled = false
                self.view.insertSubview(colorOverlay, belowSubview: mapAnchorView)
                */
                
                let myContext = UnsafeMutablePointer<()>()
                googleMapView?.addObserver(self, forKeyPath: "myLocation", options:NSKeyValueObservingOptions.New, context:myContext)
                
                googleMapView?.myLocationEnabled = true
                googleMapView?.settings.myLocationButton = true
                
                // "Crosshair"
                /*
                let cross = UIView(frame: CGRectMake(0, 0, 3, 3))
                cross.backgroundColor = UIColor.redColor()
                cross.alpha = 0.5
                cross.center = googleMapView!.center
                googleMapView?.superview?.addSubview(cross)
                */
                
                
                googleMapView!.indoorDisplay.delegate = self
            }
        }
        
        fetchCourierInfo()
        
        NotificationManager.addObserver(self, selector: Selector("userDidLogout"), name: .UserDidLogout)
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if AuthManager.sharedInstance.isLoggedIn() {
            // Check if order is present        
            
            if OrderManager.sharedInstance.currentOrder.pk != nil
            {
                self.tempCurrentOrder = OrderManager.sharedInstance.currentOrder
                self.performSegueWithIdentifier("current order", sender: self)
                delegate.hideSplasScreen(0.5)
            }
            else
            {
                APIManager.sharedInstance.getActiveOrderDetails({ (arg) -> Void in
                    if let newOrder = Mapper<OrderModel>().map(arg) {
                        self.tempCurrentOrder = newOrder
                        OrderManager.sharedInstance.currentOrder = self.tempCurrentOrder!
                        self.performSegueWithIdentifier("current order", sender: self)
                        delegate.hideSplasScreen(0.5)
                    }
                    }, failedCallback: { (arg) -> Void in
                        // Fail silently
                        delegate.hideSplasScreen(0.0)
                })
            }
            
        }
        else
        {
            delegate.hideSplasScreen(0.0)
        }
        
    }
    
//    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
//        if (buttonIndex == 0){
//            OrderManager.sharedInstance.currentOrder = self.tempCurrentOrder!
//            self.performSegueWithIdentifier("current order", sender: self)
//        }
//    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        courierTimer?.invalidate()
        courierTimer = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.shouldResetMap
        {
            // Shit shit shit
            self.userDidLogout()
            self.backTap()
            
            self.setPickupLocationFromMap()
            
            self.shouldResetMap = false
        }
        
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "current order":
            (segue.destinationViewController as! CurrentOrderVC).order = OrderManager.sharedInstance.currentOrder
        default:
            break
        }
    }
    
    // MARK: Notifications

    func userDidLogout() {
        if fromMarker != nil {
            fromMarker!.map = nil
            fromMarker = nil
        }

        if toMarker != nil {
            toMarker!.map = nil
            toMarker = nil
        }
        
        addressTextField.text = nil
        detailsTextField.text = nil

        self.mapType = .Pickup
        self.title = "PICK-UP ADDRESS"
        
        self.resetMenuButton()
        closeTap()
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: KVO
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            alreadyShownUserLocation = true
            
            if Config.isDevBuild
            {
                var gpolygon = GMSPolygon(path: googlePolygon)
                gpolygon.fillColor = UIColor(red:0.25, green:0, blue:0, alpha:0.05);
                gpolygon.strokeColor = UIColor.yellowColor()
                gpolygon.strokeWidth = 3
                gpolygon.map = googleMapView
            }
        #endif
        
        
        if alreadyShownUserLocation {
            return
        }
        
        // TODO: check context
        let dict = change! as NSDictionary
        let location: AnyObject? = dict.objectForKey(NSKeyValueChangeNewKey)
        if let loc = location as? CLLocation {
            googleMapView?.camera = GMSCameraPosition.cameraWithLatitude(loc.coordinate.latitude, longitude: loc.coordinate.longitude, zoom: 14)
            
            alreadyShownUserLocation = true
        }
    }
    
    // MARK: other
    
    func setLocation(location: CLLocationCoordinate2D, description: String?) {
        addressTextField!.text = description
        
        // Google maps version
        self.googleMapView!.animateToLocation(location);
        
        self.setMarkerForLocation(self.mapType == .Pickup, location: location, description: description)
        
        self.closeTap()
        
        // MapKit version
        /*
        var span = MKCoordinateSpanMake(0.5, 0.5)
        var region = MKCoordinateRegion(center: location, span: span)
        
        self.mapView.setRegion(region, animated: true)
        
        var annotation = MKPointAnnotation()
        annotation.setCoordinate(location)
        annotation.title = "Point"
        annotation.subtitle = description
        
        self.mapView.addAnnotation(annotation)
        
        if self.activeTextField! == self.addressTextField {
        if self.fromAnnotation != nil {
        self.mapView.removeAnnotation(self.fromAnnotation)
        }
        
        self.fromAnnotation = annotation
        } else if self.activeTextField! == self.toTextField {
        if self.toAnnotation != nil {
        self.mapView.removeAnnotation(self.toAnnotation)
        }
        
        self.toAnnotation = annotation
        }
        */
    }
    
    func setMarkerForLocation(isPickup: Bool, location: CLLocationCoordinate2D, description: String?) {
        self.googleMapView!.animateToLocation(location);
        
        // Google maps version
        let marker = GMSMarker(position: location)
        marker.snippet = description;
        //marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.map = self.googleMapView;
        marker.groundAnchor = CGPoint(x: 0.5, y: 1)
        marker.opacity = 0
        
        if isPickup {
            marker.icon = UIImage(named: "PinFrom")
            if self.fromMarker != nil {
                self.fromMarker!.map = nil
            }
            
            self.fromMarker = marker
            self.fromCoordinate = location
        } else {
            marker.icon = UIImage(named: "PinTo")
            if self.toMarker != nil {
                self.toMarker!.map = nil
            }
            
            self.toMarker = marker
            self.toCoordinate = location
        }
    }
    
    func resetMenuButton() {
        let menuButton = MenuButton(frame: CGRectMake(0, 0, 60, 30))
        menuButton.delegate = self
        menuButton.presentingViewController = self.navigationController
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
    }
    
    func updateCouriers(newCouriers: [CourierTrackModel]) {
        for courier in couriers {
            if let updatedCourier = newCouriers.filter({courier.id == $0.id}).first {
                // Courier is present in updated array
                let position = updatedCourier.tail![0].coordinate!
                updatedCourier.pin = courier.pin!
                //updatedCourier.pin!.layer.removeAllAnimations()
                
                CATransaction.begin()
                CATransaction.setAnimationDuration(Config.animationDurationCourier)
                updatedCourier.pin!.position = position
                
                CATransaction.commit()

            } else {
                // Courier is NOT present in updated array - remove pin
                let pin = courier.pin
                pin!.map = nil
            }
        }
        
        for courier in newCouriers {
            // New couriers
            if courier.pin == nil {
                let tail = courier.tail!
                
                if tail.count != 0 {
                    var position = courier.tail![0].coordinate!
                    
                    if tail.count >= 2 {
                        position = courier.tail![1].coordinate!
                    }
                    
                    let pin = GMSMarker(position: position)
                    pin!.map = self.googleMapView;
                    pin!.icon = UIImage(named: "PinCourier")
                    courier.pin = pin
                    
                    if tail.count >= 2 {
                        let duration = tail[0].timestamp!.timeIntervalSinceDate(tail[1].timestamp!)
                        
                        CATransaction.begin()
                        CATransaction.setAnimationDuration(duration)
                        pin!.position = courier.tail![0].coordinate!
                        
                        CATransaction.commit()
                    }
                }
            }
        }
        
        
        couriers = newCouriers
    }
    
    func fetchCourierInfo() {
        courierTimer?.invalidate()
        courierTimer = NSTimer.scheduledTimerWithTimeInterval(Config.animationDurationCourier, target: self, selector: Selector("fetchCourierInfo"), userInfo: nil, repeats: true)
        
        let visibleRegion = googleMapView!.projection.visibleRegion();
        let bounds = GMSCoordinateBounds(region: visibleRegion)
        
        let northEast = bounds.northEast
        let southWest = bounds.southWest
        
        APIManager.sharedInstance.getNearbyCouriers(northEast, southwest: southWest, successCallback:{ (arg) in
            //Utils.log(arg)
            self.courierTimer?.invalidate()
            self.courierTimer = NSTimer.scheduledTimerWithTimeInterval(Config.animationDurationCourier, target: self, selector: Selector("fetchCourierInfo"), userInfo: nil, repeats: true)
            
            self.updateCouriers(arg)
            }, failedCallback: { (arg) in
                Utils.showErrorForJSON(arg)
            }
        )
    }
    
    func setPickupLocationFromMap() {
        setFromMapTimer?.invalidate()
        setFromMapTimer = nil
        
        
        var location = googleMapView!.camera.target
        if Config.isDevBuild
        {
            previousLocation = location
        }
        else
        {
            if GMSGeometryContainsLocation(location, googlePolygon, true)
            {
                previousLocation = location
            }
            else
            {
                let camera = GMSCameraPosition.cameraWithLatitude(previousLocation.latitude, longitude: previousLocation.longitude, zoom: googleMapView!.camera.zoom)
                googleMapView?.animateToCameraPosition(camera)
                
                return
            }
        }
    
        setAddressWithLocation(location)
        
    }
    
    func setAddressWithLocation(location: CLLocationCoordinate2D)
    {
        setMarkerForLocation(self.mapType == .Pickup, location: location, description: nil)
        
        APIManager.sharedInstance.getLocationAddress(location,
            successCallback: { (address) -> Void in
                self.addressTextField.text = address
                self.nextButton.backgroundColor = Config.Visuals.color_blueButton
                self.nextButton.enabled = true
            }, failedCallback: { () -> Void in
                
        })
    }
    
    func animateTransition() {
        let nc = self.navigationController!
        
        UIView.transitionWithView(nc.view.superview!,
            duration: 0.5,
            options: .TransitionFlipFromRight,
            animations: { () -> Void in
                
            },
            completion: { (finished) -> Void in
                let frame = nc.view.frame
                nc.view.frame = CGRectZero
                nc.view.frame = frame
                
                self.isInTransitionBetweenMapTypes = false
        })
    }
    
    // MARK: UI callbacks

    @IBAction func deliverTap() {
        switch mapType {
        case .Pickup:
            
            self.addressTextField.placeholder = "Destination address"
            
            if (fromCoordinate == nil) {
                let av = UIAlertView(title: "Error", message: "Please select pickup address", delegate: nil, cancelButtonTitle: "OK")
                av.show()
                return
            }
            
            isInTransitionBetweenMapTypes = true
            
            // Save data
            
            OrderManager.sharedInstance.currentOrder.pickupAddress          = self.addressTextField.text
            OrderManager.sharedInstance.currentOrder.pickupAddressDetail    = self.detailsTextField.text
            OrderManager.sharedInstance.currentOrder.pickupPosition         = fromCoordinate
            

            // Change presentation
            var shouldAnimateTransition = true
            
            indicatorView.backgroundColor = Config.Visuals.color_green
            mapTargetPin.image = UIImage(named: "PinTo")
            fromMarker?.opacity = 1
            if let toMarker = toMarker {
                toMarker.opacity = 0
                
                let zoom = googleMapView!.camera.zoom
                let camera = GMSCameraPosition.cameraWithLatitude(toMarker.position.latitude, longitude: toMarker.position.longitude, zoom: zoom)
                googleMapView?.animateToCameraPosition(camera)
                
                shouldAnimateTransition = false
                
                nextButton.backgroundColor = Config.Visuals.color_blueButton
                self.nextButton.enabled = true
            } else {
                nextButton.backgroundColor = UIColor.lightGrayColor()
                self.nextButton.enabled = false
            }
            
            self.addressTextField.text = OrderManager.sharedInstance.currentOrder.destinationAddress
            self.detailsTextField.text = OrderManager.sharedInstance.currentOrder.destinationAddressDetail
            
            self.mapType = .Destination
            self.title = "DELIVERY ADDRESS"

            let backButton = UIBarButtonItem(image: UIImage(named: "BackButton"), style: .Plain, target: self, action: Selector("backTap"))
            self.navigationItem.leftBarButtonItem = backButton
            
            self.footerHeight.constant = 108.0
            self.guaranteedLabelHeight.constant = 0.0
            
            self.view.layoutIfNeeded()
            
            // Animation
            if shouldAnimateTransition {
                animateTransition()
            } else {
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.isInTransitionBetweenMapTypes = false
                }
            }
            
        case .Destination:
            
            self.addressTextField.placeholder = "Pick-up address"
            
            if (toCoordinate == nil) {
                let av = UIAlertView(title: "Error", message: "Please select destination address", delegate: nil, cancelButtonTitle: "OK")
                av.show()
                return
            }
            
            self.nextButton.enabled = false
            
            OrderManager.sharedInstance.currentOrder.destinationAddress             = self.addressTextField.text
            OrderManager.sharedInstance.currentOrder.destinationAddressDetail       = self.detailsTextField.text
            OrderManager.sharedInstance.currentOrder.destinationPosition            = toCoordinate
            
            self.showWaitOverlay()
            weak var wSelf = self
            APIManager.sharedInstance.getQuote({ (json) -> Void in
                //Utils.log(json)
                OrderManager.sharedInstance.currentOrder.pricesData = json
                
                let sSelf = wSelf
                if sSelf != nil {
                    sSelf?.nextButton.enabled = true
                    sSelf!.removeAllOverlays()
                    self.performSegueWithIdentifier("select size", sender: self)
                }
                }, failedCallback: { (json) -> Void in
                    let sSelf = wSelf
                    if sSelf != nil {
                        sSelf?.nextButton.enabled = true
                        sSelf!.removeAllOverlays()
                    }
                    
                    Utils.showErrorForJSON(json)
            })
        }
    }
    
    func backTap() {
        isInTransitionBetweenMapTypes = true
        
        self.addressTextField.placeholder = "Pick-up address"
        
        // Save data
        
        OrderManager.sharedInstance.currentOrder.destinationAddress         = self.addressTextField.text
        OrderManager.sharedInstance.currentOrder.destinationAddressDetail   = self.detailsTextField.text
        
        // Change presentation
        
        indicatorView.backgroundColor = Config.Visuals.color_blue
        mapTargetPin.image = UIImage(named: "PinFrom")
        if let fromMarker = fromMarker {
            fromMarker.opacity = 0
            
            let zoom = googleMapView!.camera.zoom
            let camera = GMSCameraPosition.cameraWithLatitude(fromMarker.position.latitude, longitude: fromMarker.position.longitude, zoom: zoom)
            googleMapView?.animateToCameraPosition(camera)
         
            nextButton.backgroundColor = Config.Visuals.color_blueButton
            self.nextButton.enabled = true
        } else {
            nextButton.backgroundColor = UIColor.lightGrayColor()
            self.nextButton.enabled = false
        }
        
        toMarker?.opacity = 1
        
        self.addressTextField.text = OrderManager.sharedInstance.currentOrder.pickupAddress
        self.detailsTextField.text = OrderManager.sharedInstance.currentOrder.pickupAddressDetail
        
        self.mapType = .Pickup
        self.title = "PICK-UP ADDRESS"
        
        self.guaranteedLabelHeight.constant = 0.0//45.0
        self.footerHeight.constant = 108.0//153.0
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
        self.resetMenuButton()
        closeTap()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.isInTransitionBetweenMapTypes = false
        }
    }
    
    @IBAction func closeTap() {
        UIView.animateWithDuration(Config.animationDurationDefault,
            animations: { () -> Void in
            self.view.endEditing(true)
            self.autocompleteTableview!.alpha = 0
        }) { (finished) -> Void in
            self.autocompleteTableview!.hidden = true
        }
    }
    
    // MARK: GMSMapViewDelegate
    
    func mapView(mapView: GMSMapView, willMove: Bool) {
        self.view.endEditing(true)
        
        setFromMapTimer?.invalidate()
        setFromMapTimer = nil
    }
    
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition ) {
        if isInTransitionBetweenMapTypes {
            return
        }
        
        fetchCourierInfo()
        
        setFromMapTimer?.invalidate()
        setFromMapTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("setPickupLocationFromMap"), userInfo: nil, repeats: false)
    }
    
    // MARK: GMSIndoorDisplayDelegate
    
    func didChangeActiveLevel(level: GMSIndoorLevel?) {
        self.view.endEditing(true)
        
        if let name = level?.shortName {
            detailsTextField.text = "Level/floor: " + name
        }
    }

    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        if textField.isEqual(self.addressTextField) {
            detailsTextField.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == addressTextField {
            let lastAddressed = AddressesManager.sharedInstance.getLastAddressesForType(self.mapType)
            
            if lastAddressed.count > 0 {
                self.autocompleteSuggestions = lastAddressed
                self.autocompleteTableview?.reloadData()
                
                if autocompleteTableview!.hidden {
                    autocompleteTableview!.alpha = 0
                    autocompleteTableview!.hidden = false
                    
                    UIView.animateWithDuration(Config.animationDurationDefault, animations: { () -> Void in
                        self.autocompleteTableview!.alpha = 1
                    })
                }
            }
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        
        if mapType == .Pickup {
            if self.fromMarker != nil {
                self.fromMarker!.map = nil
            }
            
            self.fromCoordinate = nil
            
            nextButton.backgroundColor = UIColor.lightGrayColor()
            self.nextButton.enabled = false
        } else {
            if self.toMarker != nil {
                self.toMarker!.map = nil
            }
            
            self.toCoordinate = nil
            
            nextButton.backgroundColor = UIColor.lightGrayColor()
            self.nextButton.enabled = false
        }
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == addressTextField {
            let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            
            if newString.characters.count > 2 {
                if autocompleteTableview!.hidden {
                    autocompleteTableview!.alpha = 0
                    autocompleteTableview!.hidden = false
                    
                    UIView.animateWithDuration(Config.animationDurationDefault, animations: { () -> Void in
                        self.autocompleteTableview!.alpha = 1
                    })
                }
                
                self.showWaitOverlay()
                APIManager.sharedInstance.getPlaceAutosuggestions(newString,
                    successCallback: ({ (array) -> Void in
                        self.removeAllOverlays()
                        
                        self.autocompleteSuggestions = array
                        self.autocompleteTableview?.reloadData()
                    }), failedCallback: ({ (json) in
                        self.removeAllOverlays()
                        
                        Utils.showErrorForJSON(json)
                    }))
            }
        }
        
        return true
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteSuggestions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "generic cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? GenericTVC

        cell!.genericLabel.text = ""
        cell!.backgroundColor = UIColor.whiteColor()
        
        let autocompleteItem: (AnyObject) = autocompleteSuggestions[indexPath.row]

        if autocompleteItem is Dictionary<String, AnyObject> {
            if let desc = autocompleteItem["address"] as? String {
                cell!.genericLabel.text = desc
            }
            
            if !(autocompleteItem["google_place_id"] is String) {
                //cell!.backgroundColor = UIColor.yellowColor()
            }
        } else if autocompleteItem is LastUsedAddress {
            cell!.genericLabel.text = autocompleteItem.address
            //cell!.backgroundColor = UIColor.cyanColor()
        }
        
        return cell!
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let autocompleteItem: (AnyObject) = autocompleteSuggestions[indexPath.row]
        
        if autocompleteItem is Dictionary<String, AnyObject> {
            let description = autocompleteItem["address"] as? String
            
            if let placeID = autocompleteItem["google_place_id"] as? String {
                self.showWaitOverlay()
                APIManager.sharedInstance.getPlaceInfo(placeID, successCallback: { (placeInfo) -> Void in
                    self.removeAllOverlays()
                    
                    if let coordinatesArray = (placeInfo as AnyObject).valueForKeyPath("location.coordinates") as? Array<Double> {
                        if let location = CLLocationCoordinate2D(array: coordinatesArray) {
                            self.setLocation(location, description: description)
                            
                            self.nextButton.backgroundColor = Config.Visuals.color_blueButton
                            self.nextButton.enabled = true
                        }
                    }

                    }, failedCallback: {(json) -> Void in
                        self.removeAllOverlays()
                        
                        Utils.showErrorForJSON(json)
                })
            } else if let coordinatesArray = (autocompleteItem as AnyObject).valueForKeyPath("position.coordinates") as? Array<Double> {
                if let location = CLLocationCoordinate2D(array: coordinatesArray) {
                    self.setLocation(location, description: description)
                }
            }
        } else if let lastUsedAddress = autocompleteItem as? LastUsedAddress {
            let location = CLLocationCoordinate2D(latitude: lastUsedAddress.lat.doubleValue, longitude: lastUsedAddress.lng.doubleValue)
            self.setLocation(location, description: lastUsedAddress.address)
        }
    }
}

