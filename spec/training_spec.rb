# frozen_string_literal: true

# frozen_string_literal

require "spec_helper"

RSpec.describe Micrograd::Training do
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

    it "returns results without printing to stdout" do
      result = training.call(epochs: 20, learning_rate: 0.1)
      expect(result).to eq(
        [
          0.8920758724901439,
          -0.8269374284014038,
          -0.932803596534813,
          0.8634266452660331,
        ]
      )
    end

    it "has verbose option that does print to stdout" do
      expect { training.call(epochs: 20, learning_rate: 0.1, verbose: true) }.to output(
        <<~OUT.chomp
          0: 5.880817830998961
          1: 3.714337425993763
          2: 3.240431842900067
          3: 2.9181656515317216
          4: 2.987536606848577
          5: 2.482341393052873
          6: 2.3283368887312985
          7: 2.0900121473671005
          8: 2.8252008622822244
          9: 0.7348034808421076
          10: 0.4557900858144743
          11: 0.26542995735252733
          12: 0.1909861343585164
          13: 0.15182318273234666
          14: 0.1254869191059634
          15: 0.10646394608908546
          16: 0.09212809977887804
          17: 0.08096558465470402
          18: 0.07204557385098528
          19: 0.06476590884902907
          Final loss: 0.06476590884902907
          Targets: [1.0, -1.0, -1.0, 1.0]
          Outputs:\x20
        OUT
      ).to_stdout
    end
  end
end
