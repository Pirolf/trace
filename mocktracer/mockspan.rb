require './span'

class MockSpan < Span
  attr_reader :start_time, :finish_time, :operation_name, :tracer

  def initialize(tracer, name, opts = {})
    @tracer = tracer
    @operation_name = name
    @start_time = opts[:start_time] || Time.now
  end

  def finish
    @finish_time = Time.now
    @tracer.record_span(self)
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
