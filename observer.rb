# frozen_string_literal: true

# Hand-Built Solution
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

  # Pass the object that has been updated
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

# With a code block observer
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
