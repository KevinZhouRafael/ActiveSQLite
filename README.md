# ActiveSQLite

[![Version](https://img.shields.io/cocoapods/v/ActiveSQLite.svg?style=flat)](http://cocoapods.org/pods/ActiveSQLite)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/ActiveSQLite.svg?style=flat)](http://cocoapods.org/pods/ActiveSQLite)
[![Platform](https://img.shields.io/cocoapods/p/ActiveSQLite.svg?style=flat)](http://cocoapods.org/pods/ActiveSQLite)


ActiveSQLite is an helper of [SQLite.Swift](https://github.com/stephencelis/SQLite.swift). It can let you use SQLite.swift easily.


## Features

 - Support all Features of SQLite.swift
 - Auto create tables
 - Auto add columns of id , created\_at , updated\_at 
 - Auto set values to attributes of models frome query sql 
 - Mapping name of table and name of model, mapping attributes and columns
 - Support Transcation and Asynchronous
 - A flexible, chainable, lazy-executing query layer
 - Query use String or Expression<T> of SQLite.swift
 - Logger level

## Example

To run the ActiveSQLiteTests target of project.


## Usage

### Model

```swift
import ActiveSQLite

class Product:DBModel{

    var name:String!
    var price:NSNumber!
    var desc:String?
    var publish_date:NSDate?

}

//save
let product = Product()
product.name = "iPhone 7"
product.price = NSNumber(value:599)
try! product.save()

//Query
let p = Product.findFirst("name",value:"iPhone") as! Product

//or 
let name = Expression<String>("name")
let p = Product.findAll(name == "iPhone")!.first as! Product

                        
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
ASConfigration.dbPath = "..."
```
If you not set dbPath, the default db file is "ActiveSQLite.db" in the documents directory.

## Building Type-Safe SQL

| ActiveSQLite<br />Swift Type    | SQLite.swift<br />Swift Type    | SQLite<br /> SQLite Type      |
| --------------- | --------------- | ----------- |
| `NSNumber `     | `Int64`         | `INTEGER`   |
| `NSNumber `     | `Double`        | `REAL`      |
| `String`        | `String`        | `TEXT`      |
| `nil`           | `nil`           | `NULL`      |
|                 | `SQLite.Blob`   | `BLOB`      |
| `NSDate`        | `Int64`         | `INTEGER`   |



NSNumber maps two SQLite.swift types. they are Int64 ans Double. The default type is Int64. You can override doubleTypeProperties() function of DBModel to mark properties are Double Type.

``` swift
class Product:DBModel{

    var name:String!
    var price:NSNumber!
    var desc:String?
    var publish_date:NSDate?

  override func doubleTypeProperties() -> [String]{
      return ["price"]
  }
  
}

```
The default SQLite.swift type of NSDate is Int64. You can map NSDate to String by looking [Custom Types of Documentaion](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#custom-types) of SQLite.swift


## Creating a Table

ActiveSQLite can auto create table and add "id", "created\_at" and "updated\_at" columns. "id" column is parimay key. The create code looks like:

``` swift
try db.run(products.create { t in      
    t.column(id, primaryKey: true)
    t.column(Expression<NSDate>("created_at"), defaultValue: NSDate(timeIntervalSince1970: 0))	
    t.column(Expression<NSDate>("updated_at"), defaultValue: NSDate(timeIntervalSince1970: 0))	
    t.column(...)  
    t.column(...)  
})                             

// CREATE TABLE "Products" (
//		"id" INTEGER PRIMARY KEY NOT NULL,
//		created_at INTEGER DEFAULT (0),
//		created_at INTEGER DEFAULT (0)
//	)
  
```
The "created\_at" and "updated\_at" columns' unit is ms.


### Mapper
You can custom name of table, names of column and prevent save some properties into database.

#### 1. Table name.

Default table name is class name of Model.

``` swift
// Set table name to "ProductTable"
override class var nameOfTable: String{
    return "ProductTable"
}
```

#### 2. Column name.

Default column name is same as properity name.

``` swift
//Set column name equals "product_name" when properity is "product"
//Set column name equals "price_name" when properity is "price"
override class func mapper() -> [String:String]{
    return ["name":"product_name","price":"product_price"];
}
```

#### 3. transient properties.

Transent properity is not saved into database.

``` swift
override class func transientProperties() -> [String]{
    return ["isSelected"]
}

```
ActiveSQLite can only save properities in (String,NSNumber,NSDate) into database. The properities of other types are not saved into database, they are transent properities.

### Table constraints
If you want custom columns by yourself, you just set model implements CreateColumnsProtocol, and comfirm createColumns function. Then the ActiveSQLite will not auto create columns. Make sure the properties' names of model mapping the columns'.

```swift

class Users:DBModel,CreateColumnsProtocol{
    var name:String!
    var email:String!
    var age:Int?
   
	func createColumns(t: TableBuilder) {
		t.column(Expression<NSNumber>("id"), primaryKey: true)
		t.column(Expression<String>("name"),defaultValue:"Anonymous")
		t.column(Expression<String>("email"), , check: email.like("%@%"))
	}
}
```
more infomations of [table constraints document](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#table-constraints) of SQLite.swift.

## Inserting Rows
There are only 3 functions used for insert rows. they are

Insert one.

```swift
func insert()throws ;
```

Insert more.

```swift
class func insertBatch(models:[DBModel])throws ;

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
There two strategies for update.

### 1. Update by attribute.

First modefiy attribute of model，and then save() or update() or updateBatch().
	
```swift
	p.name = "zhoukai"
	p.save()
```
	
### 2. Update by Setter.

Update one Product object to database. 

```swift
	p.update([Product.desc <- "normal",ProductM.price <- NSNumber(value:3))
```

Update one or more Products by Expression.

```swift
 Product.update([Product.desc <- "best"], where: ProductM.price == NSNumber(value:9999))
```
For more to see source code and example of ActiveSQLite, also look up document [Updating Rows document](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#updating-rows) , [Setters document](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#setters) of SQLite.swift.



## Selecting Rows

You can use findFirst to find one row, use findAll to find more rows.

The methods that prefix name is "find" are class method.

#### 1.Find by attribute.

```swift
let p = Product.findFirst("name",value:"iWatch") as! Product

let ps = Product.findAll("name",value:"iWatch",orders:["price",false]) as! [Product]

```

#### 2.Find by Expression.

```swift
let id = Expression<NSNumber>("id")
let name = Expression<String>("name")

let arr = Product.findAll(name == "iWatch") as! Array<Product>

let ps = Product.findAll(id > NSNumber(value:100), orders: [Product.id.asc]) as! [Product]

```

### Chainable Query
chainable query style methods are property method.

```swift
let products = Product().where(Expression<NSNumber>("code") > 3)
                                .order(Product.code)
                                .limit(5)
                                .run() as! [Product]

```
Don't forget excute run().

more complex queries to see source code and example of ActiveSQLite.
Look documents [Building Complex Queries](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#building-complex-queries) of SQLite.swift

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
                    debugPrint("transtion fails \(error)")
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
let db = ASConnection.sharedConnection.db
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
- Xcode 8.3.2
- Swift 3

## Installation

### Cocoapods

ActiveSQLite is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ActiveSQLite"
```


## Author

Rafael Zhou

- Email me: <wumingapie@gmail.com>
- Follow me on **Twitter**: [**@wumingapie**](https://twitter.com/wumingapie)
- Contact me on **Facebook**: [**wumingapie**](https://www.facebook.com/wumingapie)
- Contact me on **LinkedIn**: [**Rafael**](https://www.linkedin.com/in/rafael-zhou-7230943a/)

## License

ActiveSQLite is available under the MIT license. See the LICENSE file for more info.
