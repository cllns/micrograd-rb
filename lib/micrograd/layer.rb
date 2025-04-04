# frozen_string_literal: true

require_relative "neuron"

module Micrograd
  class Layer
    attr_reader :neurons

    def initialize(n_in, n_out, random: Random.new)
      @neurons = n_out.times.map { Neuron.new(n_in, random:) }
    end

    def call(x)
      outs = neurons.map { |neuron| neuron.call(x) }
      if outs.length == 1
        outs.first
      else
        outs
      end
    end

    def parameters
      neurons.flat_map(&:parameters)
    end
  end
end
