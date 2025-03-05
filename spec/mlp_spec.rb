# frozen_string_literal: true

require "spec_helper"
require "micrograd/mlp"

RSpec.describe Micrograd::MLP do
  let(:random) { Random.new(RSpec.configuration.seed) }

  subject { Micrograd::MLP.new(3, [4, 4, 1], random:) }

  it "returns value within expected range of -1 to 1" do
    x = [2.0, 3.0, -1.0]
    expect(subject.call(x).data).to be_within(1).of(0)
  end

  it "is deterministic when passing specific seed in" do
    x = [2.0, 3.0, -1.0]
    expect(
      described_class.new(3, [4, 4, 1], random: Random.new(123)).call(x).data
    ).to eq(-0.7514151822609686)
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

    let(:inputs) do
      [
        [2.0, 3.0, -1.0],
        [3.0, -1.0, 0.5],
        [0.5, 1.0, 1.0],
        [1.0, 1.0, -1.0],
      ]
    end

    let(:targets) do
      [1.0, -1.0, -1.0, 1.0]
    end

    let(:random) { Random.new(12345678) }
    # Gives us a loss of 5.2, which is close to his example of 4.8
    # https://youtu.be/VMj-3S1tku0?feature=shared&t=7282

    it do
      outputs = inputs.map { |input| subject.call(input) }

      loss = targets.zip(outputs).map do |target, output|
        (output - target) ** 2
      end.sum

      loss.backward

      p mlp.layers.first.neurons.first.weights.first.grad
    end
  end
end
