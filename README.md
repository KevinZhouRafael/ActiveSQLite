# ActiveSQLite

[![Version](https://img.shields.io/cocoapods/v/ActiveSQLite.svg?style=flat)](http://cocoapods.org/pods/ActiveSQLite)
<!--[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)-->
[![License](https://img.shields.io/cocoapods/l/ActiveSQLite.svg?style=flat)](http://cocoapods.org/pods/ActiveSQLite)
[![Platform](https://img.shields.io/cocoapods/p/ActiveSQLite.svg?style=flat)](http://cocoapods.org/pods/ActiveSQLite)


ActiveSQLite is an helper of [SQLite.Swift](https://github.com/stephencelis/SQLite.swift). It can let you use SQLite.swift easily.<p>
There is a project named [Reed downloader](https://github.com/KevinZhouRafael/Reed) used ActiveSQLite.<p>
[**中文说明**](README_cn.md)

## Features

 - [x] Support all Features of SQLite.swift.
 - [x] Auto create tables. Auto add columns of id , created\_at , updated\_at .
 - [x] Auto set values to attributes of models frome query sql 
 - [x] Mapping name of table with name of model, mapping attribute names with column names
 - [x] Support Transcation and Asynchronous
 - [x] A flexible, chainable, lazy-executing query layer
 - [x] Query use String or Expression<T> of SQLite.swift
 - [x] Logger level
 - [ ] Runtime Encoding to Codable Encoding
 - [ ] Complete Protocol Oriented Programming
 - [ ] Table relations
 - [ ] Cache and Faults value


## Example

To run the ActiveSQLiteTests target of project.


## Usage

```swift
import ActiveSQLite

class Product:ASModel{
    var name:String = ""
    var price:NSNumber = NSNumber(value:0.0)
    var desc:String?
    var publish_date:NSDate?
}

//save
let product = Product()
product.name = "iPhone 7"
product.price = NSNumber(value:599)
try! product.save()

//Query
let p = Product.findFirst("name",value:"iPhone")

//or 
let name = Expression<String>("name")
let p = Product.findAll(name == "iPhone").first
//id = 1, name = iPhone 7, price = 599, desc = nil,  publish_date = nil, created_at = 1498616987587.237, updated_at = 1498616987587.237, 

//Update
p.name = "iPad"
try! p.update()


//Delete
p.delete()

```

## Getting Started

To use ActiveSQLite classes or structures in your target’s source file, first import the `ActiveSQLite` module.

``` swift
import ActiveSQLite
```


### Connecting to a Database

``` swift
ASConfigration.setDefaultDB(path:"db file path", name: "default db name")

//If you want a other db
ASConfigration.setDB(path: "other db file path", name: "other db name")

```
You must set default db path.


## Building Type-Safe SQL

| ActiveSQLite<br />Swift Type    | SQLite.swift<br />Swift Type    | SQLite<br /> SQLite Type      | SQLite Default Value<br /> If not use optionl property |
| --------------- | --------------- | ----------- | ---------- |
| `NSNumber `     | `Int64`         | `INTEGER`   | `0`|
| `NSNumber `     | `Double`        | `REAL`      |`0.0`|
| `String`        | `String`        | `TEXT`      |`""`|
| `nil`           | `nil`           | `NULL`      |`NULL`|
|                 | `SQLite.Blob`   | `BLOB`      ||
| `NSDate`        | `Int64`         | `INTEGER`   |`0`|



The NSNumber Type maps with two SQLite.swift's Swift Type. they are Int64 ans Double. The default type is Int64. You can override doubleTypes() function of ASModel to mark properties are Double Type.

``` swift
class Product:ASModel{

    var name:String = ""
    var price:NSNumber = NSNumber(value:0.0)
    var desc:String?
    var publish_date:NSDate?

  override func doubleTypes() -> [String]{
      return ["price"]
  }
  
}
```


ActiviteSQLite map NSDate to Int64 of SQLite.swift. You can map NSDate to String by looking [Custom Types of Documentaion](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#custom-types) of SQLite.swift


## Creating a Table

ActiveSQLite auto create table and add "id". The create code looks like below:

``` swift
try db.run(products.create { t in      
    t.column(id, primaryKey: true)
    t.column(Expression<NSDate>("created_at"), defaultValue: NSDate(timeIntervalSince1970: 0))	
    t.column(Expression<NSDate>("updated_at"), defaultValue: NSDate(timeIntervalSince1970: 0))	
    t.column(...)  

})                             

// CREATE TABLE "Products" (
//		"id" INTEGER PRIMARY KEY NOT NULL,
//		created_at INTEGER DEFAULT (0),
//		created_at INTEGER DEFAULT (0),
//     ...
//	)
  
```
The unit of "created\_at" and "updated\_at" columns is ms.

### From ActiveSQLite0.4.0 to 0.4.1

ActiveSQLite0.4.0 can use 3 types to define property: T, T!, T?.<br>
ActiveSQLite0.4.1 use 2 types to define property: T, T?.

| type		|  0.4.0    | 0.4.1    |
| --------------- | --------------- | ----------- |
| `T `    | `not nil`        | `not nil`   |
| `T! `   | `not nil`        | `can be nil. use T? replace`|
| `T?`    | `can be nil`     | `can be nil`|
| `pirmary key id` | `is T! type`	|` is T? type.`|

If you want find the db column default value to see the first table in this document.


### Mapper
You can custom name of table, names of column and prevent save some properties into database.

#### 1. DB name.
If you use one db, only setDefaultDB(path:name:),, you needn't do anything. If you set you table in other db, you must override dbName.

``` swift

ASConfigration.setDefaultDB(path:"db file path", name: "default db name")
ASConfigration.setDB(path: "other db file path", name: "other db name")

override class var dbName:String?{
    return "other db name"
}
```

#### 2. Table name.

Default table name is same with class name, you needn't do anything. If you want use different name ,you must override nameOfTable.

``` swift
// Set table name to "ProductTable"
override class var nameOfTable: String{
    return "ProductTable"
}
```

#### 3. Column name.

Default column name is same with properity name, you needn't do anything. If you want use different name, you must override mapper().

``` swift
override func mapper() -> [String:String]{
    return ["property_name":"column_name"];
}
```

If you let primary key is not "id",use like this:

``` swift
override class var PRIMARY_KEY:String{
    return "_id"
}
    
override func mapper() -> [String:String]{
    return ["id":"_id"]
}
``` 


#### 4. Transient properties.

Transent properitird have not been saved into database.

``` swift
override class func transientTypess() -> [String]{
    return ["isSelected"]
}

```
ActiveSQLite can only save properities in (String,NSNumber,NSDate) into database. The properities without in these types are not be saved into database, they are transent properities.

#### 5. Auto create "created\_at" and "updated\_at" columns. 

Just override isSaveDefaulttimestamp, don't do anything, the super class ASModel already define "created\_at" and "updated\_at" properies.

```swift

override class var isSaveDefaulttimestamp:Bool{
        return true
}
    
```

### Table constraints
If you want custom columns by yourself, you just set model implements CreateColumnsProtocol, and comfirm createColumns function. Then the ActiveSQLite will not auto create columns. Make sure the properties' names of model mapping the columns'.

```swift

class Users:ASModel,CreateColumnsProtocol{
    var name:String = ""
    var email:String = ""
    var age:Int?
   
    func createColumns(t: TableBuilder) {
        t.column(Expression<NSNumber>("id"), primaryKey: true)
        t.column(Expression<String>("name"),defaultValue:"Anonymous")
        t.column(Expression<String>("email"), , check: email.like("%@%"))
    }
}
```
find more infomations to look up [table constraints document](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#table-constraints) of SQLite.swift.

## Inserting Rows
There are 3 functions used for insert rows. they are

Insert one.

```swift
func insert()throws ;
```

Insert more.

```swift
class func insertBatch(models:[ASModel])throws ;

```

Save method.

Insert or Update. Insert if id == nil. Update if id != nil.

```swift
func save() throws;
```

eg:

```swift
let u = Users()
u.name = "Kevin"
try! u.save()
                
var products = [Product]()
for i in 1 ..< 8 {
    let p = Product()
    p.name = "iPhone-\(i)"
    p.price = NSNumber(value:i)
    products.append(p)
}
                
try! Product.insertBatch(models: products)

```
For more to see source code or example of ActiveSQLite, also look up document [Inserting Rows document](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#inserting-rows) of SQLite.swift.

## Updateing Rows
There 3 strategies for update.

### 1. Update by attribute.

First modefiy attribute of model，and then save() or update() or updateBatch().
	
```swift
p.name = "zhoukai"
p.save()

```
	
### 2. Update by String:Value.

```swift
//Update one
u.update("name",value:"3ds")
u.update(["name":"3ds","price":NSNumber(value:199)])


//Update more

Product.update(["name": "3ds","price":NSNumber(value:199)], where: ["id": NSNumber(1)])

```

### 2. Update by Setter.

Update one Product object to database. 

```swift
//Update one
p.update([Product.price <- NSNumber(value:199))

//Update more
Product.update([Product.price <- NSNumber(value:199), where: Product.name == "3ds")
```

For more to see source code and example of ActiveSQLite, also look up document [Updating Rows document](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#updating-rows) , [Setters document](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#setters) of SQLite.swift.


## Selecting Rows

You can use findFirst to find one row, use findAll to find more rows.

The methods that prefix name is "find" are class method.

#### 1.Find by attribute.

```swift
let p = Product.findFirst("name",value:"iWatch")

let ps = Product.findAll("name",value:"iWatch",orders:["price",false])

```

#### 2.Find by Expression.

```swift
let id = Expression<NSNumber>("id")
let name = Expression<String>("name")

let arr = Product.findAll(name == "iWatch")

let ps = Product.findAll(id > NSNumber(value:100), orders: [Product.id.asc])

```

### Chainable Query
chainable query style methods are property method.

```swift
let products = Product().where(Expression<NSNumber>("code") > 3)
                                .order(Product.code)
                                .limit(5)
                                .run()

```
Don't forget excute run().

more complex queries to see source code and example of ActiveSQLite.
Look documents [Building Complex Queries](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#building-complex-queries) of SQLite.swift

## Expression
SQLite.swift use Expression replece 'where' SQL when you execute update and select SQLs.
Complex Expression to look for [filtering-rows](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#filtering-rows)

## Deleting Rows

```swift
//1. Delete one row
try? product.delete()

//2. Delete all rows
try? Product.deleteAll()

//3. Delete by Expression and chains.
try? Product().where(Expression<NSNumber>("code") > 3)
                                .runDelete()

```

## Transactions
I suggest that you should put all insert, update, delete and alter tables codes into ActiveSQLite.save block. One block is a transaction.

```swift
 ActiveSQLite.save({ 

                var products = [Product]()
                for i in 0 ..< 3 {
                    let p = Product()
                    p.name = "iPhone-\(i)"
                    p.price = NSNumber(value:i)
                    products.append(p)
                }
                try Product.insertBatch(models: products)
                

                let u = Users()
                u.name = "Kevin"
                try u.save()
                

            }, completion: { (error) in
                
                if error != nil {
                    debugPrint("transtion failed \(error)")
                }else{
                    debugPrint("transtion success")
                }

            })

```

## Asynichronous
ActiveSQLite.saveAsync also contains one transcation function.

```swift
 ActiveSQLite.saveAsync({ 
			.......

            }, completion: { (error) in
                ......
            })
```
## Altering the Schema
### Renaming Tables and Adding Columns

#### Step 1.You must change model use new columns and new table name.

```swift
class Product{
	var name:String!
	
	var newColumn:String!
	override class var nameOfTable: String{
    	return "newTableName"
	}
	
}
```

#### Step 2. Execute alter table sql when db version update.

```swift
let db = DBConnection.sharedConnection.db
            if db.userVersion == 0 {
                ActiveSQLite.saveAsync({
                    try Product.renameTable(oldName:"oldTableName",newName:"newTableName")
                    try Product.addColumn(["newColumn"])
                    
                }, completion: { (error) in
                    if error == nil {
                    
                    	db.userVersion = 1
                    }
                })
                
            }             

```
more to look [Altering the Schema](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#altering-the-schema) of SQLite.swift

### Indexes

```swift
	let name = Expression<String>("name")
	Product.createIndex(name)
	Product.dropIndex(name)
```
more to see [Indexes of SQLite.swift Document](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#indexes)

### Dropping Tables
```swift
Product.dropTable()
```

## Logging
There are 4 log levels: debug,info,warn,error.
The default log level is info. Setting log level like this:

```swift
//1. Set log level
ASConfigration.logLevel = .debug

//2. Set db path
ASConfigration.dbPath = "..."
```
Make sure setting log level before setting database path.


## Requirements
- iOS 8.0+  
- Xcode 10.2
- Swift 5

## Installation

### Cocoapods

ActiveSQLite is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ActiveSQLite"
```


## Author

Kevin Zhou

- Email me: <wumingapie@gmail.com>
- Contact me on **Facebook**: [**wumingapie**](https://www.facebook.com/wumingapie)
- Contact me on **WeChat&QQ**: 358545592

## License

ActiveSQLite is available under the MIT license. See the LICENSE file for more info.
