# frozen_string_literal: true

require_relative "layer"

module Micrograd
  class MLP
    attr_reader :layers

    def initialize(n_in, n_outs, random: Random.new)
      size = [n_in] + n_outs
      @layers = n_outs.length.times.map do |i|
        Layer.new(size[i], size[i + 1], random:)
      end
    end

    def call(input)
      layers.inject(input) { |input, layer| layer.call(input) }
    end

    def parameters
      layers.flat_map(&:parameters)
    end
  end
end
