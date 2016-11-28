class SpanContext
  attr_accessor :trace_id, :span_id, :sampled

  def initialize(trace_id, span_id, sampled = false)
    @trace_id = trace_id
    @span_id = span_id
    @sampled = sampled
  end

  def foreach_baggage_item
    raise NotImplementedError
  end
end
