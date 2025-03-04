# frozen_string_literal: true

require_relative "value"

module Micrograd
  class Neuron
    def initialize(nin)
      @w = nin.times.map { Value[rand => rand(-1.0..1)] }
      @b = Value[rand => rand(-1.0..1)]
    end

    def call(x)
      act = @w.zip(x).map { |w_, x_| w_ * x_ }.sum + @b
      act.tanh
    end
  end
end
