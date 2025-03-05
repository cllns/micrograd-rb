# frozen_string_literal: true

require "spec_helper"
require "micrograd/layer"

RSpec.describe Micrograd::Layer do
  it do
    expect(
      Micrograd::Layer.new(3, 2).call([3, 2, 1]).map(&:data)
    ).to all(be_within(1).of(0))
  end

  it "has reader for neurons" do
    layer = Micrograd::Layer.new(3, 2)
    expect(layer.neurons).to_not be_empty
  end

  it "has parameters" do
    layer = Micrograd::Layer.new(3, 2)

    expect(layer.parameters).to eq(
      [layer.neurons[0].parameters, layer.neurons[1].parameters].flatten
    )
  end
end
