//
//  UITextView+InsertEmoticon.swift
//  01- 表情键盘
//
//  Created by 王俨 on 15/8/6.
//  Copyright © 2015年 王俨. All rights reserved.
//

import UIKit

extension UITextView {
    
    /// 插入表情符号
    ///
    /// - parameter emoticon: 表情
    func insertEmoticon(emoticon: Emoticon) {
        if let imageStr = emoticon.imageStr {
            replaceRange(selectedTextRange!, withText: imageStr)
            return
        }
        // png图片的处理
        guard let image = emoticon.image else {
            return
        }
        let attachment = WYTextAttachment()
        attachment.image = image
        attachment.chs = emoticon.chs
        
        // 1.对输入图片的高度做处理,保持和字体大小一样
        let h = font!.lineHeight
        attachment.bounds = CGRect(x: 0, y: -4, width: h, height: h)
        // 2.获取可变输入文本,并且设置属性
        let strM = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        strM.addAttribute(NSFontAttributeName, value: font!, range: NSRange(location: 0, length: 1))
        
        // 3.获取文本框中可变文本属性
        let textM = NSMutableAttributedString(attributedString: attributedText)
        let lastRange = selectedRange
        let range = NSRange(location: lastRange.location + 1, length: 0)
        textM.replaceCharactersInRange(lastRange, withAttributedString: strM)
        attributedText = textM
        selectedRange = range
    }
    
    /// textView的attributedText的属性的字符串
    var attrStr: String {
        // 1.获取textView的属性文本
        let textAttr = attributedText
        var strM = ""
        // 2.因为textView的属性文本是分段存储的,所以遍历该文本
        textAttr.enumerateAttributesInRange(NSRange(location: 0, length: textAttr.length), options: NSAttributedStringEnumerationOptions(rawValue: 0)) { (dict, range, _) -> Void in
            
            // 1.如果是图片,字典中会有NSAttachment这个键值对
            if let attachment = dict["NSAttachment"] as? WYTextAttachment {
                strM += attachment.chs!
            } else {    //使用range获取字符串(包括emoji也算是字符串)
                let str = (textAttr.string as NSString).substringWithRange(range)
                strM += str
            }
        }
        return strM
    }
}










