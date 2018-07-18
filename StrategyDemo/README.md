<h1>Design Patterns: Strategy 策略</h1>
The strategy pattern is used to create an interchangeable family of algorithms from which the required process is chosen at run-time.
策略模式用于创建可互换的算法族，在运行时从中选择所需的过程。

This repository is part of a series. For the full list check out <a href="https://shirazian.wordpress.com/2016/04/11/design-patterns-in-swift/">Design Patterns in Swift</a>

For a cheat-sheet of design patterns implemented in Swift check out <a href="https://github.com/ochococo/Design-Patterns-In-Swift"> Design Patterns implemented in Swift: A cheat-sheet</a>

<h3>The problem:</h3>

We order our parts from three different vendors. Each vendor has its own system for fulfilling parts orders.
我们从三个不同的供应商那里订购部件。 每个供应商都有自己的履行零件订单的系统。
<ol>
  <li>ACME Parts Co which provides parts for domestic cars requires authorization from our parts supervisor before it can finalize any orders.为家用汽车提供零件的ACME零件公司需要我们的零件主管授权才能完成任何订单。</li>
  <li>PartsNStuff which provides parts for asians cars provides us with reseller discounts and requires each mechanic to provide their designated ID before finalizing orders.为亚洲人汽车提供零件的PartsNStuff为我们提供经销商折扣，并要求每位技工在完成订单之前提供其指定的ID。</li>
  <li>AutoPart Co which provides parts for European cars, as part of their state of the art secure ordering,  sends us a number that we have to return true if even and false if odd before they can fulfill our orders.为欧洲汽车提供零部件的AutoPart Co，作为他们最先进的安全订购的一部分，向我们发送了一个数字，如果它们能够完成我们的订单，如果有的话甚至是假的，我们都必须返回true。</li>
</ol>
We need a system that can fulfil mechanic's order from all our vendors.

<h3>The solution:</h3>
We need three different strategies for placing an order. We will solve this problem by implementing an OrderManager that will receives an order and decides which strategy to use to fulfil it. We will then implement three different strategies, each for fulfilling an order with a specific vendor. 
我们需要三种不同的策略来下订单。 我们将通过实施一个订单管理器来解决这个问题，订单管理器将接收订单并决定使用哪种策略来完成订单。 然后，我们将实施三个不同的策略，每个策略用于与特定供应商完成订单。
<!--more-->

Link to the repo for the completed project: <a href="https://github.com/kingreza/Swift-Strategy"> Swift - Strategy </a>

Because of various requirements needed to complete an order for each vendor, this solution has quite a few supporting classes that in many ways simulate the needed functionalities to match the requirements for each specific strategy. Since things can get easily out of hand when dealing with three different strategies, we will skip going over these supporting classes and only mention their function signatures. Many of them are supposed to simulate API calls and other utility like functions that are outside the scope of this project. If you are interested in how they work the code for them is included in the repo.
由于完成每个供应商的订单所需的各种要求，该解决方案具有相当多的支持类，以多种方式模拟所需的功能以匹配每个特定策略的需求。 由于在处理三种不同的策略时，事情可能很容易失控，所以我们将跳过这些支持类，只提及它们的功能签名。 他们中的许多人应该模拟API调用和其他实用程序，如在本项目范围之外的功能。 如果您对自己的工作方式感兴趣，那么他们的代码将包含在回购中。

Lets begin by defining what we will use throughout all three strategies. 

````swift

struct Part {}

enum CarType: Int {}

class Order: Hashable, Equatable {}

func == (lhs: Order, rhs: Order) -> Bool {
  return lhs.orderId == rhs.orderId
}

struct Mechanic: Hashable, Equatable {}

func == (lhs: Mechanic, rhs: Mechanic) -> Bool {
  return lhs.mechanicId == rhs.mechanicId
}

````

