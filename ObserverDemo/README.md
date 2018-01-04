<h1>Design Patterns in Swift: Observer</h1>
This repository is part of a series. For the full list check out <a href="https://shirazian.wordpress.com/2016/04/11/design-patterns-in-swift/">Design Patterns in Swift</a>

For a cheat-sheet of design patterns implemented in Swift check out <a href="https://github.com/ochococo/Design-Patterns-In-Swift"> Design Patterns implemented in Swift: A cheat-sheet</a>

<h3>The problem:</h3>
We have a set of mobile mechanics who are assigned specific zip codes. Each zip code has its own hourly rate. We want to increase and decrease these rates when the number of idle mechanics within a zip code falls or goes above specific thresholds. This way we can proactively set the going rate for each mechanic when demand is high and bring it down when demand is low within a specific zip code.
我们有一组被分配特定邮政编码的移动机构。 每个邮政编码都有自己的小时费率。 当邮政编码中的空闲机制数量下降或超过特定阈值时，我们希望增加和减少这些费率。 通过这种方式，我们可以主动为需求高的每位技工设定工资率，并在特定邮编内的需求低时将其降低。
<h3>The solution:</h3>
We will set up an observer that will monitor the status of each mechanic. This observer will send out notifications to its subscribers when there is a change. Then we will set up a price manager object that will subscribe to our observer and consume its status change notifications. The price manager subscriber  will keep tally of our mechanic supply and when their status is changed it will re-calculate and assign new rates for zip codes if their idle supply falls or goes above specific thresholds.
我们将成立一个观察员来监督每个技工的状态。 当观察者发生变化时，将向用户发送通知。 然后，我们将建立一个价格管理器对象，它将订阅我们的观察者并使用其状态更改通知。 价格经理用户将保留我们的机械供应，当他们的状态改变时，如果他们的空闲供应下降或超过特定的阈值，它将重新计算并分配新的邮政编码。
<!--more-->

Link to the repo for the completed project: <a href="https://github.com/kingreza/Swift-Observer">Swift - Observer</a>

Although there are quite a few examples of the Observer design pattern in iOS (NSNotificationCenter comes to mind) we will be building our own solution from ground up. So this will be a console project (OSX Command line tool). If interested in an <a href="https://www.raywenderlich.com/90773/introducing-ios-design-patterns-in-swift-part-2">iOS focused example click here </a>Also it's worth noting that in the classic definition of the Observer design pattern, the observer itself consumes the event from the subject, for this example we will be delegating that task to another object that we call the 'subscriber'. This is done better encapsulation and separation of responsibility for this specific problem.  
尽管在iOS中有很多Observer设计模式的例子（NSNotificationCenter），我们将从头开始构建我们自己的解决方案。 所以这将是一个控制台项目（OSX命令行工具）。 如果您对<a href="https://www.raywenderlich.com/90773/introducing-ios-design-patterns-in-swift-part-2">关注iOS的示例感兴趣，请点击此处</a>也值得 注意在观察者设计模式的经典定义中，观察者本身从主体中消耗事件，对于这个例子，我们将把这个任务委托给另一个我们称之为“订户”的对象。 对于这个特定的问题，这是更好的封装和责任分离。
Let's begin:

First off lets define our Zipcode object

````swift
import Foundation

class Zipcode{
  let value: String
  var baseRate: Double
  var adjustment: Double
  var rate: Double{
    return baseRate + (baseRate * adjustment)
  }
  init (value: String, baseRate: Double){
    self.value = value
    self.baseRate = baseRate
    self.adjustment = 0.0
  }
}
````

We define a Zipcode to have a value which stands for the general zip code value (94043, 90210 etc). We define a baseRate and adjustment property of types double and define a rate property which is computed from baseRate and adjustments.
我们定义一个Zipcode来代表一般的邮政编码值（94043,90210等）。 我们定义了一个baseRate和类型的调整属性double，并定义了一个从baseRate和调整计算出来的rate属性。

Next we will define our mechanic's status as an enumerable

````swift
import Foundation
enum Status: Int{
  case Idle = 1, OnTheWay, Busy
}
````

