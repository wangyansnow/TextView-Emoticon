//
//  EmoticonController.swift
//  01- 表情键盘
//
//  Created by 王俨 on 15/8/5.
//  Copyright © 2015年 王俨. All rights reserved.
//

import UIKit

class EmoticonController: UIViewController {
    /// 表情包数组
    private var emoticonPackages: [EmoticonPackage]?
    
    var emoticonCallBack: (emoticon: Emoticon) -> ()
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//        super.init(nibName: nil, bundle: nil)
//        view.backgroundColor = UIColor.orangeColor()
//        setupUI()
//    }
    init(emoticonCallBack: (emoticon: Emoticon) -> ()) {
        self.emoticonCallBack = emoticonCallBack
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = UIColor.whiteColor()
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        emoticonPackages = EmoticonPackage.loadEmoticonPackages()

    }
    /// 基本视图准备
    private func setupUI() {
        view.addSubview(toolBar)
        view.addSubview(collectionView)
        
        // 自动布局
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let attrs = ["toolBar": toolBar, "collectionView": collectionView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[toolBar]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: attrs))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: attrs))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[collectionView]-0-[toolBar(44)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: attrs))
        
        prepareToolBar()
        prepareCollectionView()
    }
    /// 可重用ID
    private let reuseIdentifier = "EmoticonCell"
    /// 设置collectionView
    private func prepareCollectionView() {
//        collectionView.backgroundColor = UIColor.yellowColor()
        collectionView.registerClass(EmoticonCell.self, forCellWithReuseIdentifier:reuseIdentifier )
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    /// 准备工具栏
    private func prepareToolBar() {
        var items = [UIBarButtonItem]()
        var tag = 0
        for name in EmoticonPackage.groupNames! {
            let item = UIBarButtonItem(title: name, style: UIBarButtonItemStyle.Plain, target: self, action: "toolBarItemClick:")
            item.tag = tag++
            let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            items.append(item)
            items.append(flexibleItem)
        }
        items.removeLast()
        toolBar.items = items
        toolBar.backgroundColor = UIColor.darkGrayColor()
        toolBar.tintColor = UIColor(white: 0.4, alpha: 1.0)
    }
     /// 监听底部工具栏按钮点击 -- 跳转到对应的表情包
    func toolBarItemClick(item: UIBarButtonItem) {
        let indexPath = NSIndexPath(forItem: 0, inSection: item.tag)
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
    }
     // MARK: - 懒加载控件
    /// 工具栏
    private lazy var toolBar: UIToolbar = UIToolbar()
    /// UICollectionView
    private lazy var collectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: WYCollectionViewFlowLayout())

    
    /// 表情键盘布局
    private class WYCollectionViewFlowLayout: UICollectionViewFlowLayout {
        
        private override func prepareLayout() {
            let width = (collectionView?.bounds.width)! / 7
            itemSize = CGSizeMake(width, width)
            // 这里使用0.499 是因为如果使用0.5在iPhone4s 上面只能够显示两排
            let margin = (collectionView!.bounds.height - 3 * width) * 0.499
            minimumInteritemSpacing = 0
            minimumLineSpacing = 0
            scrollDirection = UICollectionViewScrollDirection.Horizontal
            collectionView?.bounces = false
            collectionView?.showsHorizontalScrollIndicator = false
            collectionView?.pagingEnabled = true
            sectionInset = UIEdgeInsets(top: margin, left: 0, bottom: margin, right: 0)
            
        }
    }

}

extension EmoticonController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: UICollectionView数据源方法
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return emoticonPackages?.count ?? 0
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emoticonPackages![section].emoticons?.count ?? 0
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EmoticonCell
        cell.backgroundColor = (indexPath.item % 2 == 0) ? UIColor.redColor() : UIColor.orangeColor()
        // 获取模型
        let emoticon = emoticonPackages![indexPath.section].emoticons![indexPath.item]
        cell.emoticon = emoticon
        return cell
    }
    // MARK: UICollectionView代理方法
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // 1.获取当前用户点击了哪个cell
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! EmoticonCell
        let emoticon = cell.emoticon!
        emoticonCallBack(emoticon: emoticon)
    }
    
}

class EmoticonCell: UICollectionViewCell {
    /// 表情
    var emoticon: Emoticon? {
        didSet {
            emoticonBtn.setImage(emoticon?.image, forState: UIControlState.Normal)
            emoticonBtn.setTitle(emoticon?.imageStr, forState: UIControlState.Normal)
            if let removeflag = emoticon?.isRemoveEmoticon where removeflag {
                emoticonBtn.setImage(UIImage(named: "compose_emotion_delete"), forState: UIControlState.Normal)
                emoticonBtn.setImage(UIImage(named: "compose_emotion_delete_highlighted"), forState: UIControlState.Highlighted)
            }
        }
    }
    
    override init(frame: CGRect) {
         super.init(frame: frame)
        setBtn()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     /// 设置按钮
    private func setBtn() {
        emoticonBtn.frame = CGRectInset(contentView.bounds, 4, 4)
        emoticonBtn.backgroundColor = UIColor.whiteColor()
        contentView.addSubview(emoticonBtn)
        // 禁止按钮和用户交互
        emoticonBtn.userInteractionEnabled = false
        // 设置按钮标题文字大小
        emoticonBtn.titleLabel?.font = UIFont.systemFontOfSize(32)
    }
    
    private lazy var emoticonBtn: UIButton = UIButton()
}







