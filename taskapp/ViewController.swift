//
//  ViewController.swift
//  taskapp
//
//  Created by 柳澤宏輔 on 2017/08/17.
//  Copyright © 2017年 kousuke.yanagisawa. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var tableView: UITableView!
  
  //realmのインスタンスを取得
  let realm = try! Realm()
  
  //DB内のタスクが格納されるリスト。日付近い順でソート　以降、内容をアップデートするとリストは自動的に更新される。
  var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath:"date", ascending: false)
  

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    tableView.delegate = self
    tableView.dataSource = self
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  //segue　で遷移する時に呼ばれる
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let inputViewController:InputViewController = segue.destination as! InputViewController
    
    if segue.identifier ==  "cellSegue"{
      let indexPath = self.tableView.indexPathForSelectedRow
      inputViewController.task = taskArray[indexPath!.row]
      print("cellsegueだったのでそのまま遷移したよ")//デバッグ用
    }else{
      print("cellsegueではなかったので色々やってから遷移したよ")//デバッグ用
      let task = Task()
      task.date = NSDate()
      
      if taskArray.count != 0{
        //既存の最大idより一つ大きいidを作成して代入
        print("taskarray.countが0ではなかったよ！（\(taskArray.count)）")
        task.id = taskArray.max(ofProperty: "id")! + 1
      }
      
      inputViewController.task = task
    }
  }
  
  //入力画面から戻ってきたときにtableviewをこうしん
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
  
  
  //MARK:UITableVIewDataSourceプロトコルのメソッド
  //データの数を返すメソッド
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    print("tableview.count = \(taskArray.count)")//??なんで４回も実行されてるの？
    return taskArray.count
  }
  
  //各セルの内容を返すメソッド
  //taskarrayから該当するデータを取り出してセルに設定
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //再利用可能なcellを得る
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    //cellに値を設定する
    let task = taskArray[indexPath.row]
    cell.textLabel?.text = task.title
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    
    let dateString:String = formatter.string(from: task.date as Date)
    cell.detailTextLabel?.text = dateString
    
    return cell
  }
  
  //MARK:uitableviewdelegateプロトコルのメソッド
  //各セルを選択した時に実行されるメソッド
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "cellSegue", sender: nil)
  }
  
  //セルが削除が可能なことを伝えるメソッド
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    return UITableViewCellEditingStyle.delete
  }
  
  //delete ぽたんが押された時に呼ばれるメソッド
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == UITableViewCellEditingStyle.delete{
      
      //削除されたタスクを取得する
      let task = self.taskArray[indexPath.row]
      
      //ローカル通知をキャンセルする
      let center = UNUserNotificationCenter.current()
      center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
      
      //データベースから削除する
      try! realm.write {
        self.realm.delete(self.taskArray[indexPath.row])
        tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
      }
      
      //未通知のローカル通知一覧をログ出力
      center.getPendingNotificationRequests{(requests:[UNNotificationRequest]) in
        for request in requests{
          print("/----------")
          print(request)
          print("/----------")
        }
        
      }
    }
  }//func

}
