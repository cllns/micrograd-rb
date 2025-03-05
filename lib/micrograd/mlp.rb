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
      input
    end
  end
end
