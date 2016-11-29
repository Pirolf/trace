require './span_context'

module TextMapWriter
  def set(k, v)
    raise NotImplementedError
  end
end

module TextMapReader
	def foreach_key
    raise NotImplementedError
  end
end

class TextMapCarrier
  include TextMapReader
  include TextMapWriter
  attr_reader :entries

  def initialize
    @entries = {}
  end

  def foreach_key
    return if !block_given?
    @entries.each_pair do |k, v|
      yield(k, v)
    end
  end

  def set(k, v)
    @entries[k.to_sym] = v
  end
end

class HttpHeadersCarrier
  include TextMapReader
  include TextMapWriter
  attr_reader :headers

  def initialize(headers)
    @headers = headers
  end

  def foreach_key
    return if !block_given?
    @headers.each_header do |k, v|
      yield(k, v)
    end
  end

  def set(k, v)
    @headers[k.to_sym] = v
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
    hash = {}

    carrier.foreach_key do |k, v|
      if [:trace_id, :span_id, :sampled].include? k
        hash[k] = v
      end
    end

    SpanContext.new(hash[:trace_id], hash[:span_id], hash[:sampled])
  end
end
