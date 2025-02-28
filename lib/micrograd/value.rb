# frozen_string_literal: true

module Micrograd
  class Value
    attr_reader :data, :label

    def initialize(data:, label:)
      @data = data
      @label = label
    end

    def self.[](**input)
      raise ArgumentError, "Expected a single key-value pair" unless input.size == 1

      label, data = input.first
      new(label: label, data: data)
    end
  end
end

