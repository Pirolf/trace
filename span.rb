class Span
  def finish
    raise NotImplementedError
  end

  def finish_with_options(opts)
    raise NotImplementedError
  end

	def context
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

	def tracer
    raise NotImplementedError
  end

	def log(kv_pairs, timestamp)
    raise NotImplementedError
  end
end
