# frozen_string_literal: true

require_relative "value"
require_relative "visualizer"

module Micrograd
  class Examples
    def initialize
      a = Value[a: 2]
      b = Value[b: -3]
      c = Value[c: 10]
      e = (a * b).with_label(:e)
      d = (e + c).with_label(:d)
      f = Value[f: -2]
      loss = (d * f).with_label(:L)

      @node = loss
    end

    def call
      puts "generating image of graph"
      Visualizer.new(@node).generate_image
    end
  end
end

Micrograd::Examples.new.call
