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
    @entries = Concurrent::Hash.new
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
  @@prefix = 'http_'

  def initialize(headers)
    @headers = headers
  end

  def foreach_key
    return if !block_given?
    @headers.each do |k, v|
      key = k.to_s.downcase
      if key.start_with?(@@prefix)
        key = key[@@prefix.length..-1]
      end
      yield(key.to_sym, v)
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

  def extract(carrier, span_context_klass)
    hash = {}

    carrier.foreach_key do |k, v|
      if [:trace_id, :span_id, :sampled].include? k
        hash[k] = v
      end
    end

    span_context_klass.new(hash[:trace_id], hash[:span_id], hash[:sampled])
  end
end
