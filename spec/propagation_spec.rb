require './spec/spec_helper'

RSpec.describe 'Propagation' do
  require './propagation'
  require './span_context'

  describe 'TextMapPropagator' do
    let(:default_propagator) { @textMapPropagator = TextMapPropagator.new }
    let(:http_headers_propagator) { @textMapPropagator = TextMapPropagator.new(true) }

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
        @span_context = SpanContext.new('some-trace-id', 'some-span-id')
        @carrier = TextMapWriter.new
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
  end
end
