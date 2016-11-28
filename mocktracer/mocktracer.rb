require './tracer'
require './mocktracer/mockspan'
require './propagation'

class MockTracer < TracerInterface
  attr_reader :finished_spans, :injectors, :extractors

  def initialize
    @finished_spans = []
    @injectors = {
      text_map: TextMapPropagator.new,
      http_headers: TextMapPropagator.new(true)
    }
  end

  def start_span(op_name)
    MockSpan.new(self, op_name)
  end

  def inject(span_context, format, carrier)
    injector = @injectors[format]
    raise NameError if (!injector)

    injector.inject(span_context, carrier)
  end

  def extract(format, carrier)
  end

  def record_span(span)
    @finished_spans.push(span)
  end

  def reset
    @finished_spans.clear
  end
end
