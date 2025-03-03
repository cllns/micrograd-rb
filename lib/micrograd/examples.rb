# frozen_string_literal: true

require_relative "value"
require_relative "visualizer"

module Micrograd
  class Examples
    def initialize
      a = Value[a: 2]
      b = Value[b: -3]
      c = Value.new(data: -6, label: :c, previous: [a, b], operation: :*)
      @node = c
    end

    def call
      p "gen image"
      Visualizer.new(@node).generate_image
    end
  end
end

Micrograd::Examples.new.call