We start by defining our parts object. This will be a simple struct with a name and a price. We set these values in its initializer. We then define an enumerable that we will use to distinguish different car types. When then define an order. Order will implement Hashable and Equitable so we can use it in a Set. This is somewhat outside the scope of this article but if you want to define a Set using custom made classes they need to implement these protocols so Swift would know what makes them equal and what makes them different. If you're not familiar with Hashable and Equatable I suggest you <a href="http://nshipster.com/swift-comparison-protocols/">review this</a>.
我们从定义零件对象开始。这将是一个具有名称和价格的简单结构。我们在初始化程序中设置这些值。然后我们定义一个枚举，我们将用它来区分不同的车型。当然后定义一个订单。 Order将实现Hashable和Equitable，所以我们可以在Set中使用它。这有点超出了本文的范围，但是如果你想定义一个使用自定义类的Set，他们需要实现这些协议，所以Swift会知道什么使得它们相等，什么使它们不同。

Our order object will have a unique id, a list of parts, a car type and a fulfilled flag. We set these values in its initializer and have it conform to the equitable and hashable protocol by adding the hashValue function and providing a == definition for the class.
我们的订单对象将有一个唯一的ID，一个零件清单，一个车型和一个满足的标志。我们在初始化程序中设置这些值，并通过添加hashValue函数并为该类提供一个==定义来使其符合公平和可哈希协议。

We then define a Mechanic's class with a unique mechanic Id and name, and have it implement Hashable and Equatable.
然后我们用一个独特的机械ID和名称来定义一个Mechanic的类，并且实现Hashable和Equatable。

We now have our general building blocks. But before we get into the Strategy Design Pattern, let's define what it means to be a Strategy, more specifically an Order Strategy:
我们现在有我们的一般积木。但在进入战略设计模式之前，让我们来定义一个策略，更具体地说是一个订单策略:

````swift
protocol OrderStrategy {
  func fulfillOrder(order: Order) -> Bool
}
````

The one thing that all three strategies must have in common is their ability to fulfill an order. How they do it is none of our concern right now, we just want to make sure they can perform this task and return a boolean indicating success or failure. In a more complicated system, we probably would want to define a return value with more details, but to keep it simple we will settle for a boolean flag. 
所有三个策略必须共同的一件事就是他们有能力履行一个命令。 他们如何做是我们现在不关心的事情，我们只是想确保他们能够执行这个任务，并返回一个表示成功或失败的布尔值。 在一个更复杂的系统中，我们可能想要定义一个更多细节的返回值，但为了简单起见，我们将解决一个布尔标志。

Let's start building our Strategy pattern by looking at our first vendor.
看看我们的第一家供应商，开始构建我们的战略模式。

<em>ACME Parts Co which provides parts for domestic cars requires authorization from our parts supervisor before it can finalize any orders.为家用汽车提供零件的ACME零件公司需要我们的零件主管授权才能完成任何订单。</em>

We also know the API provided by our ACME partners. 我们也知道我们的ACME合作伙伴提供的API。

````swift

func addToApprovedOrder(order: Order, partsSupervisorSignature: Int) -> Bool

func fulfillOrder(order: Order) -> Bool

````

Before ACME fulfills an order, the order needs to be added to its approved orders. For it to be approved it needs to supply a signature by our Part supervisor. Thankfully, our part supervisor has also provided us with an API that we can use to get her signature for our orders.
在ACME完成订单之前，需要将订单添加到批准的订单中。 要获得批准，需要由我们的部门主管提供签名。 值得庆幸的是，我们的部分主管也向我们提供了一个API，我们可以用它来签署我们的订单。

````swift

 func getSupervisorSignatureOnOrder(order: Order) -> Int

````


I believe we have everything we need to begin coding our first Strategy.

Let's begin:

````swift
class ACMEStrategy: OrderStrategy {}
````

