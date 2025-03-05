# frozen_string_literal: true

require_relative "value"

module Micrograd
  class Neuron
    def initialize(n_in)
      @weights = n_in.times.map { Value[rand(-1.0..1)] }
      @bias = Value[rand(-1.0..1)]
    end

    def call(inputs)
      act = @weights.zip(inputs).map { |weight, input| weight * input }.sum + @bias
      act.tanh
    end
  end
end
