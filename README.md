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

# Introduction

The infamous "Gang of Four" - Erich Gamma, Richard Helm, Ralph  Johnson, and  John Vlissides.

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

Rather than an object being a *type* of something, it should *have* something.


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
Simply don't build features that you don't need *right now*. Because you probably are not going to need them later anyways. Build in only the flexibility that you need. 