ACMEStrategy implements our OrderStrategy protocol. We begin by getting a signature from our PartSupervisor API. We pass our order and get an integer back. This integer acts as a signature that the ACME API will have to verify. Hypothetically we do not have access to the inner workings of these APIs and we really couldn't care less. We are just following the steps required to fulfill our order. (If interested you can find how the signature process works by viewing the PartsSupervisor and ACME singletons in the completed repo: <a href="https://github.com/kingreza/Swift-Strategy"> Swift - Strategy </a>)
ACMEStrategy实现我们的OrderStrategy协议。我们从PartSupervisor API获取签名。我们通过我们的订单，并返回一个整数。这个整数作为ACME API必须验证的签名。假设我们不能访问这些API的内部工作，我们真的不在乎。我们只是遵循完成我们的订单所需的步骤。

Once we have the signature we pass it to ACME with the order, if it is added to the approved orders we then ask ACME to fulfill it. If the order is fulfilled and a true value is returned by ACME we set the ordered to fulfilled and return true.
一旦我们有了签名，我们就把它传递给ACME，如果把它添加到批准的订单中，我们就要求ACME完成它。如果订单满足并且ACME返回一个真实价值，我们将订单设置为履行并返回true。

And just like that we are done with our first vendor and our first strategy.

Lets look at our next vendor:

<em>PartsNStuff which provides parts for asians cars provides us with reseller discounts and requires each mechanic to provide their designated ID before finalizing orders. 为亚洲人汽车提供零件的PartsNStuff为我们提供经销商折扣，并要求每位技工在完成订单之前提供其指定的ID</em>

We also know the following API is provided by PartsNStuff

````swift

func addApprovedMechanic(mechanicId: Int)

func fulfillOrder(order: Order, mechanicId: Int) -> Bool

````

We also know that internally we have a library that can provide us with the mechanic id associated with each order. This is needed if we want to fulfill an order through PartsNStuff.
我们也知道，在内部，我们有一个图书馆，可以为我们提供与每个订单相关的机制ID。 如果我们想通过PartsNStuff完成订单，这是必需的.

````swift

func getMechanicIdFromOrderId(orderId: Int) -> Int?

````

We have everything we need to build our PartsNStuff strategy. So let's do it

````swift
class PartsNStuffStrategy: OrderStrategy {}

````

Like ACME, PartsNStuffStrategy implements OrderStrategy. In our fulfill order function we first get the mechanic id associated with the order by calling our MechanicOrderDataProvider. Again this is some API that can provide us with the mechanic id that is associated with an order. If you're interested in its inner working, take a look at the repo:  <a href="https://github.com/kingreza/Swift-Strategy"> Swift - Strategy </a>
像ACME一样，PartsNStuffStrategy实现OrderStrategy。 在我们的履行顺序函数中，我们首先通过调用我们的MechanicOrderDataProvider获得与顺序相关的机制id。 再次，这是一些API，可以为我们提供与订单相关的机制ID。

If a mechanic id is returned we send the order and the mechanic id through the fulfillOrder API provided by PartsNStuff. If the mechanic id is in their list of approved mechanics they fulfill the order and return with a true value. If not, a false value is returned and our strategy informs the user by printing the error message to the console.
如果返回一个技工ID，我们通过PartsNStuff提供的fulfillOrder API发送订单和机械ID。 如果机械师ID在他们的核准机制列表中，他们履行订单并返回一个真正的价值。 如果不是，则返回一个错误的值，我们的策略通过将错误消息打印到控制台来通知用户。

Two down, one more to go:

<em>AutoPart Co which provides parts for European cars, as part of their state of the art secure ordering,  sends us a number that we have to return true if even and false if odd before they can fulfill our orders. 为欧洲汽车提供零部件的AutoPart Co，作为他们最先进的安全订购的一部分，向我们发送了一个数字，如果它们能够完成我们的订单，如果有的话甚至是假的，我们都必须返回true。</em>

We also know that AutoPart provides the following API

````swift
func getVerifyingNumber() -> Int

func authenticateOrder(order: Order, response: Bool) -> Bool

func fulfillOrder(order: Order) -> Bool 
````

Thankfully we don't need any extra calls to figure out if a number is even or odd, we can do that in the orderStrategy itself.

