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

    def self.[](**args)
      label, data = args.first
      previous = args.fetch(:previous, [])
      new(label: label, data: data, operation: args[:op], previous: previous)
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

    def generate_image
      Visualizer.new(self).generate_image
    end
  end
end
