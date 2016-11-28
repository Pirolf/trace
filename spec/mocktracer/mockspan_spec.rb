require './spec/spec_helper'

RSpec.describe 'MockSpan' do
  require './mocktracer/mockspan'

  before(:each) do
    @mocktracer = double('tracer')
    @name = 'span-name'
    @mockspan = MockSpan.new(@mocktracer, @name)
  end

  describe '#initialize' do
    it 'sets the span name and tracer' do
      expect(@mockspan.operation_name).to be(@name)
      expect(@mockspan.tracer).to eq(@mocktracer)
    end
  end

  describe '#finish' do
    before(:each) do
      @mockTime = double('mockTime')
      allow(Time).to receive(:now).and_return(@mockTime)
    end

    it 'sets finish time' do
      @mockspan.finish
      expect(@mockspan.finish_time).to eq(@mockTime)
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
