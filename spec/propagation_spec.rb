require './spec/spec_helper'

RSpec.describe 'Propagation' do
  require './propagation'
  require './span_context'
  require 'net/http'
  require 'webmock/rspec'
  class TestSpanContext
    include SpanContext
  end

  let(:default_propagator) { @textMapPropagator = TextMapPropagator.new }
  let(:http_headers_propagator) { @textMapPropagator = TextMapPropagator.new(true) }

  describe 'TextMapPropagator' do
    describe '#initialize' do
      context 'when http_headers is not set' do
        before(:each) { default_propagator }

        it 'http_headers is false' do
          expect(@textMapPropagator.http_headers).to be(false)
        end
      end

      context 'when http_headers is set' do
        before(:each) { http_headers_propagator }

        it 'http_headers is true' do
          expect(@textMapPropagator.http_headers).to be(true)
        end
      end
    end

    describe '#inject' do
      let(:setup_params) do
        @span_context = TestSpanContext.new('some-trace-id', 'some-span-id')
        @carrier = TextMapCarrier.new
      end

      before(:each) do
        default_propagator
        setup_params
      end

      #TODO: keys should be configurable
      it 'sets trace_id, span_id, and sampled' do
        expect(@carrier).to receive(:set) do |f, s|
            expect(f).to eq('trace_id')
            expect(s).to eq(@span_context.trace_id)
        end

        expect(@carrier).to receive(:set) do |f, s|
          expect(f).to eq('span_id')
          expect(s).to eq(@span_context.span_id)
        end

        expect(@carrier).to receive(:set) do |f, s|
          expect(f).to eq('sampled')
          expect(s).to eq(@span_context.sampled)
        end

        @textMapPropagator.inject(@span_context, @carrier)
      end
    end

    describe '#extract' do
      before(:each) do
        default_propagator

        @carrier = TextMapCarrier.new
        @carrier.set('trace_id', 'some-trace_id')
        @carrier.set('span_id', 'some-span_id')
        @carrier.set('sampled', true)
      end

      it 'returns span context with trace_id, span_id, and sampled' do
        spanContext = @textMapPropagator.extract(@carrier, MockSpanContext)

        expect(spanContext.trace_id).to eq('some-trace_id')
        expect(spanContext.span_id).to eq('some-span_id')
        expect(spanContext.sampled).to eq(true)
      end
    end
  end

  describe 'TextMapCarrier' do
    before(:each) { @textMapCarrier = TextMapCarrier.new }
    describe '#foreach_key' do
      context 'when block is given' do
        before(:each) do
          @textMapCarrier.set('k1', 'v1')
          @textMapCarrier.set('k2', 'v2')
        end

        it 'yield for each key value pair' do
          expect{ |b| @textMapCarrier.foreach_key(&b) }.to yield_successive_args([:k1, 'v1'], [:k2, 'v2'])
        end
      end

      context 'when block is not given' do
        it 'does nothing' do
          expect{ @textMapCarrier.foreach_key }.not_to raise_error
        end
      end
    end

    describe '#set' do
      it 'adds k, v pair to entries' do
        @textMapCarrier.set('k', 'v')
        expect(@textMapCarrier.entries).to eq({k: 'v'})
      end
    end
  end

  describe 'HttpHeadersCarrier' do
    before(:each) do
      stub_request(:any, 'www.example.com')
      @req = Net::HTTP::Get.new(URI('http://www.example.com'))
      @req.initialize_http_header({foo: "bar", meow: 'cat'})
      @httpHeadersCarrier = HttpHeadersCarrier.new(@req)
    end

    describe '#foreach_key' do
      context 'when block is given' do
        it 'yield for each key value pair' do
          expect{ |b| @httpHeadersCarrier.foreach_key(&b) }.to yield_successive_args([:foo, 'bar'], [:meow, 'cat'])
        end
      end

      context 'when block is not given' do
        it 'does nothing' do
          expect{ @httpHeadersCarrier.foreach_key }.not_to raise_error
        end
      end
    end

    describe '#set' do
      it 'adds to headers' do
        @httpHeadersCarrier.set('k', 'v')
        expect(@httpHeadersCarrier.headers.to_hash).to eq({foo: ["bar"], meow: ['cat'], k: ['v']})
      end
    end
  end
end
