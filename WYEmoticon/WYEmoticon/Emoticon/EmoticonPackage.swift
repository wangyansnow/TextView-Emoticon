//
//  EmoticonPackage.swift
//  01- 表情键盘
//
//  Created by 王俨 on 15/8/6.
//  Copyright © 2015年 王俨. All rights reserved.
//

import UIKit

class EmoticonPackage: NSObject, NSCoding {

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
    /// 表情包(全局使用)
    static let packages: [EmoticonPackage] = EmoticonPackage.loadEmoticonPackages()
    /// 加载表情包数组
    class func loadEmoticonPackages() -> [EmoticonPackage] {
        // 1.获取文件路径
        let path = bundlePath.stringByAppendingPathComponent("emoticons.plist")
        let dictionary = NSDictionary(contentsOfFile: path)
        let packagesDict = dictionary!["packages"] as! [[String: AnyObject]]
        
        // 2.从沙盒中取出常用的表情数组
        var arrayM = [EmoticonPackage]()
        let m = EmoticonPackage.unarchive()
        if let mp = m {
            arrayM.append(mp)
        } else {
            arrayM.append(EmoticonPackage(id: "", groupName: "最近WY").addRemoveEmoticon())
        }
        
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
    /// 添加常用数组
    class func addFavoriteEmoticon(emoticon: Emoticon) {
        // 1.获取常用表情包数组
        var ems = packages[0].emoticons
        if emoticon.isRemoveEmoticon {
            print("删除按钮你来捣什么乱")
            return
        }
        // 2.删除 '删除' 按钮
        ems?.removeLast()
        
        // 3.判断表情是否已经在常用数组中
        if !ems!.contains(emoticon) {
            ems?.append(emoticon)   //不存在则添加
        }
        emoticon.times++
        ems = ems?.sort({ return $0.times > $1.times })
        if ems?.count > 20 {
            ems?.removeLast()
        }
        // 4.添加删除按钮
        ems?.append(Emoticon(removeFlag: true, id: ""))
        // 5.保存到沙盒中
        packages[0].emoticons = ems!
        packages[0].archivie()
    }
    // MARK: - 归档 & 反归档
    /// 沙盒路径
    class var archivePath: String {
        return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!.stringByAppendingPathComponent("packageEmoticon.plist")
    }
    /// 保存模型到沙盒
    func archivie() {
       NSKeyedArchiver.archiveRootObject(self, toFile: EmoticonPackage.archivePath)
    }
    /// 从沙河取出模型
    class func unarchive() -> EmoticonPackage? {
        let emp = NSKeyedUnarchiver.unarchiveObjectWithFile(EmoticonPackage.archivePath) as? EmoticonPackage
        if let emoticons = emp?.emoticons {
            emp!.emoticons = emoticons.sort({ return $0.times > $1.times })
            print(" emp!.emoticons == \( emp!.emoticons?.count)")
            return emp
        }
        return nil
        
    }
    /// 归档
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(group_name_cn, forKey: "group_name_cn")
        aCoder.encodeObject(emoticons, forKey: "emoticons")
    }
    /// 返归档
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObjectForKey("id") as! String
        group_name_cn = aDecoder.decodeObjectForKey("group_name_cn") as! String
        emoticons = aDecoder.decodeObjectForKey("emoticons") as? [Emoticon]
        super.init()
    }
    /// 重写description属性
    override var description: String {
        let keys = ["id", "group_name_cn", "emoticons"]
      return "\(dictionaryWithValuesForKeys(keys))"
    }
    
}

/// 表情模型
class Emoticon: NSObject, NSCoding {
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
    var isRemoveEmoticon = false
    /// 表情使用此时
    var times = 0
    
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
    // MARK: - 归档 & 反归档
    /// 沙盒存储路径
    class var emoticonPath: String {
        return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!.stringByAppendingPathComponent("emoticon.plist")
    }
    /// 保存数据到沙盒
    private func archive() {
        NSKeyedArchiver.archiveRootObject(self, toFile: Emoticon.emoticonPath)
    }
    /// 从沙河获取数据
    class private func unarchive() {
        NSKeyedUnarchiver.unarchiveObjectWithFile(Emoticon.emoticonPath)
    }
    /// 归档
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(chs, forKey: "chs")
        aCoder.encodeObject(png, forKey: "png")
        aCoder.encodeObject(image, forKey: "image")
        aCoder.encodeObject(code, forKey: "code")
        aCoder.encodeObject(imageStr, forKey: "imageStr")
        aCoder.encodeBool(isRemoveEmoticon, forKey: "isRemoveEmoticon")
        aCoder.encodeInteger(times, forKey: "times")
    }
    /// 反归档
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObjectForKey("id") as! String
        chs = aDecoder.decodeObjectForKey("chs") as? String
        png = aDecoder.decodeObjectForKey("png") as? String
        image = aDecoder.decodeObjectForKey("image") as? UIImage
        code = aDecoder.decodeObjectForKey("code") as? String
        imageStr = aDecoder.decodeObjectForKey("imageStr") as? String
        isRemoveEmoticon = aDecoder.decodeBoolForKey("isRemoveEmoticon")
        times = aDecoder.decodeIntegerForKey("times")
    }
    /// 重写description属性
    override var description: String {
        let keys = ["id","chs", "png", "code"]
        return "\(dictionaryWithValuesForKeys(keys))"
    }
}








