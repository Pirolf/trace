require './spec/spec_helper'

RSpec.describe 'SpanContext' do
  require './span_context'
  class TestSpanContext
    include SpanContext
  end

  describe '#initialize' do
    it 'sets attributes' do
      sc = TestSpanContext.new('some-trace-id', 'some-span-id', true, {item: 'val'})
      expect(sc).to have_attributes({trace_id: 'some-trace-id', span_id: 'some-span-id', sampled: true, baggage: {item: 'val'}})
    end

    it 'defaults sampled and baggae' do
      sc = TestSpanContext.new('some-trace-id', 'some-span-id')
      expect(sc).to have_attributes({sampled: false, baggage: {}})
    end
  end

  describe '#foreach_baggage_item' do
    before(:each) do
      @sc = TestSpanContext.new('some-trace-id', 'some-span-id', true, {item1: 'val1', item2: 'val2'})
    end

    context 'when block is given' do
      it 'yield for each key value pair' do
        expect{ |b| @sc.foreach_baggage_item(&b) }.to yield_successive_args([:item1, 'val1'], [:item2, 'val2'])
      end
    end

    context 'when block is not given' do
      it 'does nothing' do
        expect{ @sc.foreach_baggage_item }.not_to raise_error
      end
    end
  end
end
