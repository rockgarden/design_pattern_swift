<h1>Design Patterns in Swift: State</h1>
This repository is part of a series. For the full list check out <a href="https://shirazian.wordpress.com/2016/04/11/design-patterns-in-swift/">Design Patterns in Swift</a>

For a cheat-sheet of design patterns implemented in Swift check out <a href="https://github.com/ochococo/Design-Patterns-In-Swift"> Design Patterns implemented in Swift: A cheat-sheet</a>
 
<h3>The Problem:</h3>

A quote goes through many phases before it is completed by a mechanic. Initially a customer request a quote, once received, our system attempts to automatically provide a quote for the customer. If our system doesn't have enough information, the quote becomes pending. At this state a member of our customer support team finds out what's needed to provide a ready quote. Once a quote is ready, the customer can use it to book an appointment. Once an appointment is booked a mechanic is assigned to the quote. We need to be able to retrieve this mechanic's information. When the appointment is completed we generate a receipt and send it to the customer.
报价经过很多阶段，然后由技工完成。一开始客户要求报价，一旦收到，我们的系统会尝试自动为客户提供报价。如果我们的系统没有足够的信息，则报价变为挂起。在这个状态下，我们的客户支持团队的成员找出需要提供准备好的报价。一旦报价准备就绪，客户可以使用它来预约。一旦预约被确定，机械师将被分配到报价。我们需要能够检索这个机制的信息。预约完成后，我们生成收据并发送给客户。

We need a system that can provide us with an interface to get the price, get a customized message that's dependant on the quotes's state, and provide the receipt when the appointment is complete.
我们需要一个系统，可以为我们提供一个接口来获取价格，获得一个依赖于报价状态的定制消息，并在预约完成时提供收据。

<h3>The solution:</h3>

We will define a context that will hold our quotes's current state. We will then define a class for every state in which our quote can be in and have our context be responsible for changing its state. Our context will also provide us with an interface for the common functionalities that we expect from our quote, regardless of the state it's in.
我们将定义一个将保存我们的报价当前状态的上下文。然后，我们将定义一个类，为我们的报价可以在每个状态和我们的上下文负责改变其状态。我们的上下文还将为我们提供一个我们期望从我们的报价中获得的常见功能的界面，而不管其状态如何。

<!--more-->

Link to the repo for the completed project: <a href="https://github.com/kingreza/Swift-State">Swift - State</a>

Let's begin

From the description in the problem we can see that we need four specific functionality for our quote.
从问题的描述中我们可以看到，我们需要四个特定的功能用于我们的报价。
<ol>
	<li>Get the price for the quote 获取报价的价格</li>
	<li>Get the message we want to show to the customer regarding the quote 获取我们想要显示给客户的报价信息</li>
	<li>Get the assigned mechanic for the quote 获取报价的分配技工</li>
	<li>Get the receipt 取得收据</li>
</ol>

It's obvious that not all these functionalities make sense if the quote is at some specific state. For example a pending quote will never have a receipt or a quote that has just been sent, will not have a mechanic assigned until it is approved by the customer.
很显然，如果报价处于某种特定的状态，并不是所有这些功能都是有意义的。例如，一个待处理的报价将永远不会有收到的或刚刚发送的报价，在客户批准之前，不会有机械师分配。

Before going forward we should also understand what are the different states our quote can be in. We also want to know the basic flow from state to state.
在推进之前，我们也应该了解我们的报价可以在哪些不同的状态。我们也想知道从状态到状态的基本流程。
Submitted->Ready->Booked->Completed
Submitted->Pending->Ready
未决定 Pending

<a href="https://shirazian.files.wordpress.com/2016/04/suppliment.png"><img src="https://shirazian.files.wordpress.com/2016/04/suppliment.png" alt="suppliment" width="500" height="131" class="alignnone size-full wp-image-1018" /></a>

A quote begins when we receive a request from the customer. This is the beginning of its life cycle. The quote doesn't have a price, a mechanic or a receipt yet. We call this a submitted quote.
报价从我们收到客户的请求开始。这是其生命周期的开始。报价没有价格，技工或收据。我们称之为提交报价。

