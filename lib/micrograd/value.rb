# frozen_string_literal: true

require_relative "topo_sort"

module Micrograd
  class Value
    attr_reader :data, :label, :grad, :_backward, :operation, :previous

    attr_writer :data

    def initialize(data:, label: nil, operation: nil, previous: [], _backward: -> (_) {})
      @data = data
      @label = label
      @operation = operation
      @previous = previous.to_set
      @_backward = _backward

      @grad = nil
    end

    def self.[](*args, **kwargs)
      if args.size == 1
        label = nil
        data = args.first
      elsif kwargs.size == 1
        label, data = kwargs.first
      else
        raise ArgumentError.new("Provide data or label: data as arg")
      end
      new(label:, data:)
    end

    def id
      self.object_id
    end

    def inspect
      label = self.label.nil? ? "" : ", label: #{self.label.inspect}"
      "Value[data: #{data}#{label}]"
    end

    def +(other)
      unless other.is_a?(Value)
        other = Value[scalar: other]
      end

      Value.new(
        data: self.data + other.data,
        operation: :+,
        previous: [self, other],
        _backward: lambda do |value|
          self.with_grad(value.grad)
          other.with_grad(value.grad)
        end
      )
    end

    def -(other)
      self + (-other)
    end

    def -@
      self * -1
    end

    def *(other)
      unless other.is_a?(Value)
        other = Value[scalar: other]
      end

      Value.new(
        data: self.data * other.data,
        operation: :*,
        previous: [self, other],
        _backward: lambda do |value|
          self.with_grad(other.data * value.grad)
          other.with_grad(self.data * value.grad)
        end
      )
    end

    def /(other)
      self * (other ** -1)
    end

    def **(pow)
      unless pow.is_a?(Numeric)
        raise TypeError.new("Cannot raise #{pow.class} to a power")
      end

      Value.new(
        data: self.data ** pow,
        label: :"**#{pow}",
        operation: :**,
        previous: [self],
        _backward: lambda do |value|
          self.with_grad(value.grad * pow * (self.data ** (pow - 1)))
        end
      )
    end

    def tanh
      t = (Math.exp(2 * self.data) - 1) / (Math.exp(2 * self.data) + 1)
      # Other valid options
      # Math.tanh(self.data)
      # (Math.exp(self.data) - Math.exp(-self.data)) / (Math.exp(self.data) + Math.exp(-self.data))
      Value.new(
        data: t,
        operation: :tanh,
        previous: [self],
        _backward: lambda do |value|
          self.with_grad(value.grad * (1 - (t ** 2)))
        end
      )
    end

    def exp
      Value.new(
        data: Math.exp(self.data),
        operation: :exp,
        previous: [self],
        _backward: lambda do |value|
          self.with_grad(value.grad * value.data)
        end
      )
    end

    def with_label(new_label)
      @label = new_label
      self
    end

    def with_grad(grad)
      @grad ||= 0.0
      @grad += grad
      self
    end

    def zero_grad!
      @grad = 0.0
    end

    def generate_image
      Visualizer.new(self).generate_image
    end

    def backward
      with_grad(1)
      Micrograd::TopoSort.new(self).call.reverse.map { |node| node._backward.call(node) }
    end

    def coerce(other)
      if other.is_a?(Numeric)
        [Value[scalar: other], self]
      else
        raise TypeError.new("Cannot coerce #{other.class} into Value")
      end
    end
  end
end
