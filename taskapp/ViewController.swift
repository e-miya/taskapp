//
//  ViewController.swift
//  taskapp
//
//  Created by 宮崎英美 on 2016/06/17.
//  Copyright © 2016年 e-miya. All rights reserved.
//

import UIKit
import RealmSwift //追加

class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{

    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    //Realmインスタンスを取得する
//    let realm = try! Realm()    //追加  //課題削除
    
    //DB内のタスクが格納されるリスト
    //日付近い順\順でソート：降順
    //以降内容をアップデートするとリスト内は自動的に更新される
//    let taskArray = try! Realm().objects(Task).sorted("date",ascending: false)  //追加  //課題削除
    var taskArray = g_realm.objects(Task).sorted("date",ascending: false)  //課題追加
    var inputText:String!
    var beforeInputText:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: UITableViewDataSourceプロトコルのメソッド
    //データの数（＝セルの数）を返すメソッド
    func tableView(tableView: UITableView,numberOfRowsInSection section:Int) ->Int{
        return taskArray.count //追加
    }
    
    //各セルの内容を返すメソッド
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) ->UITableViewCell{
        //再利用可能なcellを得る
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        //Cellに値を設定する
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.stringFromDate(task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    //MARK: UITableViewDelegateプロトコルのメソッド
    //各セルを選択した時に実行されるメソッド
    func tableView(tableView:UITableView,didSelectRowAtIndexPath indexPath:NSIndexPath){
        performSegueWithIdentifier("cellSegue", sender: nil)
    }
    
    //セルが削除可能なことを伝えるメソッド
    func tableView(tableView:UITableView,editingStyleForRowAtIndexPath indexPath:NSIndexPath) ->UITableViewCellEditingStyle{
        return UITableViewCellEditingStyle.Delete
    }

    //Deleteボタンが押された時に呼ばれるメソッド
    func tableView(tableView:UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath:NSIndexPath){
        if editingStyle == UITableViewCellEditingStyle.Delete{
            
            //ローカル通知をキャンセルする
            let task = taskArray[indexPath.row]
            
            for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
                if notification.userInfo!["id"] as! Int == task.id {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                    break
                }
            }
            
            //データベースから削除する
//            try! realm.write {                                    //課題変更
//                self.realm.delete(self.taskArray[indexPath.row])  //課題変更
            try! g_realm.write {                                    //課題変更
                g_realm.delete(self.taskArray[indexPath.row])       //課題変更
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
    }
    
    //入力画面から戻ってきた時にTableViewを更新させる
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableview.reloadData()
    }
    
    // segueで画面遷移する際に呼ばれる
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let inputViewController:InputViewController = segue.destinationViewController as! InputViewController
        if segue.identifier == "cellSegue"{
            let indexPath = self.tableview.indexPathForSelectedRow
            inputViewController.task = taskArray[(indexPath?.row)!]
        }else{
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max("id")! + 1
            }
            inputViewController.task = task
        }
    }
    
    // サーチバー更新時
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        inputText = searchText
    }
    
    //検索キャンセル
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        inputText = ""
        searchBar.text = ""
    }
    
    //検索実行
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if inputText != "" && inputText != beforeInputText{
            let predicate = NSPredicate(format: "category = %@" , inputText)
            taskArray = g_realm.objects(Task).filter(predicate)
            beforeInputText = inputText
            tableview.reloadData()
            inputText = ""
            searchBar.text = ""
        }
        if taskArray.count == 0 {
            let alert = UIAlertController(title: "確認", message: "一致するデータは存在しません", preferredStyle: .Alert)
            let alertAcction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(alertAcction)
            presentViewController(alert, animated: true , completion: nil)
            searchBar.text = ""
        }
    }
    
    // 一覧の再表示
    @IBAction func RefreshButton(sender: AnyObject) {
        taskArray = g_realm.objects(Task).sorted("date",ascending: false)
        tableview.reloadData()
        inputText = ""
        searchBar.text = ""
    }

}

