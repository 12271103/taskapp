import RealmSwift

class Task:Object {
  //管理用ID プライマリーキー
  dynamic var id = 0
  
  //タイトル
  dynamic var title = ""
  
  //内容
  dynamic var contents = ""
  
  //日時
  dynamic var date = NSDate()
  
  //categoryのstringプロパティを作成
  dynamic var category = ""
  
  
  /**
 idをプライマリキーとして設定
 */
  override static func primaryKey() -> String?{
    return "id"
  }
}
