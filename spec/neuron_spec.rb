# frozen_string_literal: true

require "spec_helper"
require "micrograd/neuron"

RSpec.describe Micrograd::Neuron do
  it do
    expect(Micrograd::Neuron.new(2).call([1, 2]).data).to be_within(1).of(0)
  end

  it "has reader for weights" do
    neuron = Micrograd::Neuron.new(2)
    expect(neuron.weights).to_not be_empty
  end

  it "has reader for bias" do
    neuron = Micrograd::Neuron.new(2)
    expect(neuron.bias).to_not be_nil
  end

  it "has parameters" do
    neuron = Micrograd::Neuron.new(2)
    expect(neuron.parameters).to eq(neuron.weights + [neuron.bias])
  end
end
