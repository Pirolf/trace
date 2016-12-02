require 'concurrent'

module SpanContext
  attr_accessor :trace_id, :span_id, :sampled, :baggage

  def initialize(trace_id, span_id, sampled = false, baggage = Concurrent::Hash.new)
    @trace_id = trace_id
    @span_id = span_id
    @sampled = sampled
    @baggage = baggage
  end

  def foreach_baggage_item
    return if !block_given?
    @baggage.each_pair do |k, v|
      yield(k, v)
    end
  end
end
