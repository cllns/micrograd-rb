# frozen_string_literal: true

module Micrograd
  class Value
    attr_reader :data, :label, :operation

    def initialize(data:, label:, operation: nil)
      @data = data
      @label = label
      @operation = operation
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
        operation: :+
      )
    end

    def *(other)
      Value.new(
        data: data * other.data,
        label: "#{label}*#{other.label}".to_sym,
        operation: :*
      )
    end
  end
end

