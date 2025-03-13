# frozen_string_literal: true

require_relative "value"
require_relative "visualizer"

module Micrograd
  class Examples
    def initialize
      x1 = Value[x1: 2]
      x2 = Value[x2: 0]
      w1 = Value[w1: -3]
      w2 = Value[w2: 1]
      b = Value[b: 6.8813735870195432]

      x1w1 = (x1 * w1).with_label(:x1w1)
      x2w2 = (x2 * w2).with_label(:x2w2)

      x1w1x2w2 = (x1w1 + x2w2).with_label(:x1w1x2w2)
      n = (x1w1x2w2 + b).with_label(:n)

      # o = n.tanh.with_label(:o)
      # Or, the equivalent implemented from our operations:
      e = (2 * n).exp
      o = (e - 1) / (e + 1)

      o.backward!

      @node = o
    end

    def call
      puts "generating image of graph"
      Visualizer.new(@node).generate_image
    end

    # First version had initializer with:
    #  a = Value[a: 2]
    #  b = Value[b: -3]
    #  c = Value[c: 10]
    #  e = (a * b).with_label(:e)
    #  d = (e + c).with_label(:d)
    #  f = Value[f: -2]
    #  loss = (d * f).with_label(:L)
    #  @node = loss
  end
end

Micrograd::Examples.new.call
