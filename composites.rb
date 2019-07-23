# frozen_string_literal: true

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