````swift
class AutoPartsStrategy: OrderStrategy {}
````

Like our other strategies our AutoPartStrategy also implements OrderStrategy. We begin by getting the number that's needed to be verified from AutoPartStrategy. Once the number is received we send in the order along with the result of it being even or odd. If the order is authenticated then we ask AutoPart to fulfill it. If everything goes correctly we mark the order as fulfilled and return true. Otherwise we print out why the process failed and return false.
像我们的其他策略一样，我们的AutoPartStrategy也实现了OrderStrategy。 我们首先从AutoPartStrategy获取需要验证的数字。 一旦收到号码，我们会按顺序发送，其结果是偶数或奇数。 如果订单被认证，那么我们要求自动部件完成它。 如果一切正常，我们将该命令标记为已完成并返回true。 否则，我们打印出为什么进程失败并返回false。


We have all three strategies implemented and ready. 

Now we define an Order Manager object, responsible for calling the correct strategy depending on the car type associated with each order. The OrderManager will also hide away the complexity of each strategy from us and presents us with a simple fulfill order interface.
现在我们定义一个订单管理器对象，负责根据与每个订单相关的汽车类型调用正确的策略。 OrderManager也将隐藏我们每个策略的复杂性，并呈现给我们一个简单的履行顺序界面。

````swift
class OrderManager {}
````

We create an instance of each strategy and initialize them in our OrderManager initializer. Next  we delegate the task of fulfilling an order to the correct strategy based on the car type associated with the order.
我们创建每个策略的一个实例，并在OrderManager初始化器中初始化它们。 接下来，我们将执行订单的任务委托给基于与订单相关的汽车类型的正确策略。

Let's test this out. Here is our main setup and with some test cases. 

````swift


var joe = Mechanic(mechanicId: 6653, name: "Joe Stevenson")
var mike = Mechanic(mechanicId: 7785, name: "Mike Rove")
var sam = Mechanic(mechanicId: 5421, name: "Sam Warren")
var tom = Mechanic(mechanicId: 99, name: "Tom Tanner")

PartsNStuff.instance.addApprovedMechanic(joe.mechanicId)

var order1 = OrderManager.instance.generateOrderForMechanic(
              joe,
              parts: [Part(name: "Brake pads", price: 15.22),
                      Part(name: "Brake Fluid", price: 18.99)],
              carType: .Asian)

var order2 = OrderManager.instance.generateOrderForMechanic(
               mike,
               parts: [Part(name: "5 qt Synthetic Oil", price: 15.99),
                       Part(name: "Standard Filters", price: 8.49)],
               carType: .European)

var order3 =  OrderManager.instance.generateOrderForMechanic(
               sam,
               parts: [Part(name: "Engine Coolant", price: 18.99)],
               carType: .Domestic)


OrderManager.instance.fulfillOrder(order1)
OrderManager.instance.fulfillOrder(order2)
OrderManager.instance.fulfillOrder(order3)

````

First we setup our mechanics. For this test we define four mechanics: Joe, Mike, Sam and Tom. Next we add Joe to PartsNStuff list of approved mechanics. This way any order associated with him will be approved through the PartsNStuff API. Next we generate some orders. It seems natural to have the process for generating orders take place in our OrderManager class. So let's add a generateOrderForMechanic in it. Here is how our OrderManager class after our new additions.
首先我们设置我们的机制。 对于这个测试，我们定义了四个机制：Joe，Mike，Sam和Tom。 接下来，我们将Joe添加到PartsNStuff批准的机制列表中。 这样，任何与他相关的订单都将通过PartsNStuff API批准。 接下来我们生成一些命令。 生成订单的过程发生在我们的OrderManager类中似乎很自然。 所以让我们在其中添加一个generateOrderForMechanic。 以下是我们的新增功能后的OrderManager类。

````swift
class OrderManager {
  static var instance = OrderManager()
  private var acmeStrategy: OrderStrategy
  private var partsnstuffStrategy: OrderStrategy
  private var autopartsStrategy: OrderStrategy
  private var currentOrderId: Int

