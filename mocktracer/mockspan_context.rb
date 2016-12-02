require './span_context'

class MockSpanContext
  include SpanContext
end

class MockSpanReference
  include SpanReference
end
