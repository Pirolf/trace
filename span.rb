class Span
  attr_reader :span_context, :tracer, :parent_id

  def context
    @span_context
  end

  def finish
    raise NotImplementedError
  end

  def finish_with_options(opts)
    raise NotImplementedError
  end

	def set_operation_name(operationName)
    raise NotImplementedError
  end

	def set_tag(k, v)
    raise NotImplementedError
  end

	def set_baggage_item(k, v)
    raise NotImplementedError
  end

	def baggage_item(k)
    raise NotImplementedError
  end

	def log(kv_pairs, timestamp)
    raise NotImplementedError
  end
end

class SpanReference
  attr_reader :referenced_context, :reference_type

  def initialize(context, type)
    @referenced_context = context
    @reference_type = type
  end
end
