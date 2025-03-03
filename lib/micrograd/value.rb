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
      raise ArgumentError.new("Expected a single key-value pair") unless input.size == 1

      label, data = input.first
      new(label:, data:)
    end

    def +(other)
      unless other.is_a?(Value)
        other = Value[:"scalar_#{other}" => other]
      end

      Value.new(
        data: data + other.data,
        label: :"#{label}+#{other.label}",
        operation: :+,
        previous: [self, other]
      ).tap do |value|
        value._backward = lambda do
          with_grad(value.grad)
          other.with_grad(value.grad)
        end
      end
    end

    def -(other)
      self + (-other)
    end

    def -@
      self * -1
    end

    def *(other)
      unless other.is_a?(Value)
        other = Value[:"scalar_#{other}" => other]
      end

      Value.new(
        data: data * other.data,
        label: :"#{label}*#{other.label}",
        operation: :*,
        previous: [self, other]
      ).tap do |value|
        value._backward = lambda {
          with_grad(other.data * value.grad)
          other.with_grad(data * value.grad)
        }
      end
    end

    def /(other)
      self * (other ** -1)
    end

    def **(pow)
      unless pow.is_a?(Numeric)
        raise TypeError.new("Cannot raise #{pow.class} to a power")
      end

      Value.new(
        data: data ** pow,
        label: :"#{label}**#{pow}",
        operation: :**,
        previous: [self]
      ).tap do |value|
        value._backward = lambda do
          with_grad(value.grad * pow * (data ** (pow - 1)))
        end
      end
    end

    def tanh
      t = (Math.exp(2 * data) - 1) / (Math.exp(2 * data) + 1)
      # Other valid options
      # Math.tanh(data)
      # (Math.exp(data) - Math.exp(-data)) / (Math.exp(data) + Math.exp(-data))
      Value.new(
        data: t,
        label: :"tanh(#{label})",
        operation: :tanh,
        previous: [self]
      ).tap do |value|
        value._backward = lambda do
          with_grad(value.grad * (1 - (t ** 2)))
        end
      end
    end

    def exp
      Value.new(
        data: Math.exp(data),
        label: :"exp(#{label})",
        operation: :exp,
        previous: [self]
      ).tap do |value|
        value._backward = lambda do
          with_grad(value.grad * value.data)
        end
      end
    end

    def with_label(new_label)
      @label = new_label
      self
    end

    def with_grad(grad)
      @grad ||= 0
      @grad += grad
      self
    end

    def generate_image
      Visualizer.new(self).generate_image
    end

    def backward
      @grad = 1
      Micrograd::TopoSort.new(self).call.reverse.map(&:_backward).map(&:call)
    end

    def coerce(other)
      if other.is_a?(Numeric)
        [Value[:"scalar_#{other}" => other], self]
      else
        raise TypeError.new("Cannot coerce #{other.class} into Value")
      end
    end
  end
end
