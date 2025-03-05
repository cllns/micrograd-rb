# frozen_string_literal: true

require "spec_helper"
require "micrograd/mlp"

RSpec.describe Micrograd::MLP do
  subject { Micrograd::MLP.new(3, [4, 4, 1]) }

  it do
    x = [2.0, 3.0, -1.0]
    expect(subject.call(x).data).to be_within(1).of(0)
  end

  it "has reader for layers" do
    expect(subject.layers).to_not be_empty
  end

  it "has parameters" do
    expect(subject.parameters).to eq(
      [
        subject.layers[0].parameters,
        subject.layers[1].parameters,
        subject.layers[2].parameters,
      ].flatten
    )
  end

  it "has 41 parameters" do
    expect(subject.parameters.length).to eq(41)
  end

  describe "a tiny dataset" do
    # Example from: https://youtu.be/VMj-3S1tku0?feature=shared&t=6664

    it do
      inputs = [
        [2.0, 3.0, -1.0],
        [3.0, -1.0, 0.5],
        [0.5, 1.0, 1.0],
        [1.0, 1.0, -1.0],
      ]

      targets = [1.0, -1.0, -1.0, 1.0]

      outputs = inputs.map { |input| subject.call(input) }

      loss = targets.zip(outputs).map do |target, output|
        (output - target) ** 2
      end.sum

      loss.backward

      p subject.layers.first.neurons.first.weights.first.grad
    end
  end
end
