class TextMapWriter
  def set(k, v)
    raise NotImplementedError
  end
end

class TextMapPropagator
  attr_reader :http_headers

  def initialize(http_headers = false)
    @http_headers = http_headers
  end

  def inject(span_context, carrier)
    ['trace_id', 'span_id', 'sampled'].each do |k|
      carrier.set(k, span_context.send(k))
    end
  end

  def extract(carrier)
  end
end
