# frozen_string_literal: true

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
    if Authentication.getlogin != @owner_name
      raise "Illegal access: #{Authentication.getlogin} cannot access account."
    end
  end
end

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

# The above approach can be slightly improved
# The Proxy is too tightly coupled to BankAccount
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
