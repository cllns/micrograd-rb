# frozen_string_literal: true

require_relative "topo_sort"

module Micrograd
  class Value
    attr_reader :data, :label, :grad, :_backward, :operation, :previous

    attr_writer :_backward

    def initialize(data:, label:, operation: nil, previous: [])
      @data = data
      @label = label
      @grad = nil
      @_backward = -> {}
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
      ).tap do |value|
        value._backward = lambda do
          self.with_grad(value.grad)
          other.with_grad(value.grad)
        end
      end
    end

    def *(other)
      Value.new(
        data: data * other.data,
        label: "#{label}*#{other.label}".to_sym,
        operation: :*,
        previous: [self, other]
      ).tap do |value|
        value._backward = lambda {
          self.with_grad(other.data * value.grad)
          other.with_grad(data * value.grad)
        }
      end
    end

    def tanh
      t = (Math.exp(2 * data) - 1) / (Math.exp(2 * data) + 1)
      # Other valid options
      # Math.tanh(data)
      # (Math.exp(data) - Math.exp(-data)) / (Math.exp(data) + Math.exp(-data))
      Value.new(
        data: t,
        label: "tanh(#{label})".to_sym,
        operation: :tanh,
        previous: [self]
      ).tap do |value|
        value._backward = lambda do
          self.with_grad(value.grad * (1 - t**2))
        end
      end
    end

    def with_label(new_label)
      @label = new_label
      self
    end

    def with_grad(grad)
      @grad = grad
      self
    end

    def generate_image
      Visualizer.new(self).generate_image
    end

    def backward
      @grad = 1
      Micrograd::TopoSort.new(self).call.reverse.map(&:_backward).map(&:call)
    end
  end
end
