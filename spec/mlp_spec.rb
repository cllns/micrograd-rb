# frozen_string_literal: true

require "spec_helper"
require "micrograd/mlp"

RSpec.describe Micrograd::MLP do
  it do
    x = [2.0, 3.0, -1.0]
    mlp = Micrograd::MLP.new(3, [4, 4, 1])
    expect(mlp.call(x).data).to be_within(1).of(0)
  end

  it "has reader for layers" do
    mlp = Micrograd::MLP.new(3, [4, 4, 1])
    expect(mlp.layers).to_not be_empty
  end

  describe "a tiny dataset" do
    # Example from: https://youtu.be/VMj-3S1tku0?feature=shared&t=6664

    it do
      mlp = Micrograd::MLP.new(3, [4, 4, 1])

      inputs = [
        [2.0, 3.0, -1.0],
        [3.0, -1.0, 0.5],
        [0.5, 1.0, 1.0],
        [1.0, 1.0, -1.0],
      ]

      targets = [1.0, -1.0, -1.0, 1.0]

      outputs = inputs.map { |input| mlp.call(input) }

      loss = targets.zip(outputs).map do |target, output|
        (output - target) ** 2
      end.sum

      loss.backward

      p mlp.layers.first.neurons.first.weights.first.grad
    end
  end
end
