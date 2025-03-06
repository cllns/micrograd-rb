# frozen_string_literal: true

# frozen_string_literal

require "spec_helper"
require "micrograd/training"

RSpec.describe Micrograd::Training do
  # let(:random) { Random.new(RSpec.configuration.seed) }
  let(:random) { Random.new(12345) }

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

    subject(:training) do
      Micrograd::Training.new(
        layer_sizes: [3, 4, 4, 1],
        random:,
        inputs:,
        targets:
      )
    end

    it do
      p training.call(epochs: 20, learning_rate: 0.05, verbose: true)
    end
  end
end
