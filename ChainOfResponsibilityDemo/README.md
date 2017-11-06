<h1>责任链 Chain of Responsibility</h1>
This repository is part of a series. For the full list check out <a href="https://shirazian.wordpress.com/2016/04/11/design-patterns-in-swift/">Design Patterns in Swift</a>

For a cheat-sheet of design patterns implemented in Swift check out <a href="https://github.com/ochococo/Design-Patterns-In-Swift"> Design Patterns implemented in Swift: A cheat-sheet</a>

<h3>The problem:</h3>
Not all mechanics are created equally. Some mechanics are more experienced and can do more than others. We need a system where every job is propagated from the least experienced mechanic to the most. This way  experienced mechanics that can perform more jobs are not busy with jobs that more junior mechanics can take care of.
并非所有的力学都是平等的。有些机械师比较有经验，可以做得比别人多。我们需要一个系统，每个工作都是从最有经验的技工传播到最多。这种经验丰富的机械师可以执行更多的工作，而不是忙于更多初级机械师可以照顾的工作。
<h3>The solution:</h3>
We will break down our mechanics into four different skill levels: oil change only, junior, apprentice and master mechanic. Every mechanic will have their skill level assigned to one of these four values. Each mechanic skill level will also have a reference to a set of mechanics that are at the next skill level. We will then define a virtual shop and pass it our first line of mechanics (our most junior fleet).  Next we will define a set of jobs we wish to perform along with the minimum skill level required. We will pass these jobs to our virtual shop which in turn goes through each skill level, trying to find the mechanic with the minimum skills set required to do the job.
我们将把我们的机制分解成四种不同的技能水平：换油，初级，学徒和机械师。每个技工都将他们的技能水平分配给这四个值中的一个。每个技工的技能水平也将参考下一个技能水平的一组机制。然后，我们将定义一个虚拟商店，并通过我们的第一线机械（我们最初级的机队）。接下来，我们将定义一组我们希望执行的工作以及所需的最低技能水平。我们将把这些工作交给我们的虚拟商店，然后再通过每个技能水平，试图找到工作所需的最低技能的机械师。

Let's begin

We'll start off by defining our different skill sets using an enumerable.
使用一个枚举 Skill 来定义我们不同的技能集


Next we'll define our job object:

The job object will have three properties, minimumSkillSet which is of type skill that we define earlier. This is the minimum level a mechanic needs to be to complete this job. We also define a name for naming our job and a completed flag which will indicate if the job has been completed. We set its minimumskillSet and name in its initializer.
将具有三个属性，minimumSkillSet是我们之前定义的类型技能。 这是一个机械师需要完成这项工作的最低水平。 我们还定义了一个名字来命名我们的工作和一个完整的标志，这将表明工作是否已经完成。 我们在其初始化程序中设置其minimumskillSet和name。

Next we'll define our mechanic object:

Our Mechanic class is not that complicated. Mechanics have a skill property which indicates the mechanic's ability. They have a name, since all our mechanic's have a name. And finally an isBusy flag which indicates if the mechanic is available to do the job. We initialize the skill set and name of the mechanics in our initializer and set our isBusy flag to false by default.
Mechanic并不复杂。Mechanic有一个技能属性，表示技工的能力。他们有一个名字，因为我们所有的机械都有一个名字。最后一个isBusy标志，表示机械是否可以做这项工作。我们在初始化器中初始化机制的技能集合和名称，并将isBusy标志设置为false。

Our Mechanic class also has a performJob function that takes a job as a parameter. The way we are going to design our system is in such a way that it will make sure the mechanic that gets the job is both available and has its skill matched before this function is called. This is why we assert that if a job is being passed to a mechanic that is not compatible with his/her skill set or if the mechanic is busy, that there is something wrong with our code. I find this to be a better solution to using a guard since calling performJob on an incompatible job or a busy mechanic is an exception and would mean there is a bug in our code.
我们的机械类也有一个performJob函数，它将一个工作作为参数。我们要设计我们的系统的方式是这样的，它将确保在调用这个函数之前，获得工作的机制是可用的，并且具有它的技能匹配。这就是为什么我们断言，如果一个工作被传递给一个与他/她的技能不相容的机械师，或者机械师很忙，那么我们的代码就有问题了。我觉得这是一个更好的解决方案，因为在一个不兼容的工作上调用performJob或者一个繁忙的机制是个例外，这意味着我们的代码中有一个bug。