We will define three different statuses. Idle, OnTheWay and Busy. Idle is considered available supply whereas OnTheWay and Busy are not.

Now lets define our Mechanic object

````swift
class Mechanic{

  let name: String
  var zipcode: Zipcode

  var status: Status = .Idle

  init(name: String, location: Zipcode){
    self.name = name
    self.zipcode = location
  }
}
````

A mechanic for our case has a name and a zip code which is his/her area of operation. A mechanic also has a status property of type Status which is initialized to Idle
我们案件的机械师有一个名字和一个邮政编码，这是他/她的经营范围。 一个机制也有一个Status类型的status属性，它被初始化为Idle

Next we will define a protocol which our observer will implement.

````swift
import Foundation

protocol Observer: class{
  var subscribers: [Subscriber] {get set}

  func propertyChanged(propertyName: String, oldValue: Int, newValue: Int, options: [String:String]?)

  func subscribe(subscriber: Subscriber)

  func unsubscribe(subscriber: Subscriber)
}
````

Our observer needs to have a propertyChanged method which is called when an observing property is changed. This method will have the name of the property changed, its old and new values along with any other optional values we want to pass in a key-value dictionary.
我们的观察者需要有一个propertyChanged方法，当观察属性被改变时被调用。 此方法将更改属性的名称，旧值和新值以及我们要在键值字典中传递的任何其他可选值。

Now lets define a protocol for our subscribers. This protocol sets all the requirements needed for classes which will subscribe and consume notifications from our observer
现在让我们为我们的用户定义一个协议。 这个协议设置了所有需要的类，这些类将订阅和使用我们观察者的通知

````swift
import Foundation

protocol Subscriber: class{
  var properties : [String] {get set}
  func notify(oldValue: Int, newValue: Int, options: [String:String]?)
}
````

First we define a collection of properties which our subscriber is interested in. Our observer will send its notification to this subscriber when any of the changing properties matches one listed in this collection. For the sake brevity this collection is of type String where the values are simple names of properties. Within more complex systems this collection can be of a well defined property type.
首先我们定义一个我们的用户感兴趣的属性集合。当任何变化的属性与本集合中列出的属性相匹配时，我们的观察者将把它的通知发送给这个用户。 为了简洁起见，这个集合的类型是String，其中的值是属性的简单名称。 在更复杂的系统中，这个集合可以是一个明确定义的属性类型。

We also define a notify function which will be called by our observer along with all relevant values needed to consume its data.
我们还定义了一个通知函数，这个函数将被我们的观察者调用，以及消耗其数据所需的所有相关值。

Next we will define a MechanicObserver which will implement our Observer protocol.

````swift
import Foundation

class MechanicObserver: Observer{

  var subscribers: [Subscriber] = []

  func propertyChanged(propertyName: String, oldValue: Int, newValue: Int, options:[String:String]?){
    print("Change in property detected, notifying subscribers")
    let matchingSubscribers = subscribers.filter({$0.properties.contains(propertyName)})
    matchingSubscribers.forEach({$0.notify(propertyName, oldValue: oldValue, newValue: newValue, options: options)})
  }

  func subscribe(subscriber: Subscriber){
    subscribers.append(subscriber)
  }

  func unsubscribe(subscriber: Subscriber) {
    subscribers = subscribers.filter({$0 !== subscriber})
  }
}
````

The MechanicObserver will have a collection of subscribers with simple methods for adding and removing them from the collection through subscribe and unsubscribe functions.
MechanicObserver将有一个订阅者集合，通过订阅和取消订阅功能，通过简单的方法添加和删除集合。

The most interesting part of our code perhaps starts in the propertyChanged function. Let's go over it line by line

````swift
print("Change in property detected, notifying subscribers")
````

We output a simple message to the console informing the user that a change in property has been detected by the observer.

````swift
let matchingSubscribers = subscribers.filter({$0.properties.contains(propertyName)})
````

