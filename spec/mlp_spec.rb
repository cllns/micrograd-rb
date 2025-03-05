# frozen_string_literal: true

require "spec_helper"
require "micrograd/mlp"

RSpec.describe Micrograd::MLP do
  it do
    x = [2.0, 3.0, -1.0]
    mlp = Micrograd::MLP.new(3, [4, 4, 1])
    expect(mlp.call(x).data).to eq(-0.9611534134128307)
  end

  it "has reader for layers" do
    mlp = Micrograd::MLP.new(3, [4, 4, 1])
    expect(mlp.layers).to_not be_empty
  end
end
