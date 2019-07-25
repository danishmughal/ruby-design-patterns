# frozen_string_literal: true

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

# A basic Internal Iterator
def for_each_element(array)
  i = 0
  while i < array.length
    yield (array[i])
    i += 1
  end
end

a = [10, 20, 30]
for_each_element(a) { |element| puts "Element: #{element}" }

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
