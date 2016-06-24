//
//  Task.swift
//  taskapp
//
//  Created by 宮崎英美 on 2016/06/17.
//  Copyright © 2016年 e-miya. All rights reserved.
//

import RealmSwift

class Task: Object{
    // 管理用 ID。プライマリキー
    dynamic var id = 0
    
    //タイトル
    dynamic var title = ""
    
    //内容
    dynamic var contents = ""
    
    //日時
    dynamic var date = NSDate()
    
    //カテゴリー（追加）
    dynamic var category = ""
    
    /**
     idをプライマリキーとして設定
    */
    override static func primaryKey() -> String?{
        return "id"
    }
}

