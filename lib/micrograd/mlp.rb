# frozen_string_literal: true

require_relative "layer"

module Micrograd
  class MLP
    def initialize(n_in, n_outs)
      size = [n_in] + n_outs
      @layers = n_outs.length.times.map { |i| Layer.new(size[i], size[i + 1]) }
    end

    def call(input)
      @layers.each { |layer| input = layer.call(input) }
    end
  end
end

x = [2.0, 3.0, -1.0]
n = Micrograd::MLP.new(3, [4, 4, 1])
p n.call(x)