When a quote is submitted two things can happen. If our system can generate an automatic price for the quote then the quote becomes ready. However if our system doesn't have enough information or if the customer didn't provide something important, then the quote goes into a pending state. When a qoute is pending, someone from our customer support team needs to follow up on it and provide the needed information to turn it into a ready quote.
当提交报价时，可能发生两件事情。如果我们的系统可以为报价生成一个自动价格，那么报价已经准备就绪。然而，如果我们的系统没有足够的信息，或者客户没有提供重要的东西，那么报价就会进入待定状态。当qoute挂起时，我们客户支持团队的成员需要跟进并提供所需的信息，以将其转化为现成的报价。

When a quote is ready, it has a price and is sent to the customer. If the customer decides to book an appointment based on the quote, they will pick a mechanic. At this point the quote has become an appointment. For the sake of consistency we will call this, a booked quote.
当报价准备好了，它就会有价格并发送给客户。如果客户决定根据报价预约，他们将选择一名技工。在这一点上，报价已成为约定。为了保持一致性，我们会把这个叫做预订报价。

When the mechanic completes the job, then the quote has become completed and can now generate a receipt.
当技工完成工作后，报价已经完成，现在可以生成收据。

Now that we have a clear understanding of the problem, what's needed and the different states a quote can be in, we can begin building our system.
现在我们对这个问题有了清楚的认识，需要什么和不同的状态，我们可以开始建立我们的系统。

We begin by defining a protocol called State. This protocol enforces our state classes to supply the required functionality stated in the beginning. We need a way to get the price of the quote, we need the quote to give us a customized message to the customer regarding its status, we need to be able to get the assigned mechanic and have the quote provide a receipt when the work is completed.
我们首先定义一个名为State的协议。 该协议强制我们的state类提供开始所述的所需功能。 我们需要一种方法来得到报价的价格，我们需要报价给我们一个关于其状态的定制消息给客户，我们需要能够得到分配的技工，并在报价时提供收据完成。

````swift
protocol State {
  func getPrice(context: Context) -> Double?
  func getMessageToCustomer(context: Context) -> String
  func getAssignedMechanic(context: Context) -> Mechanic?
  func getReceipt(context: Context) -> Receipt?
}
````

Knowing our requirements, there isn't much in the protocol that stands out except the Context parameter that is passed to all our functions.
了解我们的要求，除了传递给我们所有函数的Context参数之外，协议中没有多少东西是暴露的。

What is context? Let's look at its code

````swift
class Context {
  private var state: State = SubmittedState()

  func getMessageToCustomer() -> String {
    return state.getMessageToCustomer(self)
  }

  func getPrice() -> Double? {
    return state.getPrice(self)
  }

  func getReceipt() -> Receipt? {
    return state.getReceipt(self)
  }

  func getMechanic() -> Mechanic? {
    return state.getAssignedMechanic(self)
  }

  func changeStateToReady(price: Double) {
    state = ReadyState(price: price)
  }

  func changeStateToPending() {
    state = PendingState()
  }

  func changeStateToBooked(price: Double, mechanic: Mechanic) {
    state = BookedState(price: price, mechanic: mechanic)
  }

  func changeStateToCompleted(price: Double, mechanic: Mechanic, receipt: Receipt) {
    state = CompletedState(price: price, mechanic: mechanic, receipt: receipt)
  }

}
```` 

The context acts as an interface between the quotes's various states/functionalities and the outside world. In our example, the context also provides an interface for other classes to change our quotes's state. Here anyone can change a quotes's state if they can provide the parameters requested by the context. Depending on the system you are designing you can limit or extend this behaviour to fit your needs.
上下文充当报价各种状态/功能与外部世界之间的接口。在我们的例子中，上下文还为其他类提供了一个接口来改变我们的引用的状态。这里任何人都可以改变引号的状态，如果他们可以提供上下文请求的参数。根据您设计的系统，您可以限制或扩展此行为以适应您的需求。

Our Context, can gives us the message we want to send to the customer, it can provide us with the price, the assigned mechanic and the receipt when the job is completed. 
我们的环境，可以给我们留言，我们要发送给客户，它可以为我们提供价格，分配技工和工作完成时的收据。

