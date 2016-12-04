require 'rack'
require 'sinatra'
require './global_tracer'
require './mocktracer/mocktracer'
require './propagation'
require 'net/http'

GlobalTracer::init_global_tracer(MockTracer.new)
tracer = GlobalTracer::global_tracer

def forward_request(n, headers, tracer)
  uri = URI("http://localhost:4567/#{n+1}")
  http = Net::HTTP.new(uri.host, uri.port)
  r = Net::HTTP::Get.new(uri)
  headers.each do { |k, v| r.add_field(k, v) }
  http.request r
end

get '/1' do
  span = GlobalTracer::start_span('start')
  carrier = HttpHeadersCarrier.new(env)
  tracer.inject(span.context, :http_headers, carrier)

  forward_request(1, env, tracer)
end

get '/2' do
  carrier = HttpHeadersCarrier.new(env)
  parent = tracer.extract(:http_headers, carrier)
  span = tracer.start_span('start', {reference: MockSpanReference.new(parent, :child_of)})
  tracer.inject(span.context, :http_headers, carrier)

  p "parent - trace_id: #{parent.trace_id}, span_id: #{parent.span_id}"
  p "current span - trace_id: #{span.context.trace_id}, span_id: #{span.context.span_id}, parent: #{span.parent_id}"
end
