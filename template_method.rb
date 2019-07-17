# frozen_string_literal: true

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
