# frozen_string_literal: true

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