Next we will filter out subscribers that are interested on the property that has been modified. As we showed earlier in our subscriber protocol every subscriber has a collection of property names it wishes to be notified about. We find subscribers that match up with the propertyName that has been modified.
接下来，我们将筛选出对已修改的属性感兴趣的订阅者。 正如我们之前在用户协议中所展示的，每个用户都有一系列希望得到通知的属性名称。 我们找到与已修改的propertyName匹配的订阅者。

````swift
matchingSubscribers.forEach({$0.notify(propertyName, oldValue: oldValue, newValue: newValue, options: options)})
````

Next for every subscriber that matched with that property name, we call its notify method with all the data that was passed to the observer.
接下来，对于与该属性名称匹配的每个订阅者，我们将其所有传递给观察者的数据称为其notify方法。

This is pretty much it.

Now that our observer is set up lets change our mechanic model so its status property is observed by our observer.
现在我们的观察者已经建立起来了，让我们改变我们的机械模型，以便观察者观察它的状态属性。

````swift
import Foundation

class Mechanic{

  weak var observer: Observer?

  let name: String
  var zipcode: Zipcode

  var status: Status = .Idle{
    didSet{
      observer?.propertyChanged("Status", oldValue: oldValue.rawValue, newValue: status.rawValue, options: ["Zipcode": zipcode.value])
    }
  }

  init(name: String, location: Zipcode){
    self.name = name
    self.zipcode = location
  }
}
````

We add an observer property to our mechanic. Next we changed the definition of our status property to executes our observer's propertyChange method when its value is set.

in Swift willSet and didSet are used to execute specific code before and after a property is changed. <a href="https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Properties.html">For more info click here</a>.
在Swift中，willSet和didSet用于在属性更改之前和之后执行特定的代码。

We will also include the mechanic's Zipcode in our options collection which will come in handy later.
我们还将在我们的选项集合中包含机械师的Zipcode，稍后将派上用场。

For the last piece of the puzzle we need to implement our subscriber. Since this will get a little more complicated lets appraoch it step by step.

First let's define a ZipcodePriceManager class that will implement our Subscriber protocol.

````swift
import Foundation

class ZipcodePriceManager: Subscriber{
  var properties : [String] = ["Status"]
  var zipcodes: Set<Zipcode>
  var supply: [Zipcode: Int] = [:]

