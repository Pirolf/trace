module Span
  def finish
  end

  def finish_with_options(opts)
  end

	def context
  end

	def set_operation_name(operationName)
  end

	def set_tag(k, v)
  end

	def set_baggage_item(k, v)
  end

	def baggage_item(k)
  end

	def tracer
  end

	def log(kv_pairs, timestamp)
  end
end
