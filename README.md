# Design Patterns in Ruby

Notes from the book by Russ Olsen. Everything has been compiled into this one readme for easy reference and lookup.

- [Design Patterns in Ruby](#Design-Patterns-in-Ruby)
- [Introduction](#Introduction)
  - [Metapatterns](#Metapatterns)
    - [1. Separate out things that are likely to change from those that are not](#1-Separate-out-things-that-are-likely-to-change-from-those-that-are-not)
    - [2. Program to an interface, not an implementation](#2-Program-to-an-interface-not-an-implementation)
    - [3. Prefer composition over inheritance](#3-Prefer-composition-over-inheritance)
    - [4. Delegate, delegate, delegate](#4-Delegate-delegate-delegate)
    - [You Ain't Gonna Need It (YAGNI)](#You-Aint-Gonna-Need-It-YAGNI)
- [Template Method](#Template-Method)
- [Strategies](#Strategies)
  - [Using `Proc` and `lambda`](#Using-Proc-and-lambda)
- [Observers](#Observers)
  - [Hand-Built Solution](#Hand-Built-Solution)
  - [Ruby Standard Library](#Ruby-Standard-Library)

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
