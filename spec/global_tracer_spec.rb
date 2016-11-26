require './spec/spec_helper'

RSpec.describe 'GlobalTracer' do
  require './noop'
  require './global_tracer'

  describe 'when tracer is provided' do
    let(:tracer) { @tracer = instance_double('TracerInterface') }

    it 'initializes singleton global tracer' do
      GlobalTracer::init_global_tracer(tracer)
      expect(GlobalTracer::global_tracer).to eq @tracer
    end

    it "delegates start_span" do
      span = double('span')
      GlobalTracer::init_global_tracer(tracer)
      expect(@tracer).to receive(:start_span).with(span)
      GlobalTracer::start_span(span)
    end
  end

  it 'returns noop tracer by default' do
    expect(GlobalTracer::global_tracer).to be_instance_of(Noop)
  end
end
