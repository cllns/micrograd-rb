# frozen_string_literal: true

module Micrograd
  class Value
    attr_reader :data, :label, :operation, :previous

    def initialize(data:, label:, operation: nil, previous: [])
      @data = data
      @label = label
      @operation = operation
      @previous = previous.to_set
    end

    def self.[](**input)
      raise ArgumentError, "Expected a single key-value pair" unless input.size == 1

      label, data = input.first
      new(label: label, data: data)
    end

    def +(other)
      Value.new(
        data: data + other.data,
        label: "#{label}+#{other.label}".to_sym,
        operation: :+,
        previous: [self, other]
      )
    end

    def *(other)
      Value.new(
        data: data * other.data,
        label: "#{label}*#{other.label}".to_sym,
        operation: :*,
        previous: [self, other]
      )
    end

    def with_label(new_label)
      @label = new_label
      self
    end

    def generate_image
      Visualizer.new(self).generate_image
    end
  end
end
