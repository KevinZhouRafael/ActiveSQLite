# ActiveSQLite

[![Version](https://img.shields.io/cocoapods/v/ActiveSQLite.svg?style=flat)](http://cocoapods.org/pods/ActiveSQLite)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/ActiveSQLite.svg?style=flat)](http://cocoapods.org/pods/ActiveSQLite)
[![Platform](https://img.shields.io/cocoapods/p/ActiveSQLite.svg?style=flat)](http://cocoapods.org/pods/ActiveSQLite)


ActiveSQLite is an helper of [SQLite.Swift](https://github.com/stephencelis/SQLite.swift). It can let you use SQLite.swift easily.


## Features

 - Support all Features of SQLite.swift
 - Auto create tables
 - Auto add columns of id, created_at, updated_at 
 - Auto set values to attributes of database models
 - Map name of table, attributes and columns
 - A flexible, chainable, lazy-executing query layer
 - Query use String or Expression<T> of SQLite.swift

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
let p = ProductM.findAll(Product.name == "iPhone")!.first as! ProductM

                        
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
DBConfigration.dbPath = "..."
```
If you not set dbPath, the default dbPath is ActiveSQLite.db in the documents directory.

## Building Type-Safe SQL

| ActiveSQLite    | SQLite.swift    | SQLite      |
| Swift Type      | Swift Type      | SQLite Type |
| --------------- | --------------- | ----------- |
| `NSNumber`      | `Int64`         | `INTEGER`   |
| `NSNumber`      | `Double`        | `REAL`      |
| `String`        | `String`        | `TEXT`      |
| `nil`           | `nil`           | `NULL`      |
|                 | `SQLite.Blob`†  | `BLOB`      |
| `NSDate`        | `Int64`         | `INTEGER`   |

NSNumber maps two SQLite.swift types. they are Int64 ans Double. The default type is Int64. You can override doubleTypeProperties() function of DBModel like this.

``` swift
class Product:DBModel{

    var name:String!
    var price:NSNumber!
    var desc:String?
    var publish_date:NSDate?

  override class func doubleTypeProperties() -> [String]{
      return ["price"]
  }
  
}

```
The default SQLite.swift type of NSDate is Int64. You can map NSDate to String throuth look [Custom Types of Documentaion](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#custom-types) of SQLite.swift


## Creating a Table

ActiveSQLite can auto create table and add "id", "created_at","updated_at" columns. "id" columns is parimay key. It looks like:

``` swift
try db.run(products.create { t in      
    t.column(id, primaryKey: true)
    t.column(Expression<NSDate>("created_at"), defaultValue: NSDate(timeIntervalSince1970: 0))	
    t.column(Expression<NSDate>("updated_at"), defaultValue: NSDate(timeIntervalSince1970: 0))	
    t.column(...)  //
    t.column(...)  
})                             

// CREATE TABLE "Products" (
//		"id" INTEGER PRIMARY KEY NOT NULL,
//		created_at INTEGER DEFAULT (0),
//		created_at INTEGER DEFAULT (0)
//	)
  
```
The created_at and updated_at columns' unit is ms.


### Mapper
You can custom name of table, names of columns and prevent save some properties into database.

``` swift

//1. table name.
// Default table name is Class name of Model.
// Set table name to "ProductTable"
override class var nameOfTable: String{
    return "ProductTable"
}

//2. column name.
// Default column name is same as properity name.
// Set column name of "name" properity is "product_name"
// Set column name of "name" properity is "product_name"
override class func mapper() -> [String:String]{
    return ["name":"product_name","price":"product_price"];
}

//3. Transent properity is not saved into database.
override class func transientProperties() -> [String]{
    return ["isSelected"]
}

```
ActiveSQLite can only save properities in (String,NSNumber,NSDate) into database. The properities of other types are not saved into database, they are transent properities.

### table constraints
If you want custom columns by yourself. you just set model implements CreateColumnsProtocol, and comfirm createColumns. Then the auto create columns will stop. Make sure the properties' names of model mapping columns'.

```swift

class Users:DBModel,CreateColumnsProtocol{
    var name:String!
    var email:String!
    var age:NSNumber!
   
	func createColumns(t: TableBuilder) {
    	t.column(Expression<NSNumber>("id"), primaryKey: true)
		t.column(Expression<String>("name"),defaultValue:"Anonymous")
    	t.column(Expression<String>("email"), , check: email.like("%@%"))
	}
}
```
more infomations of [table constraints document](https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#table-constraints).

//savepoint demo. TODO
begin;
update Users set name = 'sgr' where `id` = '1';
select * from Users where `id` = '1';

savepoint 'abc';
update Users set name = 'zk' where `id` = '1';
relEASE 'abc';

commIT;

## Requirements
- iOS 8.0+  
- Xcode 7.3
- Swift 3.0.1

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