As we can see when a Context is generated, it comes with a local variable called state. This variable is initialized to be of SubmittedState type. The SubmittedState is one of five classes that are representative of the five different states our quote can be in. As we mentioned earlier, submitted is the initial state of a quote, it makes sense to have our Context start with its state set to the class that represents the submitted state.
正如我们可以看到，当一个上下文产生，它带有一个局部变量称为状态。这个变量被初始化为SubmittedState类型。 SubmittedState是五个类中的一个，它们代表了我们的报价可以在的五种不同的状态。正如我们前面提到的，提交的是报价的初始状态，让我们的上下文以其状态设置为该类的状态开始是有意义的代表提交的状态。

Let's look at the code behind our SubmittedState:

````swift
class SubmittedState: State {

  func getAssignedMechanic(context: Context) -> Mechanic? {
    print("a submitted quote doesn't have a mechanic assigned yet")
    return nil
  }

  func getMessageToCustomer(context: Context) -> String {
    return "Your quote has been submitted and is " +
    "being processed right now, please wait a few moments"
  }

  func getPrice(context: Context) -> Double? {
    print("a submitted quote doesn't have a price")
    return nil
  }

  func getReceipt(context: Context) -> Receipt? {
    print("a submitted quote doesn't have a receipt")
    return nil
  }
}

````

Naturally this class implemented the State protocol. Since no mechanic has been assigned to the quote yet, the SubmittedState returns nil when a mechanic is requested. We are also printing a message to the console so we know why we didn't get a Mechanic from our Context. The message sent to our customer "Your quote has been submitted and is being processed right now, please wait a few moments" is descriptive of the state the quote is in and lets the user know what will happen next. A submitted quote also has no price or receipt.
自然，这个类实现了State协议。 由于没有机械师已经被分配到报价，所以被请求的机械师时，已提交的状态返回零。 我们也向控制台发送消息，所以我们知道为什么我们没有从我们的上下文中获得一个技工。 发送给我们的客户的消息“您的报价已经提交，正在处理中，请稍等片刻”描述报价所在的状态，并让用户知道接下来会发生什么。 提交的报价也没有价格或收据。

Not a very exciting state for a quote to be in, but a good example that shows how our implemented class deals with the functions it needs to implement.
不是一个令人兴奋的状态，而是一个很好的例子，它显示了我们实现的类如何处理它需要实现的功能。

We need four more classes like this to cover all the states our quote can end up in. Here is the code for the rest of them:
我们需要四个这样的类来覆盖我们的报价可能结束的所有状态。下面是其余部分的代码

````swift
class ReadyState: State {}

class PendingState: State {}

class BookedState: State {}

class CompletedState: State {}
````

These classes follow the same pattern. As defined earlier, if they can provide the price, mechanic or a receipt they do so. If not they will return nil. Adding a new states, is as simple as implementing the State class and providing the needed interactions within the Context object. Instead of multiple nested ifs or never ending case statements within a quote object, we can extend our quotes various states easier without the complications of hardcoding it.
这些类遵循相同的模式。如前所述，如果他们能够提供价格，技工或收据，他们可以这样做。如果不是，他们将返回零。添加一个新的状态，就像实现State类一样简单，并在Context对象内提供所需的交互。而不是在一个quote对象中嵌套多个嵌套的ifs或永不结束的case语句，我们可以更容易地扩展我们的引用各种状态，而不需要硬编码的复杂性。

When our Context class is switching a quote's state, depending on the requirements set by that state, specific parameters are needed. For example, when a quote is being set to ready, we require a price, when it is being set to booked we need a mechanic and so on. Once the required parameters are provided, the new state is generated and the context's current state is assigned to the new state.
当我们的Context类正在切换报价状态时，根据该状态设置的要求，需要特定的参数。例如，当一个报价准备就绪时，我们需要一个价格，当它被设置为预订时，我们需要一个技工等等。一旦提供了所需的参数，就会生成新状态，并将上下文的当前状态分配给新状态。

