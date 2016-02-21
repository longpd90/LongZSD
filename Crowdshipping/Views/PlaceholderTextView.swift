//
//  PlaceholderTextView.swift
//  Crowdshipping
//
//  Created by Ivan Kozlov on 28/05/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

import UIKit

class PlaceholderTextView : UITextView {
    
    var placeholderColor : UIColor = UIColor(white: 0.7, alpha: 1.0)
    var placeholderText : NSString? = nil
    
    override var font : UIFont? {
        willSet(font) {
            super.font = font
        }
        didSet(font) {
            setNeedsDisplay()
        }
    }
    
    override var contentInset : UIEdgeInsets {
        willSet(text) {
            super.contentInset = contentInset
        }
        didSet(text) {
            setNeedsDisplay()
        }
    }
    
    override var textAlignment : NSTextAlignment {
        willSet(textAlignment) {
            super.textAlignment = textAlignment
        }
        didSet(textAlignment) {
            setNeedsDisplay()
        }
    }
    
    override var text : String? {
        willSet(text) {
            super.text = text
        }
        didSet(text) {
            setNeedsDisplay()
        }
    }
    
    override var attributedText : NSAttributedString? {
        willSet(attributedText) {
            super.attributedText = attributedText
        }
        didSet(text) {
            setNeedsDisplay()
        }
    }
    
    convenience init() {
        self.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:",
            name: UITextViewTextDidChangeNotification, object: self)
        setNeedsDisplay()
    }
    
    override init(frame frameRect: CGRect, textContainer aTextContainer: NSTextContainer!) {
        super.init(frame: frameRect, textContainer: aTextContainer)
    }
    
    convenience init(placeholderText: NSString) {
        self.init()
        self.placeholderText = placeholderText
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    convenience required init(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
    }
    
    convenience init(frame: CGRect) {
        self.init(frame: frame)
    }
    
    func textChanged(notification: NSNotification) {
        setNeedsDisplay()
    }
    
    func placeholderRectForBounds(bounds : CGRect) -> CGRect {
        var x = contentInset.left + 4.0
        var y = contentInset.top  + 9.0
        var w = frame.size.width - contentInset.left - contentInset.right - 16.0
        var h = frame.size.height - contentInset.top - contentInset.bottom - 16.0
        
        if let style = self.typingAttributes[NSParagraphStyleAttributeName] as? NSParagraphStyle {
            x += style.headIndent
            y += style.firstLineHeadIndent
        }
        return CGRectMake(x, y, w, h)
    }
    
    override func drawRect(rect: CGRect) {
        if (text! == "" && placeholderText != nil) {
            var paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            var attributes: [ String: AnyObject ] = [
                NSFontAttributeName : UIFont.italicSystemFontOfSize(font!.pointSize),
                NSForegroundColorAttributeName : placeholderColor,
                NSParagraphStyleAttributeName  : paragraphStyle]
            
            placeholderText!.drawInRect(placeholderRectForBounds(bounds), withAttributes: attributes)
        }
        super.drawRect(rect)
    }
}