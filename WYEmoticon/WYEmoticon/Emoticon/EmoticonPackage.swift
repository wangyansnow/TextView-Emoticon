//
//  EmoticonPackage.swift
//  01- 表情键盘
//
//  Created by 王俨 on 15/8/6.
//  Copyright © 2015年 王俨. All rights reserved.
//

import UIKit

class EmoticonPackage: NSObject {

    /// 目录名
    var id: String
    /// 包名称
    var group_name_cn: String = ""
    /// 表情数组
    var emoticons: [Emoticon]?
    /// 包名称的集合
    class var groupNames: [String]? {
        var groups = [String]()
        for em in EmoticonPackage.loadEmoticonPackages() {
            groups.append(em.group_name_cn)
        }
        return groups
    }
    init(id: String, groupName: String = "") {
        self.id = id
        self.group_name_cn = groupName
        super.init()
    }
    /// bundlePath文件主路径
    private class var bundlePath: String {
        let path = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("Emoticons.bundle")
        return path
    }
    
    /// 加载表情包数组
    class func loadEmoticonPackages() -> [EmoticonPackage] {
        // 1.获取文件路径
        let path = bundlePath.stringByAppendingPathComponent("emoticons.plist")
        let dictionary = NSDictionary(contentsOfFile: path)
        let packagesDict = dictionary!["packages"] as! [[String: AnyObject]]
        
        var arrayM = [EmoticonPackage(id: "", groupName: "最近WY").addRemoveEmoticon()]
        for dict in packagesDict {
            let ep = EmoticonPackage(id: dict["id"] as! String).loadGroup().addRemoveEmoticon()
            arrayM.append(ep)
        }
        return arrayM
    }
    /// 加载表情数组
    private func loadGroup() -> Self {
        let path = EmoticonPackage.bundlePath.stringByAppendingPathComponent(id).stringByAppendingPathComponent("info.plist")
        let dictionary = NSDictionary(contentsOfFile: path)!
        group_name_cn = dictionary["group_name_cn"] as! String
        let emoticonArr = dictionary["emoticons"] as! [[String: AnyObject]]
        var arrM = [Emoticon]()
        for dict in emoticonArr {
            let emoticon = Emoticon(dict: dict, id: id)
            // 添加删除emoticon
            if arrM.count > 0 && arrM.count % 21 == 0 {
                arrM.insert(Emoticon(removeFlag: true, id: id), atIndex: arrM.count - 1 )
            }
            arrM.append(emoticon)
        }
        emoticons = arrM
        return self
    }
    /// 添加空白按钮
    private func addRemoveEmoticon() -> Self {
        if emoticons == nil {
            emoticons = [Emoticon(removeFlag: false, id: id)]
        }
        let count = emoticons!.count % 21
        if count == 0 {
            return self
        }
        for _ in count..<20 {
            emoticons?.append(Emoticon(removeFlag: false, id: id))
        }
        // 添加最后的一个删除按钮
        emoticons?.append(Emoticon(removeFlag: true, id: id))
        
        return self
    }
    
    /// 重写description属性
    override var description: String {
        let keys = ["id", "group_name_cn", "emoticons"]
      return "\(dictionaryWithValuesForKeys(keys))"
    }
    
}

/// 表情模型
class Emoticon: NSObject {
    /// 所在包名
    var id: String
    /// 图片(文字形式的字符串)
    var chs: String?
    /// 图片名称
    var png: String? {
        didSet {
            let path = EmoticonPackage.bundlePath.stringByAppendingPathComponent(id).stringByAppendingPathComponent(png!)
            image = UIImage(contentsOfFile: path)
        }
    }
    /// 图片
    var image: UIImage?
    
    /// 16进制编码
    var code: String? {
        didSet {
            // 1.读取 16 进制字符串
            let scanner = NSScanner(string: code!)
            // 2.定义一个UInt32的整型接收字符串长度
            var count: UInt32 = 0
            scanner.scanHexInt(&count)
            // 3.将数值转换成Unicode字符
            let c = Character(UnicodeScalar(count))
            // 4.将字符转换成字符串
            imageStr = String(c)
        }
    }
    /// 显示图片的编码字符串
    var imageStr: String?
    
    /// 是否是删除按钮
    var isRemoveEmoticon: Bool?
    
    init(dict: [String: AnyObject], id: String) {
        self.id = id
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    init(removeFlag: Bool, id: String) {
        self.id = id
        isRemoveEmoticon = removeFlag
    }
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    /// 重写description属性
    override var description: String {
        let keys = ["id","chs", "png", "code"]
        return "\(dictionaryWithValuesForKeys(keys))"
    }
}








