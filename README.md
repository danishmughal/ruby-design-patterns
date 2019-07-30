# Design Patterns in Ruby

Notes from the book by Russ Olsen. Everything has been compiled into this one readme for easy reference and lookup.

- [Design Patterns in Ruby](#design-patterns-in-ruby)
- [Introduction](#introduction)
  - [Metapatterns](#metapatterns)
    - [1. Separate out things that are likely to change from those that are not](#1-separate-out-things-that-are-likely-to-change-from-those-that-are-not)
    - [2. Program to an interface, not an implementation](#2-program-to-an-interface-not-an-implementation)
    - [3. Prefer composition over inheritance](#3-prefer-composition-over-inheritance)
    - [4. Delegate, delegate, delegate](#4-delegate-delegate-delegate)
    - [You Ain't Gonna Need It (YAGNI)](#you-aint-gonna-need-it-yagni)
- [Template Method](#template-method)
- [Strategies](#strategies)
  - [Using `Proc` and `lambda`](#using-proc-and-lambda)
- [Observers](#observers)
  - [Hand-Built Solution](#hand-built-solution)
  - [Ruby Standard Library](#ruby-standard-library)
- [Composites](#composites)
  - [Baking a Cake](#baking-a-cake)
- [Iterators](#iterators)
  - [External Iterator](#external-iterator)
  - [Internal Iterator](#internal-iterator)
    - [`Enumerable`](#enumerable)
- [Commands](#commands)
  - [Composite Command](#composite-command)
- [Adapters](#adapters)
  - [Writing an Adapter class](#writing-an-adapter-class)
- [Proxies](#proxies)
  - [Protection Proxies](#protection-proxies)
  - [Virtual Proxies](#virtual-proxies)

# Introduction

The infamous "Gang of Four" - Erich Gamma, Richard Helm, Ralph Johnson, and John Vlissides.

## Metapatterns

### 1. Separate out things that are likely to change from those that are not

### 2. Program to an interface, not an implementation

Rather than coupling code to various different implementation options, we should try to program to a more overarching interface.

```ruby
# Bad:
if is_car
  car.drive(200)
else
  plane.fly(200)
end


# Good - Programming to an interface:
vehicle.travel(200)
```

### 3. Prefer composition over inheritance

While inheritance is a poweful tool, by definition it leads to strongly coupled code between super/subclasses.

Rather than an object being a _type_ of something, it should _have_ something.

```ruby
class Engine # GasolineEngine, DieselEngine, etc...
  def start; end
  def stop; end
end

class Car
  def initialize(engine)
    @engine = engine
  end

  def drive
    @engine.start
    @engine.stop
  end
end

# Both cars here are Cars, but composed of different parts (engines)
gasoline_car = Car.new(GasolineEngine.new)
diesel_car = Car.new(DieselEngine.new)
```

### 4. Delegate, delegate, delegate

Objects of a class should not be responsible for behavior in another class. That responsibility should be passed off to the correct class/object.

```ruby
class Car
  # ...
  def start_engine
    @engine.start
  end

  def stop_engine
    @engine.stop
  end
  # ...
end
```

### You Ain't Gonna Need It (YAGNI)

Simply don't build features that you don't need _right now_. Because you probably are not going to need them later anyways. Build in only the flexibility that you need.

# Template Method

The template method is useful when abstracting out a process that follows the same pattern across a variety of use cases, but where individual steps may differ. Generally you will create a base class with a template method + some abstract/hook methods that are fleshed out in subclasses (more specific implementations).

The major downside to this approach is that depends on inheritance -- something we should be trying to avoid relying on.

```ruby
class Report
  def initialize
    @title = 'Monthly Report'
    @text = ['Things are going', 'really, really well.']
  end

  # Template method (skeletal method)
  def output_report
    output_start
    output_head
    output_body_start
    output_body
    output_body_end
    output_end
  end

  # Example of a Hook Method
  # Subclasses can define or leave as is
  def output_body
    @text.each do |line|
      output_line(line)
    end
  end

  def output_start
    raise 'Called abstract method: output_start'
  end

  def output_head
    raise 'Called abstract method: output_head'
  end

  def output_body_start
    raise 'Called abstract method: output_body_start'
  end

  def output_line(_line)
    raise 'Called abstract method: output_line'
  end

  def output_body_end
    raise 'Called abstract method: output_body_end'
  end

  def output_end
    raise 'Called abstract method: output_end'
  end
end

# An implementation of a plain text report
# Utilizing the template method on the superclass
class PlainTextReport < Report
  def output_start; end

  def output_head
    puts("**** #{@title} ****")
  end

  def output_body_start; end

  def output_line(line)
    puts(line)
  end

  def output_body_end; end

  def output_end; end
end

PlainTextReport.new.output_report
```

# Strategies

The strategy pattern is a delegation-based approach to solving the same problem as the template method pattern. Each algorithm is implemented separately, and can be dynamically passed to the context object to vary behavior.

```ruby
# The 'Report' is the context
# The 'Formatter' is the strategy
class Report
  attr_reader :title, :text
  attr_accessor :formatter

  def initialize(formatter)
    @title = 'Monthly Report'
    @text = ['Things are going', 'really, really well.']
    @formatter = formatter
  end

  def output_report
    @formatter.output_report(self)
  end
end

# HTML Strategy Object
class HTMLFormatter
  def output_report(context)
    puts('<html>')
    puts('  <head>')
    puts("    <title>#{context.title}</title>")
    puts('  </head>')
    puts('  <body>')
    context.text.each do |line|
      puts("    <p>#{line}</p>")
    end
    puts('  </body>')
    puts('</html>')
  end
end

# Plain Text Strategy Object
class PlainTextFormatter
  def output_report(context)
    puts("***** #{context.title} *****")
    context.text.each do |line|
      puts(line)
    end
  end
end

Report.new(formatter: HTMLFormatter.new)
Report.new(formatter: PlainTextFormatter.new)
```

## Using `Proc` and `lambda`

Since a strategy is simply a piece of code that knows how to do something, we can also use `Proc` and `lambda` to implement the Strategy pattern:

```ruby
# Proc/lambda Strategy
class Report
  # ...
  def initialize(&formatter)
    # ...
    @formatter = formatter
  end

  def output_report
    @formatter.call(self)
  end
end

# Define the formatter (just a block of code)
HTML_FORMATTER = lambda do |context|
  puts('<html>')
  puts('  <head>')
  puts("    <title>#{context.title}</title>")
  puts('  </head>')
  puts('  <body>')
  context.text.each do |line|
    puts("    <p>#{line}</p>")
  end
  puts('  </body>')
  puts('</html>')
end

report = Report.new(&HTML_FORMATTER)
report.output_report
```

With this approach, we can also create strategies on the fly by passing a code block directly into the method:

```ruby
report = Report.new do |context|
  puts("***** #{context.title} *****")
  context.text.each do |line|
    puts(line)
  end
end
report.output_report
```

# Observers

The observer pattern helps us solve the problem of building a tightly integrated system, where changes in one parts of the program need to be responded to by other parts.

## Hand-Built Solution

```ruby
# An includable module to make a class 'Observable'
module Subject
  def initialize
    @observers = []
  end

  def add_observer(observer)
    @observers << observer
  end

  def delete_observer(observer)
    @observers.delete(observer)
  end

  # Pass the object that has been updated (self)
  # to each of the observers on the object
  def notify_observers
    @observers.each do |observer|
      observer.update(self)
    end
  end
end

# Our 'Observable'/Subject class
class Employee
  include Subject

  attr_reader :name, :address, :salary

  def initialize(name, title, salary)
    super()
    @name = name
    @title = title
    @salary = salary
  end

  # Whenever salary is updated, we notify all observers
  def salary=(new_salary)
    @salary = new_salary
    notify_observers
  end
end
```

We can also pass in a code block as an observer like so:

```ruby
class Employee
  # ...
  def notify_observers
    @observers.each do |observer|
      observer.call(self)
    end
  end
  # ...
end

fred = Employee.new('Fred', 'Crane Operator', 30000)

fred.add_observer do |changed_employee|
  puts("Cut a new check for #{changed_employee.name}!")
  puts("His salary is now #{changed_employee.salary}!")
end
```

## Ruby Standard Library

The ruby standard library comes with a built in `Observable` module that works in a similar way to the one written above:

```ruby
# Ruby standard library
require 'observer'

class Employee
  include Observable

  # ...

  def salary=(new_salary)
    @salary = new_salary

    # Built-in methods to use
    changed
    notify_observers(self)
  end
end
```

# Composites

The composite pattern recommends that when you are building large complex objects, they should be _composed_ of smaller, more simpler objects. It is a highly flexible pattern that can be applied in many scenarios, such as hierarchies and with complex multi-step processes.

With this pattern, you'll usually end up defining:

1. The most basic type of object that represents a leaf (Task)
2. A _composite_ class composed of those leaves (CompositeTask)

## Baking a Cake

When baking a cake, we need to do the following.

```
1. Make Batter
   1. Add dry ingredients
   2. Add liquids
   3. Mix
2. Fill pan
3. Bake
4. Frost
```

```ruby
# Our `leaf` class - a Task
class Task
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def get_time_required
    0.0
  end
end

# Our `composite` class, composed of subtask Tasks
# A composite should behave similarly to the basic leaf
class CompositeTask < Task
  def initialize(name)
    super(name)
    @subtasks = []
  end

  def add_subtask(task)
    @subtasks << task
  end

  def remove_subtask(task)
    @subtasks.delete(task)
  end

  def get_time_required
    time = 0.0
    @subtasks.each { |task| time += task.get_time_required }
    time
  end
end

# The overall process, which is a composite of many subtasks
class MakeCakeTask < CompositeTask
  def initialize
    super 'Make Cake'
    add_subtask(MakeBatterTask.new)
    add_subtask(FillPanTask.new)
    add_subtask(FrostTask.new)
  end
end

# The first step, also a composite
class MakeBatterTask < CompositeTask
  def initialize
    super('Make Batter')
    add_subtask(AddDryIngredientsTask.new)
    add_subtask(AddLiquidsTask.new)
    add_subtask(MixTask.new)
  end
end

# Various simple tasks
class FillPanTask < Task; end
class FrostTask < Task; end
class AddLiquidsTask < Task; end
class MixTask < Task; end
```

# Iterators

The iterator pattern allows an aggregate object to be accessed sequentially without exposing its underlying implementation.

## External Iterator

With external iterators, you have access to an instantiated iterator object, which gives your more flexibility as to what you can do with it.

```ruby
# An External Iterator (Java-style)
class ExternalIterator
  def initialize(array)
    @array = array
    @index = 0
  end

  def has_next?
    @index < @array.length
  end

  def item
    @array[@index]
  end

  def next_item
    value = @array[@index]
    @index += 1
    value
  end
end

# Using the iterator
array = %w[red blue green]
i = ExternalIterator.new(array)

while i.has_next?
  puts 'Next Item:'
  puts i.next_item
end

# Can also use with strings as it also has a `length` method
i = ExternalIterator.new('abc')
puts i.next_item.chr while i.has_next?
```

## Internal Iterator

With internal iterators, we pass down a code block into the iterator itself -- therefore all of the actual iteration logic is performed within it, internally.

There is no separate iterator object to manage, leading to simpler code.

A simple implentation of `for_each_object`, which works similarly to the built-in `each` method:

```ruby
# A hand-rolled internal iterator
def for_each_element(array)
  i = 0
  while i < array.length
    yield (array[i])
    i += 1
  end
end

a = [10, 20, 30]
for_each_element(a) { |element| puts "Element: #{element}" }
```

### `Enumerable`

Ruby provides a built-in mixin `Enumerable` which adds in a number of useful methods for constructing Iterators.

```ruby
# Enumerable Mixin
class Portfolio
  include Enumerable

  def initialize
    @accounts = []
  end

  def add_account
    @accounts << account
  end

  # Need to define an `each` method
  def each(&block)
    @accounts.each(&block)
  end
end

class Account
  attr_accessor :name, :balance

  def initialize(name, balance)
    @name = name
    @balance = balance
  end

  def <=>(other)
    balance <=> other.balance
  end
end

# We now have access to various Enumerable methods
my_portfolio = Portfolio.new
my_portfolio.any? { |account| account.balance > 2000 }
my_portfolio.all? { |account| account.balance >= 10 }
```

# Commands

The Command pattern involes setting up "command objects" whose sole responsibility is to carry out some specific instructions when executed.

This pattern is similar to the Observer pattern, except for the fact that commands do not care at all about the actual state of the object that calls them.

For example, the following scenario represents how one might design a button class for a GUI that can be extended by other developers to do whatever they need:

```ruby
class SlickButton
  attr_accessor :command

  def initialize(command)
    @command = command
  end

  def on_button_push
    @command.execute if command
  end
end

class SaveCommand
  def execute
    # ... Save the document
  end
end

# We supply a command when construction a button
SlickButton.new(SaveCommand.new)
```

We can use the Command pattern without having to specifically create a Command class by just passing in a code block / `Proc`:

```ruby
# Code-block Example
class SlickButton
  attr_accessor :command

  def initialize(&block)
    @command = block
  end

  def on_button_push
    @command&.call
  end
end

# To use:
new_button = SlickButton.new do
  puts 'Button pressed'
end
```

## Composite Command

As processes grow in complexity, we can't keep all of our logic in a single command object. By combining the composite and command patterns, we can create a `CompositeCommand` that serves as a wrapper for and keeps track of the state of multiple sub-commands.

```ruby
# Composite Command
class CompositeCommand
  def initialize(commands = [])
    @commands = commands
  end

  def add_command(command)
    @commands << command
  end

  def execute
    @commands.each(&:execute)
  end
end

class CreateFile; end
class CopyFile; end
class DeleteFile; end

# Using the composite
cmds = CompositeCommand.new
cmds.add_command(CreateFile.new('example.txt', 'Words'))
cmds.add_command(CopyFile.new('example.txt', 'example2.txt'))
cmds.add_command(DeleteFile.new('example.txt'))
```

# Adapters

Similarly to the hardware world, software needs mechanisms to make sure that certain pieces of code can correctly communicate with others.

An adapter is an object that helps make other objects work better with each other -- it unifies interfaces.

## Writing an Adapter class

```ruby
# The Encrypter encrypts text from a reader file into a writer file
class Encrypter
  def initialize(key)
    @key = key
  end

  def encrypt(reader, writer)
    key_index = 0
    until reader.eof?
      clear_char = reader.getc
      encrypted_char = clear_char ^ @key[key_index]
      writer.putc(encrypted_char)
      key_index = (key_index + 1) % @key.size
    end
  end
end

# When dealing strictly with files, it works well:
reader = File.open('message.txt')
writer = File.open('message.encrypted', 'w')
encrypter = Encrypter.new('my secret key')
encrypter.encrypt(reader, writer)

# If we want the Encrypter to work with strings, we can write an adapter:
class StringIOAdapter
  def initialize(string)
    @string = string
    @position = 0
  end

  def getc
    raise EOFError if @position >= @string.length

    ch = @string[@position]
    @position += 1
    ch
  end

  def eof?
    @position >= @string.length
  end
end

# We can now adapt strings to be Encrypter-compatible:
reader = StringIOAdapter.new('We attack at dawn')
writer = File.open('out.txt', 'w')
encrypter = Encrypter.new('XYZZY')
encrypter.encrypt(reader, writer)
```

# Proxies

The Proxy Pattern is useful when we want to provide a layer of functionality on top of an object, but don't want to really change how that object is used by others.

Some use cases:

- Building an authorization/access-control policy for objects
- Delaying creation of an expensive object
- Hiding the location of an actual object

First let's define a core BankAccount class:

```ruby
class BankAccount
  attr_reader :balance

  def initialize(starting_balance = 0)
    @balance = starting_balance
  end

  def deposit(amount)
    @balance += amount
  end

  def withdraw(amount)
    @balance -= amount
  end
end
```

## Protection Proxies

We can create a protection proxy for the bank account to restrict access/usage of the object:

```ruby
# Protection Proxy
class AccountProtectionProxy
  def initialize(real_account, owner_name)
    @subject = real_account
    @owner_name = owner_name
  end

  def deposit(amount)
    check_access
    @subject.deposit(amount)
  end

  def withdraw(amount)
    check_access
    @subject.withdraw(amount)
  end

  def balance
    check_access
    @subject.balance
  end

  def check_access
    if Etc.getlogin != @owner_name
      raise "Illegal access: #{Etc.getlogin} cannot access account."
    end
  end
end
```

Ruby gives us a few metaprogramming shortcuts for writing proxies, namely the `method_missing` method which is triggered whenever an undefined method on an object is called. We can use this to delegate the correct message to the correct object after the proxy has done its work:

```ruby
# Protection Proxy - the Ruby way
class AccountProtectionProxy
  def initialize(real_account, owner_name)
    @real_account = real_account
    @owner_name = owner_name
  end

  def method_missing(name, *args)
    check_access
    @subject.send(name, *args)
  end

  def check_access
    if Authentication.getlogin != @owner_name
      raise "Illegal access: #{Authentication.getlogin} cannot access account."
    end
  end
end
```

## Virtual Proxies

We can create virtual proxies to delay the creation of expensive objects until they are needed.

```ruby
# Virtual Proxy
class AccountProtectionProxy
  def initialize(starting_balance = 0)
    @starting_balance = starting_balance
  end

  def deposit(amount)
    subject.deposit(amount)
  end

  def withdraw(amount)
    subject.withdraw(amount)
  end

  def balance
    subject.balance
  end

  def subject
    @subject ||= BankAccount.new(@starting_balance)
  end
end
```

The above approach can be improved by de-coupling the proxy from BankAccount and allowing a code black to be passed in during initialization:

```ruby
# Proc-based Virtual Proxy
class VirtualAccountProxy
  def initialize(&creation_block)
    @creation_block = creation_block
  end

  # ...

  def subject
    @subject ||= @creation_block.call
  end
end

account = VirtualAccountProxy.new { BankAccount.new(10) }
```

We can take the above example and use the same `method_missing` metaprogramming strategy to write a virtual proxy:

```ruby
# Virtual Proxy - the Ruby way
class VirtualAccountProxy
  def initialize(&creation_block)
    @creation_block = creation_block
  end

  def method_missing(name, *args)
    subject.send(name, *args)
  end

  def subject
    @subject ||= @creation_block.call
  end
end
```