In our system, our context doesn't really do much internal computing or performs automatic state changes. It simply provides an interface for other classes to take on that responsibility. I personally thought this makes sense for this example, but you don't have to follow this pattern if it doesn't make sense for your specific circumstances. Your context object can be as involved as you want it to be.
在我们的系统中，我们的上下文并不真正做太多的内部计算或执行自动的状态改变。它只是为其他类提供一个接口来承担这个责任。我个人认为这个例子是有道理的，但是如果对你的具体情况没有意义，你就不必遵循这个模式。你的上下文对象可以像你想要的那样被包含在内。

Before we get to test this out, let's look at our Mechanic and Receipt classes.
在我们开始测试之前，让我们看看我们的机械和收据类。

````swift
class Mechanic {}

class Receipt {}
````
Nothing out of the ordinary here. Our Mechanic object is a simple struct with a name property. Our receipt object too is a simple struct with a delivered, total and customerName property. These values are each set by their respective initializer method.
这里没什么特别的。我们的Mechanic对象是一个带有name属性的简单结构。我们的收据对象也是一个简单的结构，具有交付，总计​​和customerName属性。这些值分别由各自的初始化方法设置。

Let's put it all together and see who it looks like. For our test case we are going to play out the following scenario:
让我们把它放在一起，看看它是什么样子。对于我们的测试案例，我们将播放以下场景：

John Lee recently heard of YourMechanic and decided to give it a try. He requests a quote but forgets to provide his car's trim information. Our system wasn't able to give him an instant ready quote so his submitted quote went into pending. Steve from our customer support team reviews the pending quote and fills out the car's trim information. The ready quote now has a price of $66.25. John Lee reviews the quote and decides to book Joe Murphy, one of our best mechanics to perform the needed services. When Joe Murphy completes the job a receipt is attached to the quote and the customer is informed of the another service completed by YourMechanic.
李约翰最近听说YourMechanic，并决定试一试。他要求一个报价，但忘记提供他的车的修剪信息。我们的系统不能给他一个即时准备好的报价，所以他提交的报价进入待定状态。我们的客户支持团队史蒂夫审查待处理的报价，并填写汽车的修剪信息。准备好的报价现在有66.25美元的价格。约翰·李评论报价，并决定预订乔·墨菲，我们最好的机械师之一，执行所需的服务。当Joe Murphy完成工作时，会在报价单上附上收据，并通知您客户由YourMechanic完成的另一项服务。

As you can see there are a lot of moving parts here that is not related to our quote and its status. Again the idea here is to build a simple solution, representative of the State design pattern so we are going to simulate what's not closely related to the patterns.
正如你所看到的，这里有很多移动的部件，与我们的报价和状态无关。这里的想法再次是建立一个简单的解决方案，代表State的设计模式，所以我们将模拟与模式不密切相关的东西。

Here is our main setup with the scenario coded out:

````swift

var context = Context()

print(context.getMessageToCustomer())

context.changeStateToPending()

print(context.getMessageToCustomer())

var price = 66.25
context.changeStateToReady(price)

print(context.getMessageToCustomer())

print(context.getPrice()!)

var attemptedReceipt = context.getReceipt()

var joe = Mechanic(name: "Joe Murphy")
context.changeStateToBooked(price, mechanic: joe)

print(context.getMessageToCustomer())

var receipt = Receipt(delivered: true, total: price, customerName: "John Lee")
context.changeStateToCompleted(price, mechanic: joe, receipt: receipt)

print(context.getMessageToCustomer())

````

Let's go through it step by step

````swift
var context = Context()

print(context.getMessageToCustomer())

````

We begin when John Lee submits a quote. We start by creating our Context. Our context's initial state is set to SubmittedQuote automatically. Then we call our getMessageToCustomer function on our context which returns the message we would send to the customer when a quote is first submitted.
我们从John Lee提交报价开始。我们从创建我们的上下文开始。我们的上下文的初始状态自动设置为SubmittedQuote。然后我们在我们的上下文中调用我们的getMessageToCustomer函数，该函数返回我们在首次提交报价时发送给客户的消息。

Since John Lee did not provide his car's trim information, his quote will have to be set to pending:

````swift
context.changeStateToPending()
print(context.getMessageToCustomer())
````  

