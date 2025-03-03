# frozen_string_literal: true

module Micrograd
  class Value
    attr_reader :data, :label, :grad, :operation, :previous

    def initialize(data:, label:, backward: -> {}, operation: nil, previous: [])
      @data = data
      @label = label
      @grad = nil
      @backward = backward
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
        backward: lambda {
          self.grad = 1.0
          other.grad = 1.0
        },
        operation: :+,
        previous: [self, other]
      )
    end

    def *(other)
      Value.new(
        data: data * other.data,
        label: "#{label}*#{other.label}".to_sym,
        backward: lambda {
          self.grad = other.data * out.grad,
                      other.grad = data * out.grad
        },
        operation: :*,
        previous: [self, other]
      )
    end

    def tanh
      t = (Math.exp(2 * data) - 1) / (Math.exp(2 * data) + 1)
      # Other valid options
      # Math.tanh(data)
      # (Math.exp(data) - Math.exp(-data)) / (Math.exp(data) + Math.exp(-data))
      Value.new(
        data: t,
        label: "tanh(#{label})".to_sym,
        backward: -> { self.grad = (1 - t**2) * out.grad },
        operation: :tanh,
        previous: [self]
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
