require './span'

class MockSpan < Span
  attr_reader :finish_time, :operation_name, :tracer

  def initialize(tracer, name)
    @tracer = tracer
    @operation_name = name
  end

  def finish
    @finish_time = Time.now
  end

  def finish_with_options(opts)

  end

  def context

  end

  def set_operation_name(operation_name)
    @operation_name = operation_name
    self
  end

  def set_tag(k, v)

  end

  def set_baggage_item(k, v)

  end

  def baggage_item(k)

  end

  def log(kv_pairs, timestamp)

  end
end