The perform job method simply performs the job, sets the mechanic to busy and the job to completed.
执行作业方法只是简单地执行作业，将机械师设置为忙碌，并完成作业。

Here is where things get interesting. Next up we are going to define a MechanicSkillGroup object. This class will contain an inventory of all mechanics within its skillset and a link to the MechanicSkillGroup with mechanics at the next level. This class will function as a container for all mechanics that share the same skill level.
这是事情变得有趣的地方。接下来，我们将定义一个MechanicSkillGroup对象。这个类将包含一个技能组中的所有机制的清单，并与MechanicSkillGroup与下一级机制的链接。这个类将作为共享相同技能水平的所有机制的容器。

Lets go through it step by step so we understand what's going on here:

Our MechanicSkillGroup class has three properties. First off we have mechanics which is a collection of all mechanics that share the skill group's skill set. Next we have nextLevel which is an optional reference to another MechanicSkillGroup. This will be a pointer to the MechanicSkillGroup set for the next level of mechanics. The reason this is set to optional is because at the MasterMechanic skill level, we will be at the end of the chain, no other MechanicSkillGroup will come after it. Finally we have our skill property which is set to what this MechanicSkillGroup is representing. We initialize these values in our initializer.
我们的MechanicSkillGroup类有三个属性。 首先我们有机械师，这是所有分享技能组技能的机械师的集合。 接下来我们有nextLevel，它是另一个MechanicSkillGroup的可选参考。 这将成为下一个机制的MechanicSkillGroup指针。 这个选择的原因是因为在MasterMasteric的技能水平上，我们将会在链条的末端，没有其他的MechanicSkillGroup会跟在后面。 最后，我们有我们的技能属性，这是由这个MechanicSkillGroup代表的。 我们在初始化器中初始化这些值。

Next up we define a function within our MechanicSkillGroup class called performJobOrPasstUp.

performJobOrPassItUp takes one parameter of type job as an argument and returns a boolean to indicate whether it was able or not able to get the job done. First we check to see if the job's minimum skill requirement is more than what our current MechanicSkillGroup can do or that we have no available mechanics in the current MechanicSkillGroup. If either one of those are true then the mechanics in this MechanicSkillGroup cannot perform this job and it should be passed to higher ups in our chain of responsibility. If there is no higher ups in our chain then when have reached the end of the line and we simply do not have anyone available that can perform this job. Otherwise we grab the first available mechanic from our list of mechanics and have them perform the job.
performJobOrPassItUp将作为参数的一个参数作为参数，并返回一个布尔值来指示是否能够完成工作。 首先我们检查工作的最低技能要求是否比我们目前的MechanicSkillGroup能够做的要多，或者我们现在的MechanicSkillGroup中没有可用的机制。 如果其中任何一个都是真的，那么这个MechanicSkillGroup的机制就不能完成这个工作，而应该被传递给更高层的责任链。 如果我们的连锁店没有更高的起步线，那么什么时候到达线的末端，我们根本没有任何人可以完成这项工作。 否则，我们从机械师名单中抓住第一名可用的机械师，让他们完成这项工作。

Finally we define a shop object which will behave as a pseudo manager for our MechanicSkillGroup.
最后，我们定义一个商店对象，它将作为我们MechanicSkillGroup的伪管理者。

This class will have a private property called firstMechanics. This will be a reference to the beginning of our chain of responsibility. These will be our least experienced mechanics.
这个类将有一个名为firstMechanics的私有财产。 这将是对我们责任链开始的提及。 这些将是我们经验最少的机制。
Next we will define a performJob function that will begin the process by calling the performJobOrPassItUp on our first MechanicSkillGroup in our chain of responsibility.
接下来，我们将定义一个performJob函数，通过调用我们在我们职责链中的第一个MechanicSkillGroup的performJobOrPassItUp来开始这个过程。
This is it, we have all the needed pieces to set up and run our implementation of chain of responsibility. Lets look at a sample set up and some test cases.

