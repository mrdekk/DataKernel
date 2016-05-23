# DataKernel

[![Language: Swift](https://img.shields.io/badge/lang-Swift-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Language: Swift](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](http://opensource.org/licenses/MIT)
[![Build Status](https://travis-ci.org/mrdekk/DataKernel.svg?branch=master)](https://travis-ci.org/pepibumur/SugarRecord)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/badge/Cocoa_Pods-compatible-4BC51D.svg?style=flat)](http://cocoapods.org)

## What is DataKernel?

DataKernel is a minimalistic wrapper around CoreData stack to ease persistence operations. It is havily inspired by [SugarRecord][site-sugarrecord] but have no external dependencies (except cocoa of course) and with some refinements. It is covered with unit tests.

[site-sugarrecord]: https://github.com/pepibumur/SugarRecord

If you have any propositions please file issue.
If you need usage examples - see unit test, it is very straightforward

## Features
- Swift (tested in xCode 7.2.1, xCode 7.3.0)
- Protocols based design
- Fully tested
- Actively supported
- Rich set of operations (but I think something may be missed)
- No iCloud yet (but planned)

## Note

- context.wipe uses NSBatchDeleteRequest on iOS 9 and OSX 10.11, it gives big performance improvements, but can cause problems if you use patterns like wipe all and create new, because it acts directly on persistent store (see Apple WWDC 2015 video or slides)

## Setup

### [CocoaPods](https://cocoapods.org)

1. Install [CocoaPods](https://cocoapods.org). You can do it with `gem install cocoapods`
2. Edit your `Podfile` file and add the following line `pod 'DataKernel'` (you have to use use_frameworks!, because this is a Swift pod)
3. Update your pods with the command `pod install`
4. Open the project from the generated workspace (`.xcworkspace` file).

*Note: You can also test the last commits by specifying it directly in the Podfile line*

### [Carthage](https://carthage)
1. Install [Carthage](https://github.com/carthage/carthage) on your computer using `brew install carthage`
3. Edit your `Cartfile` file adding the following line `github "mrdekk/DataKernel"`
4. Update and build frameworks with `carthage update`
5. Add generated frameworks to your app main target following the steps [here](https://github.com/carthage/carthage)
6. Link your target with **CoreData** library *(from Build Phases)*

# How to use

#### Creating your Storage

A storage is a general wrapper around CoreData PersistentStoreCoordination and PersistentStores. The first step you need to get started is to create `CoreDataLocalStorage`.

```swift
let store = StoreRef.Named("test1")
let bundle = NSBundle(forClass: self.classForCoder)
let model = ModelRef.Merged([bundle])
let storage = try! CoreDataLocalStorage(store: store!, model: model!, migration: true)
```

#### Contexts

Storage offer access to uiContext (NSManagedObjectContext on main thread to **GET** data from storage). All modification operations on CoreData entities should be performed with `perform` operation on storage. 

#### Fetching data

```swift
let cars: [Cars] = try! storage.uiContext.fetch(Request<Car>().filter("mark", equalTo: "Honda"))
let cars: [Cars] = try! storage.uiContext.fetch(Request<Car>())
let cars: [Cars] = try! storage.uiContext.fetch(Request<Car>().sort("model", ascending: true))

let predicate = NSPredicate(format: "model == %@", "CRZ")
let crz: Car? = try! storage.uiContext.fetch(Request<Car>(predicate: predicate)).first
```

#### Remove/Insert/Update operations

All modification operations should be performed under `perform` operation due to it handles all core data context/threading things internally and you can safely use modification operations under them.

`save` operation perform recursive save with nesting context on core data stack. So, if you change entities that already loaded in uiContext, they will be updated.

Note the first parameter `ephemeral` on `perform` function. If it is true, new context for this operation will be created, and then after save succeeded it will be removed. Creation of contexts in CoreData is rather cheap operations, so don't worry. If you don't need to save data in ephemeral context, just don't call `save`. If you set `ephemeral = false` than precreated special save context will be used for all `ephemeral = false` operations.

```swift
do {
  storage.perform(true) { (context, save) throws -> Void in
    // do you unit of work here
    save()
  }
}
catch {
  // There was an error in the operation
}
```

##### Creating a model

You can use the `create()` for initializing and inserting in the context in the same operation:

```swift
do {
  storage.perform(true) { (context, save) throws -> Void in
    let newCar: Car = try! context.create()
    newCar.model = "Honda"
    newCar.mark = "CRZ"
    save()
  }
}
catch {
  // There was an error in the operation
}
```

#### Upsert a model 

Upsert - update or insert first search the entity in storage, and then if it is not found creates it. Just call the `acquire` function.

Important: to get this feature work, you should add model property `pk` and set it to name of the field, that is primary key of this entity. Moreover, this property should be indexed. It is needed to achieve needed level of performance.

```swift
do {
  storage.perform(true) { (context, save) throws -> Void in
    let car: Car = try! context.acquire("CRZ")
  }
}
catch {
  // There was an error in the operation
}
```

##### Delete a model

In a similar way you can use the `remove()` method from the context passing the objects you want to remove from the database:

```swift
do {
  storage.perform(true) { (context, save) throws -> Void in
    let car: Car? = try! context.fetch(Request<Car>.filter("model", equalTo: "CRZ")).first
    if let car = car {
      try! context.remove([car])
      save()
    }
  }
}
catch {
  // There was an error in the operation
}
```

# Contributing

## Support

If you want to communicate any issue, suggestion or even make a contribution, you have to keep in mind the flow bellow:

- If you need help, ask your doubt in Stack Overflow using the tag 'datakernel'
- If you want to ask something in general, use Stack Overflow too.
- Open an issue either when you have an error to report or a feature request.
- If you want to contribute, submit a pull request, and remember the rules to follow related with the code style, testing, ...

## Code of conduct

This project adheres to the [Open Code of Conduct][code-of-conduct]. By participating, you are expected to honor this code.
[code-of-conduct]: http://todogroup.org/opencodeofconduct/#DataKernel/mrdekk@yandex.ru

## License
The MIT License (MIT)

Copyright (c) <2014> <Pedro Piñera>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