We set the quotes's state to pending through our context. Since no new information needs to be passed, this is done by simply calling the changeStateToPending function, with no parameters.
我们通过我们的上下文将报价状态设置为挂起。 由于不需要传递新的信息，只需调用changeStateToPending函数即可完成，而不需要任何参数。

We then print the message we expect to send to the customer.

````swift
var price = 66.25
context.changeStateToReady(price)

print(context.getMessageToCustomer())
````  

This is where Steve from customer support reviews our pending quote. He sets the quote to ready and assigns the price. Again, we print the message we expect to send to the customer.
这是来自客户支持的Steve审核我们待处理的报价的地方。 他将报价设置为准备并分配价格。 再次，我们打印我们希望发送给客户的消息。

````swift
print(context.getPrice()!)
var attemptedReceipt = context.getReceipt()

var joe = Mechanic(name: "Joe Murphy")
context.changeStateToBooked(price, mechanic: joe)

print(context.getMessageToCustomer())
````

Our quote is now ready and has a price. However it does not have a receipt yet. To do a quick test we will try to print the price and get a receipt. We will see the result of these two calls in a bit. At this point John Lee decides to pick Joe Murphy as his mechanic. We change the state to booked and pass Joe as the assigned mechanic.
我们的报价现在已经准备好，并有一个价格。 但是它还没有收据。 要做一个快速测试，我们将尝试打印价格并获得收据。 我们稍后会看到这两个调用的结果。 此时John Lee决定选择Joe Murphy作为他的机械师。 我们改变状态到预定并且通过乔作为被分配的技工。

````swift
var receipt = Receipt(delivered: true, total: price, customerName: "John Lee")
context.changeStateToCompleted(price, mechanic: joe, receipt: receipt)

print(context.getMessageToCustomer())
````

When the job is completed, we generate a receipt and set the quote to completed.
工作完成后，我们生成收据并设置报价完成。

Let's take a look at our output

````swift
Your quote has been submitted and is being processed right now, please wait a few moments
Your quote is currently pending, we will get back to you with a ready quote soon
Your quote is ready. The total for the services you have requested is: $66.25
66.25
a ready quote doesn't have a receipt
Your appointment has been booked with Joe Murphy.
Thank you for using YourMechanic.
Program ended with exit code: 0
````

As you can see, our quote goes through all its states successfully. It is able to provide what is requested if that is a viable option at that state and provides a message when it is not. The States themselves are not aware of each other and the flow from one state to another is confined in one place. Adding or removing a state is also fairly straightforward since none of the states or context code related to our quote object is actually in the quote object (Which if you noticed is absent from this solution all together)
正如你所看到的，我们的报价成功通过了所有的状态。它能够提供所要求的东西，如果这是一个可行的选择在那个国家，并提供一个消息，当它不是。各国本身并不相互了解，从一个国家流向另一个国家的局面只局限于一个地方。添加或删除状态也相当简单，因为与我们的引用对象相关的任何状态或上下文代码实际上都不在引用对象中（如果您注意到这些解决方案都不在这个解决方案中）

Congratulations you have just implemented the State Design Pattern to solve a nontrivial problem

The repo for the complete project can be found here:<a href="https://github.com/kingreza/Swift-State"> Swift - State </a> Download a copy of it and play around with it. See if you can find ways to improve it. Here are some ideas to consider:

<ul>
	<li>Integrate a quote object the the context object 集成一个quote对象的上下文对象</li>
        <li>In our example we pass the context to the functions defined within a state but never used the context itself, what would be a good example of when we would use the context? 在我们的例子中，我们将上下文传递给在状态中定义的函数，但是从来没有使用上下文本身，那么什么时候使用上下文会是一个很好的例子呢？</li>
	<li>If a customer would like to make a warranty claim they can do so after a service is completed, provided the supply a receipt. How would you include this state with its requirement in our current model. 如果客户想要提出保修索赔，他们可以在服务完成之后提供，并提供收据。你如何将这个状态与它的要求包括在我们现在的模型中？</li>
        <li>Instead of calling changeStateToX have the context do so automatically when a price is set, a mechanic is assigned or a receipt is generated. 当设置价格时，不是调用changeStateToX，而是在上下文自动完成的情况下，分配机械师或生成收据</li>
</ul>



