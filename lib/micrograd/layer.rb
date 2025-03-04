# frozen_string_literal: true

require_relative "neuron"

module Micrograd
  class Layer
    def initialize(nin, nout)
      @neurons = nout.times.map { Neuron.new(nin) }
    end

    def call(x)
      @neurons.map { |neuron| neuron.call(x) }
    end
  end
end
