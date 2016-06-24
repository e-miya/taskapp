//
//  InputViewController.swift
//  taskapp
//
//  Created by 宮崎英美 on 2016/06/17.
//  Copyright © 2016年 e-miya. All rights reserved.
//

import UIKit
import RealmSwift

class InputViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var contentsCategory: UITextField!       //課題追加
    @IBOutlet weak var saveButton: UIButton!
    
    
//    let realm = try! Realm()      //課題削除
    var task:Task!
    var saveFlag:Bool = false      //課題追加（変更あり：true、変更なし：false）
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 課題追加 start
        contentsTextView.layer.borderWidth = 0.5
        contentsTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        contentsTextView.layer.cornerRadius = 5
        // 課題追加 end
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGestuer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGestuer)
        
        titleTextField.text = self.task.title
        contentsTextView.text = self.task.contents
        datePicker.date = self.task.date
        contentsCategory.text = self.task.category   //課題追加
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        if saveFlag == true {
            //        try! realm.write {        // 課題変更
            try! g_realm.write {        // 課題変更
                self.task.title = self.titleTextField.text!
                self.task.contents = self.contentsTextView.text
                self.task.date = self.datePicker.date
                self.task.category = self.contentsCategory.text!    //課題追加
                //            self.realm.add(self.task, update: true)       //課題変更
                g_realm.add(self.task, update: true)            //課題変更
            }
            setNotification(self.task)
        }
        
        super.viewWillDisappear(animated)
    }
    
    func dismissKeyboard(){
        //キーボードを閉じる
        view.endEditing(true)
    }
    
    //タスクのローカル通知を設定する
    func setNotification(task: Task){
        if saveFlag == false {
            return
        }
        //すでに同じタスクが登録されていたらキャンセルする
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
            if notification.userInfo!["id"] as! Int == self.task.id {
                UIApplication.sharedApplication().cancelLocalNotification(notification)
                /*課題追加 START
                if self.task.title != self.titleTextField.text ||
                   self.task.contents != self.contentsTextView.text ||
                   self.task.date != self.datePicker.date ||
                   self.task.category != self.contentsCategory.text {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                }else{
                   changeFlag = false
                }
                *///課題追加 END

                break   //breakに来るとforループから抜け出せる
            }
        }
//        if changeFlag == true {     //課題追加
            let notification = UILocalNotification()
            
            notification.fireDate = self.task.date
            notification.timeZone = NSTimeZone.defaultTimeZone()
            notification.alertBody = "\(self.task.title)"
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.userInfo = ["id":self.task.id]
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
            
//        }   //課題追加
    }

    @IBAction func saveButton(sender: AnyObject) {
            saveFlag = true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