  init(zipcodes: Set<Zipcode>, supply: [Zipcode: Int]){
    self.zipcodes = zipcodes
    self.supply = supply
  }
 func notify(propertyName: String, oldValue: Int, newValue: Int, options: [String:String]?){}
````

In our definition we can see that ZipcodePriceManager implements subscriber, it defines a properties collection that is initialized to an array which holds one value "Status". Since this class only needs the mechanic's Status to determine zip code's rates we will only monitor that property. (It is also the case we are not observing any other property in our Mechanic's class, however extending the observer to monitor more properties and our subscribers to consume a more diverse set of properties is a trivial process.)
在我们的定义中，我们可以看到ZipcodePriceManager实现了订阅者，它定义了一个属性集合，它被初始化为一个包含一个“Status”值的数组。由于这个类只需要机械师的状态来确定邮政编码的费率，我们只会监视这个属性。 （同样的情况是，我们并没有观察机械师课程中的其他任何属性，但是扩展观察者来监控更多的属性，而我们的用户使用更多元化的属性是一个微不足道的过程。）

Our ZipcodePriceManager also has two properties that are not part of the subscriber protocol: zipcodes and supply. Since our zipcodes will be all unique values and since we don't care about their order, we will define it as a Set type.
我们的ZipcodePriceManager还有两个不属于用户协议的属性：邮政编码和供应。由于我们的邮编将是唯一的价值，因为我们不关心他们的顺序，我们将它定义为一个集合类型。

We will also define our supply as a dictionary of key Zipcodes and value Ints. Our unique Zipcodes behaves as a key and the Int value will be the available idle mechanics for that Zipcode. The initial values for these properties will be set by its initializer.
我们还将定义我们的供应作为关键ZipCodes和价值Ints字典。我们独特的邮政编码行为作为一个关键和Int值将是该Zipcode可用的闲置机制。这些属性的初始值将由其初始值设定。

When we define our supply this way, Swift will complain about our Zipcode object. The problem is that our Zipcode object does not implement Hashable and Equatable. Since we are using a Zipcode instance as a key within a dictionary, Swift needs a way to derive a unique value from it. This is something we need to provide Swift. This can be achieved by implementing the Hashable protocol which will require us to add a hashValue property which must return a unique integer. We also need to implement the Equatable protocol which Hashable inherits from. Equatable tells Swift how two Zipcode are equal. This is a requirement for any object that implements the Hashable protocol.
当我们以这种方式定义我们的供应时，Swift会抱怨我们的Zipcode对象。问题是我们的Zipcode对象没有实现Hashable和Equatable。由于我们使用Zipcode实例作为字典中的一个键，所以Swift需要一种方法来从它中派生一个唯一的值。这是我们需要提供Swift的东西。这可以通过实现Hashable协议来实现，该协议要求我们添加一个hashValue属性，该属性必须返回一个唯一的整数。我们还需要实现Hashable继承的Equatable协议。 Equatable告诉Swift两个Zipcode是如何相等的。这是实现Hashable协议的任何对象的要求。

So we change our Zipcode class to be:

````swift

import Foundation

class Zipcode: Hashable, Equatable{
  ......

  var hashValue: Int{
    return value.hashValue
  }

}

func == (lhs: Zipcode, rhs: Zipcode) -> Bool {
  return lhs.value == rhs.value
}
````

We added a hashValue function that returns an Int. Since our Zipcode value will be unique for each Zipcode and since String already implements Hashable we can return our Zipcode's value.hashValue.
我们添加了一个返回一个Int的hashValue函数。 由于我们的Zipcode值对于每个Zipcode都是唯一的，而且由于String已经实现了Hashable，我们可以返回我们的Zipcode的值.hashValue。

we also define == operator for Zipcode to compare Zipcode's value for equality. This will make our Zipcode class conform to the Equatable protocol. Note that this is done outside out of Zipcode's class definition. More info on <a href="https://developer.apple.com/library/watchos/documentation/Swift/Reference/Swift_Hashable_Protocol/index.html">Hashable</a> and <a href="https://developer.apple.com/library/watchos/documentation/Swift/Reference/Swift_Equatable_Protocol/index.html">Equatable</a>
我们还为Zipcode定义==运算符来比较Zipcode的值是否相等。 这将使我们的Zipcode类符合Equatable协议。 请注意，这是在Zipcode的类定义之外完成的。

Alright let's get back to our ZipcodePriceManager. Next we will implement our notify function. We want our ZipcodePriceManager subscriber to consumer its notifications so that every change to a mechanic's status will increase and decrease the zipcode number of supply.
好吧，让我们回到我们的ZipcodePriceManager。 接下来我们将实现我们的通知功能。 我们希望我们的ZipcodePriceManager订阅者使用它的通知，以便对技工状态的每次更改都会增加和减少邮政编码。

````swift
  func notify(propertyName: String, oldValue: Int, newValue: Int, options: [String:String]?){
    if properties.contains(propertyName){
       print("\(propertyName) is changed from \(Status(rawValue: oldValue)!) to \(Status(rawValue: newValue)!)")
      if propertyName == "Status"{
        if let options = options{
          let zipcode = zipcodes.filter({$0.value == options["Zipcode"]}).first
          if let zipcode = zipcode{
            if (Status(rawValue: newValue) == Status.Idle && Status(rawValue: oldValue) != Status.Idle){
              supply[zipcode]! += 1
            }else if (Status(rawValue: newValue) != Status.Idle && Status(rawValue: oldValue) == Status.Idle){
              supply[zipcode]! -= 1
            }
            updateRates()
            print("**********************")
          }
        }
      }
    }
  }
````

So let's break this down
所以我们来分解一下

First we check to make sure the property being changed is included in the list of properties our subscriber is interested in:
首先我们检查以确保被更改的属性包含在我们的订户感兴趣的房产清单中:
````swift
if properties.contains(propertyName){
````

Next we prompt the user that our subscriber has been notified that a property it is interested in has changed:
接下来我们提示用户，我们的用户已经被通知了它感兴趣的房产已经改变了：
````swift
  print("\(propertyName) is changed from \(Status(rawValue: oldValue)!) to \(Status(rawValue: newValue)!)")
````

Next we check to see if the property changed is "Status". If so unwrap its options and find the Zipcode that was passed from the Mechanic.
接下来我们检查一下，看看这个属性是否是“状态”。 如果这样解开它的选项，并找到从技工传递的邮编。

````swift
  if propertyName == "Status"{
        if let options = options{
          let zipcode = zipcodes.filter({$0.value == options["Zipcode"]}).first
````

if the Zipcode was found, change its supply. If the status is from idle to anything this means an idle mechanic has become busy, then we decrease its value in the supply dictionary. Conversely if the change is from anything else to idle, it means a busy mechanic has become idle so we increase our supply:
如果找到Zipcode，请更改其供应。 如果状态从闲置到任何事物，这意味着闲置的机制变得忙碌，那么我们在供应词典中减少它的价值。 相反，如果变化是从其他任何东西闲置，这意味着一个繁忙的机制已经成为闲置，所以我们增加了我们的供应：

````swift
 if let zipcode = zipcode{
   if (Status(rawValue: newValue) == Status.Idle && Status(rawValue: oldValue) != Status.Idle){
     supply[zipcode]! += 1
   }else if (Status(rawValue: newValue) != Status.Idle && Status(rawValue: oldValue) == Status.Idle){
     supply[zipcode]! -= 1
}
````

Finally we call an updateRate function which will update our Zipcode rates according to the new supplies:

````swift
updateRates()
print("**********************")
````

Here is the definition for updateRates() which recalculates and reassigns adjustment ratios to our Zipcodes:

````swift
  func updateRates(){
    supply.forEach({(zipcode: Zipcode, supply: Int) in
      if (supply <= 1){
        zipcode.adjustment = 0.50
        print("Very High Demand! Adjusting price for \(zipcode.value): rate is now \(zipcode.rate) because supply is \(supply)")
      }else if (supply <= 3){
        zipcode.adjustment = 0.25
        print("High Demand! Adjusting price for \(zipcode.value): rate is now \(zipcode.rate) because supply is \(supply)")
      }else{
        zipcode.adjustment = 0.0
        print("Normal Demand. Adjusting price for \(zipcode.value): rate is now \(zipcode.rate) because supply is \(supply)")
      }
    })
  }
````

There isn't much here that's related to our Observer design pattern so I'll let you go over it and figure it out.

So when we put it all together, our ZipcodePriceManager ends up looking like this:

````swift
import Foundation

class ZipcodePriceManager: Subscriber{
  var properties : [String] = ["Status"]
  var zipcodes: Set<Zipcode>
  var supply: [Zipcode: Int] = [:]

  init(zipcodes: Set<Zipcode>, supply: [Zipcode: Int]){
    self.zipcodes = zipcodes
    self.supply = supply
  }

  func notify(propertyName: String, oldValue: Int, newValue: Int, options: [String:String]?){
    if properties.contains(propertyName){
       print("\(propertyName) is changed from \(Status(rawValue: oldValue)!) to \(Status(rawValue: newValue)!)")
      if propertyName == "Status"{
        if let options = options{
          let zipcode = zipcodes.filter({$0.value == options["Zipcode"]}).first
          if let zipcode = zipcode{
            if (Status(rawValue: newValue) == Status.Idle && Status(rawValue: oldValue) != Status.Idle){
              supply[zipcode]! += 1
            }else if (Status(rawValue: newValue) != Status.Idle && Status(rawValue: oldValue) == Status.Idle){
              supply[zipcode]! -= 1
            }
            updateRates()
            print("**********************")
          }
        }
      }
    }
  }

  func updateRates(){
    supply.forEach({(zipcode: Zipcode, supply: Int) in
      if (supply <= 1){
        zipcode.adjustment = 0.50
        print("Very High Demand! Adjusting price for \(zipcode.value): rate is now \(zipcode.rate) because supply is \(supply)")
      }else if (supply <= 3){
        zipcode.adjustment = 0.25
        print("High Demand! Adjusting price for \(zipcode.value): rate is now \(zipcode.rate) because supply is \(supply)")
      }else{
        zipcode.adjustment = 0.0
        print("Normal Demand. Adjusting price for \(zipcode.value): rate is now \(zipcode.rate) because supply is \(supply)")
      }
    })
  }
}
````

It's important to note that our ZipcodePriceManager knows nothing about our Mechanics, and our Mechanics know nothing about ZipcodePriceManager, Supplies or the collection of our serving zip codes. Also our MechanicObserver, although named MechanicObserver has no reference to a Mechanic.
需要注意的是，我们的ZipcodePriceManager对我们的机制一无所知，而我们的机制对ZipcodePriceManager，Supplies或我们的服务邮政编码一无所知。 另外我们的MechanicObserver，虽然名为MechanicObserver没有提及一个Mechanic。

Lets define our Main function and test it out

````swift

import Foundation

var mountainView = Zipcode(value: "94043", baseRate: 40.00)
var redwoodCity = Zipcode(value: "94063", baseRate: 30.00)
var paloAlto = Zipcode(value: "94301", baseRate: 50.00)
var sunnyvale = Zipcode(value: "94086", baseRate: 35.00)

var zipcodes : Set<Zipcode> = [mountainView, redwoodCity, paloAlto, sunnyvale]

var steve = Mechanic(name: "Steve Akio", location: mountainView)
var joe = Mechanic(name: "Joe Jackson", location: redwoodCity)
var jack = Mechanic(name: "Jack Joesph", location: redwoodCity)
var john = Mechanic(name: "John Foo", location: paloAlto)
var trevor = Mechanic(name: "Trevor Simpson", location: sunnyvale)
var brian = Mechanic(name: "Brian Michaels", location: sunnyvale)
var tom = Mechanic(name: "Tom Lee", location: sunnyvale)
var mike = Mechanic(name: "Mike Cambell", location: mountainView)
var jane = Mechanic(name: "Jane Sander", location: mountainView)
var ali = Mechanic(name: "Ali Ham", location: paloAlto)
var sam = Mechanic(name: "Sam Fox", location: mountainView)
var reza = Mechanic(name: "Reza Shirazian", location: mountainView)
var max = Mechanic(name: "Max Watson", location: sunnyvale)
var raj = Mechanic(name: "Raj Sundeep", location: sunnyvale)
var bob = Mechanic(name: "Bob Anderson", location: mountainView)

var mechanics = [steve, joe, jack, john, trevor, brian, tom, mike, jane, ali, sam, reza, max, raj, bob]

var supply: [Zipcode: Int] = [:]

zipcodes.forEach({(zipcode: Zipcode) in supply[zipcode] = mechanics.filter({(mechanic:Mechanic) in mechanic.status == Status.Idle && mechanic.zipcode === zipcode}).count})

var priceManager = ZipcodePriceManager(zipcodes: zipcodes, supply: supply)

let observer = MechanicObserver()

observer.subscribe(priceManager)

mechanics.forEach({$0.observer = observer})

john.status = .OnTheWay
steve.status = .OnTheWay
steve.status = .Busy
steve.status = .Idle
trevor.status = .OnTheWay
brian.status = .OnTheWay
tom.status = .OnTheWay
reza.status = .OnTheWay
tom.status = .Busy
raj.status = .OnTheWay

observer.unsubscribe(priceManager)
print("unsubscribed")

raj.status = .Idle
````

Alright that was a lot, so lets break it down and go step by step. First off we set our Zipcodes:

````swift
var mountainView = Zipcode(value: "94043", baseRate: 40.00)
var redwoodCity = Zipcode(value: "94063", baseRate: 30.00)
var paloAlto = Zipcode(value: "94301", baseRate: 50.00)
var sunnyvale = Zipcode(value: "94086", baseRate: 35.00)

var zipcodes : Set<Zipcode> = [mountainView, redwoodCity, paloAlto, sunnyvale]
````

Next we set our Mechanics:

````swift
var steve = Mechanic(name: "Steve Akio", location: mountainView)
var joe = Mechanic(name: "Joe Jackson", location: redwoodCity)
var jack = Mechanic(name: "Jack Joesph", location: redwoodCity)
var john = Mechanic(name: "John Foo", location: paloAlto)
var trevor = Mechanic(name: "Trevor Simpson", location: sunnyvale)
var brian = Mechanic(name: "Brian Michaels", location: sunnyvale)
var tom = Mechanic(name: "Tom Lee", location: sunnyvale)
var mike = Mechanic(name: "Mike Cambell", location: mountainView)
var jane = Mechanic(name: "Jane Sander", location: mountainView)
var ali = Mechanic(name: "Ali Ham", location: paloAlto)
var sam = Mechanic(name: "Sam Fox", location: mountainView)
var reza = Mechanic(name: "Reza Shirazian", location: mountainView)
var max = Mechanic(name: "Max Watson", location: sunnyvale)
var raj = Mechanic(name: "Raj Sundeep", location: sunnyvale)
var bob = Mechanic(name: "Bob Anderson", location: mountainView)

var mechanics = [steve, joe, jack, john, trevor, brian, tom, mike, jane, ali, sam, reza, max, raj, bob]
````

Next we calculate our supply dictionary and setting up our ZipcodePriceManager subscriber. The code for the initial supply calculation might seem a bit complicated but it's just the count of all mechanics that have their status set to idle for each zipcode. Play around with it a bit if you're new to closures.

````swift
var supply: [Zipcode: Int] = [:]

zipcodes.forEach({(zipcode: Zipcode) in supply[zipcode] = mechanics.filter({(mechanic:Mechanic) in mechanic.status == Status.Idle && mechanic.zipcode === zipcode}).count})

var priceManager = ZipcodePriceManager(zipcodes: zipcodes, supply: supply)
````

Next we set up our observer, have our ZipcodePriceManager subscribe to it and have our observer observe all our mechanics:

````swift
let observer = MechanicObserver()

observer.subscribe(priceManager)

mechanics.forEach({$0.observer = observer})
````

Now everything is setup. Let's get our mechanics to work and see how our zipcode rates change as supplies go up and down

````swift
john.status = .OnTheWay
steve.status = .OnTheWay
steve.status = .Busy
steve.status = .Idle
trevor.status = .OnTheWay
brian.status = .OnTheWay
tom.status = .OnTheWay
reza.status = .OnTheWay
tom.status = .Busy
raj.status = .OnTheWay
````

Note that all we are doing is changing our mechanic's status. We don't call anything else. All of our changes to supply and rates for our zipcodes are taken care of by our observer and subscriber.

As for one last test we unsubscribe our ZipcodePriceManager from the observer and see what happens when we change a mechanic's status:

````swift
observer.unsubscribe(priceManager)
print("unsubscribed")

raj.status = .Idle
````

The output we get to the console when we run all of this is:

````swift
Change in property detected, notifying subscribers
Status is changed from Idle to OnTheWay
Normal Demand. Adjusting price for 94043: rate is now 40.0 because supply is 6
High Demand! Adjusting price for 94063: rate is now 37.5 because supply is 2
Normal Demand. Adjusting price for 94086: rate is now 35.0 because supply is 5
Very High Demand! Adjusting price for 94301: rate is now 75.0 because supply is 1
**********************
Change in property detected, notifying subscribers
Status is changed from Idle to OnTheWay
Normal Demand. Adjusting price for 94043: rate is now 40.0 because supply is 5
High Demand! Adjusting price for 94063: rate is now 37.5 because supply is 2
Normal Demand. Adjusting price for 94086: rate is now 35.0 because supply is 5
Very High Demand! Adjusting price for 94301: rate is now 75.0 because supply is 1
**********************
Change in property detected, notifying subscribers
Status is changed from OnTheWay to Busy
Normal Demand. Adjusting price for 94043: rate is now 40.0 because supply is 5
High Demand! Adjusting price for 94063: rate is now 37.5 because supply is 2
Normal Demand. Adjusting price for 94086: rate is now 35.0 because supply is 5
Very High Demand! Adjusting price for 94301: rate is now 75.0 because supply is 1
**********************
Change in property detected, notifying subscribers
Status is changed from Busy to Idle
Normal Demand. Adjusting price for 94043: rate is now 40.0 because supply is 6
High Demand! Adjusting price for 94063: rate is now 37.5 because supply is 2
Normal Demand. Adjusting price for 94086: rate is now 35.0 because supply is 5
Very High Demand! Adjusting price for 94301: rate is now 75.0 because supply is 1
**********************
Change in property detected, notifying subscribers
Status is changed from Idle to OnTheWay
Normal Demand. Adjusting price for 94043: rate is now 40.0 because supply is 6
High Demand! Adjusting price for 94063: rate is now 37.5 because supply is 2
Normal Demand. Adjusting price for 94086: rate is now 35.0 because supply is 4
Very High Demand! Adjusting price for 94301: rate is now 75.0 because supply is 1
**********************
Change in property detected, notifying subscribers
Status is changed from Idle to OnTheWay
Normal Demand. Adjusting price for 94043: rate is now 40.0 because supply is 6
High Demand! Adjusting price for 94063: rate is now 37.5 because supply is 2
High Demand! Adjusting price for 94086: rate is now 43.75 because supply is 3
Very High Demand! Adjusting price for 94301: rate is now 75.0 because supply is 1
**********************
Change in property detected, notifying subscribers
Status is changed from Idle to OnTheWay
Normal Demand. Adjusting price for 94043: rate is now 40.0 because supply is 6
High Demand! Adjusting price for 94063: rate is now 37.5 because supply is 2
High Demand! Adjusting price for 94086: rate is now 43.75 because supply is 2
Very High Demand! Adjusting price for 94301: rate is now 75.0 because supply is 1
**********************
Change in property detected, notifying subscribers
Status is changed from Idle to OnTheWay
Normal Demand. Adjusting price for 94043: rate is now 40.0 because supply is 5
High Demand! Adjusting price for 94063: rate is now 37.5 because supply is 2
High Demand! Adjusting price for 94086: rate is now 43.75 because supply is 2
Very High Demand! Adjusting price for 94301: rate is now 75.0 because supply is 1
**********************
Change in property detected, notifying subscribers
Status is changed from OnTheWay to Busy
Normal Demand. Adjusting price for 94043: rate is now 40.0 because supply is 5
High Demand! Adjusting price for 94063: rate is now 37.5 because supply is 2
High Demand! Adjusting price for 94086: rate is now 43.75 because supply is 2
Very High Demand! Adjusting price for 94301: rate is now 75.0 because supply is 1
**********************
Change in property detected, notifying subscribers
Status is changed from Idle to OnTheWay
Normal Demand. Adjusting price for 94043: rate is now 40.0 because supply is 5
High Demand! Adjusting price for 94063: rate is now 37.5 because supply is 2
Very High Demand! Adjusting price for 94086: rate is now 52.5 because supply is 1
Very High Demand! Adjusting price for 94301: rate is now 75.0 because supply is 1
**********************
unsubscribed
Change in property detected, notifying subscribers
Program ended with exit code: 0
````

As you can see our observer correctly detects changes to mechanic's status, it correctly sends its notifications to its subscribers. Our ZipcodePriceManager subscriber correctly consumes the notifications and sets the prices for each zip code accordingly.

Congratulations you have just implemented the Observer Design Pattern to solve a nontrivial problem. 

The repo for the complete project can be found here: <a href="https://github.com/kingreza/Swift-Observer">Swift - Observer.</a> 

Download a copy of it and play around with it. See if you can find ways to improve its performance, observer more properties and expand on it anyway you like. Here are some suggestions on how to expand or improve on the project:

<ul>
  <li>What if a mechanic can server multiple zipcodes</li>
  <li>How can we improve the updateRates() function</li>
  <li>How can we add and observe other properties like hoursWorked for overtime calculation, location for when a mechanic is close to a job's location and so on...</li>
</ul>