Lets go over it section by section so we understand how it's all set up.

We begin by setting our master mechanics

We create four mechanics, assigning them their names and skill level. Next we create our MechanicSkillGroup container for our master mechanics. We pass .MasterMechanic as this group's skill set, an array of master mechanics we created and nil for the nextLevel. Since MasterMechanic is the highest skill set this makes sense.
我们创建四个机制，分配他们的名字和技能水平。 接下来我们为我们的主要机制创建我们的MechanicSkillGroup容器。 我们通过.MasterMechanic作为这个小组的技能组合，我们创建了一组主要力学，而下一个级别则是零。 由于MasterMechanic是最高的技能，所以这是有道理的。

We follow the same procedure for apprenticeMechanics, juniorMechanics and oilChangeOnlys.

Next up we'll define our shop and jobs:

We create a shop instance and pass it the begining of our chaint of responsibility which is OilChangeOnly mechanics. Next we define an array of jobs with different minimumSkillSets.
我们创建一个商店实例，并将其传递给我们的责任即OilChangeOnly机制的开始。 接下来我们用不同的minimumSkillSets定义一个作业数组。

And finally we attempt to perform each job through our chain:

Here is the result we get:

````swift
Ken Hudson with skill set Junior has started to do Windshield Wiper
Tyson Trump with skill set Apprentice has started to do Light Bulb Change
Tina Bernard with skill set Apprentice has started to do Battery Replacement
Grant Hughes with skill set OilChangeOnly has started to do General Oil Change
Matt Lowes with skill set Junior has started to do General Oil Change
Sandeep Shenoy with skill set Junior has started to do General Oil Change
Tom Berry with skill set Junior has started to do General Oil Change
Steve Frank with skill set MasterMechanic has started to do Timing Belt Replacement
Bryan Tram with skill set Apprentice has started to do Brake Pads Replacement
Program ended with exit code: 9
````

We see that jobs are traversing correctly up the chain. We see that once our only mechanic who is at OilChangeOnly becomes busy with the job, further oil changes are bumped up to the next level. Following this chain of responsibility we ensure that mechanics are only occupied with jobs that most closely match their skill set. This optimizes our supply and ensures that our more experienced mechanics are available for jobs that only they can perform.
我们看到工作正在链条上正确地运行。我们看到，一旦我们唯一在OilChangeOnly的机械忙于工作，进一步的OilChangeOnly就会碰撞到更高一层。遵循这个责任链条，我们确保机制只与最接近他们技能的工作有关。这优化了我们的供应，并确保我们更有经验的机械师可用于只有他们可以执行的工作。

Congratulations you have just implemented the Chain Of Responsibility Design Pattern to solve a nontrivial problem

<li>What would you change if you wanted to have lower tier mechanics perform parts of the job and pass the rest to the higher up mechanics in chain 如果您希望让低层机制执行部分工作，并将剩下的工作交给链中更高级的机制，那么您会改变什么</li>
<li>Implement a way for a mechanic to spend a finite amount of time performing a job and becoming available when completed. Then try to expand on the design so it can deal with jobs that could not be performed at the time the request was sent. What are our options?实施一种方法让技工花费有限的时间执行工作，并在完成时变得可用。然后尝试扩展设计，以便处理发送请求时无法执行的作业。我们有什么选择？</li>
<li>Imagine we have customers that are willing to pay premium rates to use our most experienced mechanics available, how would we set up our chain of responsibility for those customers?假设我们有客户愿意支付高额费用来使用我们最有经验的机械师，我们将如何为这些客户建立我们的责任链？ </li>
<li>It's not always necessary to traverse all jobs all the way up the chain. Imagine it's not financially feasible to have master mechanics do any oil changes. How would you prevent this from happening? 并不总是需要遍历链上的所有工作。想象一下，让主力学家做任何换油都不是经济上可行的。你会如何防止这种情况发生？</li>
</ul>

