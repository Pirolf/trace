require './span'
require './mocktracer/mockspan_context'
require 'uuid'

class MockSpan
  include Span
  attr_reader :start_time, :finish_time, :operation_name

  def initialize(tracer, name, opts = {})
    @tracer = tracer
    @operation_name = name
    @start_time = opts[:start_time] || Time.now

    reference = opts[:reference]
    span_id = UUID.generate
    if !reference
      @span_context = MockSpanContext.new(UUID.generate, span_id)
      @parent_id = '-'
    else
      context = reference.referenced_context
      @span_context = MockSpanContext.new(context.trace_id, span_id)
      @parent_id = context.span_id
    end
  end

  def finish(opts = {})
    @finish_time = opts[:finish_time] || Time.now
    @tracer.record_span(self)
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
