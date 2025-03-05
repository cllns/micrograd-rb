# frozen_string_literal: true

require_relative "value"

module Micrograd
  class Neuron
    attr_reader :weights, :bias

    def initialize(n_in, random: Random.new)
      @weights = n_in.times.map { Value[random.rand(-1.0..1)] }
      @bias = Value[random.rand(-1.0..1)]
    end

    def call(inputs)
      act = weights.zip(inputs).map { |weight, input| weight * input }.sum + bias
      act.tanh
    end

    def parameters
      weights + [bias]
    end
  end
end
