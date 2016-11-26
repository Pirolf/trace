require './noop'

module GlobalTracer
  @@global_tracer_singleton = Noop.new
  def self.init_global_tracer(tracer)
    @@global_tracer_singleton = tracer
  end

  def self.global_tracer
    @@global_tracer_singleton
  end

  def self.start_span(span)
    p span
    @@global_tracer_singleton.start_span(span)
  end
end
