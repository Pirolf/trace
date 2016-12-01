require './spec/spec_helper'

RSpec.describe 'MockSpan' do
  require './mocktracer/mockspan'
  require './span_context'
  require './span'
  require 'uuid'

  let(:mock_time) do
    @mockTime = double('mockTime')
    allow(Time).to receive(:now).and_return(@mockTime)
  end

  before(:each) do
    @mocktracer = spy('tracer')
    @name = 'span-name'
    @mockspan = MockSpan.new(@mocktracer, @name)
  end

  describe '#initialize' do
    it 'sets the span name and tracer' do
      expect(@mockspan.operation_name).to be(@name)
      expect(@mockspan.tracer).to eq(@mocktracer)
    end

    describe 'span context' do
      let(:fake_span_id) do
        @span_id = 'some-span-id'
        allow(UUID).to receive(:generate).and_return(@span_id)
      end

      context 'when there is no reference' do
        let(:fake_trace_id) do
          @trace_id = 'some-trace-id'
          allow(UUID).to receive(:generate).and_return(@trace_id)
        end

        it 'generates a new trace id' do
          fake_trace_id
          @mockspan = MockSpan.new(@mocktracer, @name)
          expect(@mockspan.span_context.trace_id).to eq(@trace_id)
        end

        it 'generates a new span id' do
          fake_span_id
          @mockspan = MockSpan.new(@mocktracer, @name)
          expect(@mockspan.span_context.span_id).to eq(@span_id)
        end

        it 'sets parent id to -' do
          @mockspan = MockSpan.new(@mocktracer, @name)
          expect(@mockspan.parent_id).to eq('-')
        end
      end

      context 'when there is a reference' do
        before(:each) do
          context = SpanContext.new('some-trace-id', 'some-span_id')
          @reference = SpanReference.new(context, :child_of)
          fake_span_id
          @mockspan = MockSpan.new(@mocktracer, @name, {reference: @reference})
        end

        it 'inherits the trace id' do
          expect(@mockspan.span_context.trace_id).to eq('some-trace-id')
        end

        it 'generates a new span id' do
          expect(@mockspan.span_context.span_id).to eq(@span_id)
        end

        it 'sets referenced span as parent' do
          expect(@mockspan.parent_id).to eq('some-span_id')
        end
      end
    end

    context 'when start_time is given in the options' do
      it 'sets start_time with the optional start_time' do
        mock_start_time = double('mock start_time')
        @mockspan = MockSpan.new(@mocktracer, @name, {start_time: mock_start_time})
        expect(@mockspan.start_time).to eq(mock_start_time)
      end
    end

    context 'when start_time is not given in the options' do
      before(:each) { mock_time }
      it 'sets start_time with now' do
        @mockspan = MockSpan.new(@mocktracer, @name)
        expect(@mockspan.start_time).to eq(@mockTime)
      end
    end
  end

  describe '#finish' do
    before(:each) do
      mock_time
      allow(@mocktracer).to receive(:record_span)
    end

    it 'sets finish time' do
      @mockspan.finish
      expect(@mockspan.finish_time).to eq(@mockTime)
    end

    it 'signals tracer' do
      @mockspan.finish
      expect(@mocktracer).to have_received(:record_span).once.with(@mockspan)
    end

    context 'when finish_time is given in the options' do
      it 'sets finish time with it' do
        @mockspan.finish finish_time: 'some-finish-time'
        expect(@mockspan.finish_time).to eq('some-finish-time')
      end
    end
  end

  describe '#set_operation_name' do
    it 'sets operation name and returns updated span' do
      op_name = 'some-op-name'
      span = @mockspan.set_operation_name(op_name)
      expect(span.operation_name).to be(op_name)
    end
  end
end
