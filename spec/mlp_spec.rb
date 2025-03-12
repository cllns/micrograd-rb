# frozen_string_literal: true

require "spec_helper"
require "micrograd/mlp"

RSpec.describe Micrograd::MLP do
  let(:random) { Random.new(RSpec.configuration.seed) }

  subject(:mlp) { Micrograd::MLP.new(3, [4, 4, 1], random:) }

  it "returns value within expected range of -1 to 1" do
    x = [2.0, 3.0, -1.0]
    expect(mlp.call(x).data).to be_within(1).of(0)
  end

  it "is deterministic when passing specific seed in" do
    x = [2.0, 3.0, -1.0]
    expect(
      described_class.new(3, [4, 4, 1], random: Random.new(123)).call(x).data
    ).to eq(-0.7514151822609686)
  end

  it "has reader for layers" do
    expect(mlp.layers).to_not be_empty
  end

  it "has parameters" do
    expect(mlp.parameters).to eq(
      [
        mlp.layers[0].parameters,
        mlp.layers[1].parameters,
        mlp.layers[2].parameters,
      ].flatten
    )
  end

  it "has 41 parameters" do
    expect(mlp.parameters.length).to eq(41)
  end

  it "has zero_grad!" do
    expect(mlp.parameters.map(&:grad)).to all(be_nil)
    mlp.parameters.each(&:zero_grad!)
    expect(mlp.parameters.map(&:grad)).to all(eq(0))
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

    # Since extracted into Micrograd::Training, but keeping for posterity
    it do
      outputs = inputs.map { |input| mlp.call(input) }

      loss = targets.zip(outputs).map do |target, output|
        (output - target) ** 2
      end.sum

      loss.backward

      puts "0: #{loss.inspect}"

      20.times do |i|
        mlp.parameters.each do |parameter|
          parameter.data += -0.1 * parameter.grad
        end

        outputs = inputs.map { |input| mlp.call(input) }
        loss = targets.zip(outputs).map do |target, output|
          (output - target) ** 2
        end.sum

        mlp.zero_grad!
        loss.backward

        puts "#{i + 1}: #{loss.inspect}"
      end

      puts outputs.map(&:data)
    end
  end
end
