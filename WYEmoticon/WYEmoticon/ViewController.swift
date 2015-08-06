//
//  ViewController.swift
//  WYEmoticon
//
//  Created by 王俨 on 15/8/6.
//  Copyright © 2015年 wangyan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
     /// 表情控制器
    private lazy var emoticonController: EmoticonController = EmoticonController {[weak self] (emoticon) -> () in
        self?.textView.insertEmoticon(emoticon)
    }

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.inputView = emoticonController.view
    }

   


}