  private init() {
    self.acmeStrategy = ACMEStrategy()
    self.partsnstuffStrategy = PartsNStuffStrategy()
    self.autopartsStrategy = AutoPartsStrategy()
    self.currentOrderId = 1558
  }

  func generateOrderForMechanic(mechanic: Mechanic, parts: [Part], carType: CarType) -> Order {
    let orderId = currentOrderId + 1
    let order = Order(orderId: orderId, parts: parts, carType: carType)
    MechanicOrderDataProvider.instace.addMechanicOrder(order, mechanic: mechanic)
    currentOrderId = orderId
    return order
  }

  func fulfillOrder(order: Order) -> Bool {
    switch order.carType {
    case .Domestic:
      return acmeStrategy.fulfillOrder(order)
    case .Asian:
      return partsnstuffStrategy.fulfillOrder(order)
    case .European:
      return autopartsStrategy.fulfillOrder(order)

    }
  }
}
````

We add a currentOrder value that we increment with every new order. We define a generateOrderForMechanic function that takes in what's needed to create an order and creates it. (smells like another design pattern...)  We also add the mechanic id and order id to our MechanicOrderDataProvider which is used in the PartsNStuff Strategy. We then return the order.
我们添加一个currentOrder值，随着每个新订单的增加。 我们定义了一个generateOrderForMechanic函数，该函数接受创建订单所需的内容并创建它。我们还将Mechanic ID和订单ID添加到PartsNStuff策略中使用的MechanicOrderDataProvider。 我们然后返回订单。

Finally we call our OrderManager.fulfill order with the orders that we have generated.
最后，我们使用我们生成的订单调用OrderManager.fulfill订单。

Here is the output we get with the current setup

````

PartsNStuff strategy worked correctly, order fulfilled
Order: 1559 is fulfilled
Auto part strategy worked correctly, order fulfilled
Order: 1560 is fulfilled
ACME strategy worked correctly, order fulfilled
Order: 1561 is fulfilled

````


We can see that the correct order is mapped to the correct strategy. we see that each strategy goes through its own set of steps required to fulfill an order. Outside of our OrderManager none of the strategies are exposed to any other object or each other. We simply pass in an order and receive a true or false regarding the outcome. Our test case here present the happy path, try mocking around with our Orders and see how our Strategy Pattern responses.
们可以看到正确的顺序被映射到正确的策略。我们看到，每个策略都要通过自己完成订单所需的一系列步骤。在我们的OrderManager之外，没有任何策略暴露于任何其他对象或其他对象。我们只是简单地通过一个命令，并得出结果的真假。我们的测试案例呈现的是快乐的道路，试着嘲笑我们的订单，看看我们的策略模式如何回应。

Congratulations you have just implemented the Strategy Design Pattern to solve a nontrivial problem

The repo for the complete project can be found here:<a href="https://github.com/kingreza/Swift-Strategy"> Swift - Strategy </a> Download a copy of it and play around with it. See if you can find ways to improve it. Here are some ideas to consider:

<ul>
  <li>Add a new strategy for PartCo, a parts company for asian cars. They don't have the same requirements as PartsNStuff. Change the system so if the order for PartsNStuff fails, PartCo will be used to fulfill it.PartCo是亚洲汽车零部件公司的新战略。他们没有与PartsNStuff相同的要求。改变系统，如果PartsNStuff的订单失败，PartCo将被用来完成它。</li>
  <li>This example takes advantage of another well known design pattern. Can you spot it? 这个例子利用了另一个众所周知的设计模式。你能发现吗？</li>
       <li>In our current solution our strategies are hard coded in the OrderManager. Write a system where new strategies for each car type can be added to the manager dynamically. 在我们当前的解决方案中，我们的策略在OrderManager中被硬编码。写一个系统，每个车型的新策略可以动态添加到经理.</li>
</ul>
