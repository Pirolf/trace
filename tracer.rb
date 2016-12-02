module TracerInterface
  def start_span(op_name)
    raise NotImplementedError
  end

  def inject(span_context, format, carrier)
    raise NotImplementedError
  end

  def extract(format, carrier)
    raise NotImplementedError
  end
end
