# frozen_string_literal: true

# frozen_string_literal

require "micrograd/value"
require "micrograd/topo_sort"
require "micrograd/mlp"

module Micrograd
  class Training
    attr_reader :mlp, :inputs, :targets

    def initialize(layer_sizes:, inputs:, targets:, random: Random.new)
      p random.seed
      # TODO: make sure sizes match up
      n_in, *n_outs = layer_sizes
      @mlp = MLP.new(n_in, n_outs, random:)
      @inputs = inputs
      @targets = targets
    end

    def call(epochs:, learning_rate:, verbose: false)
      outputs = forward_pass
      loss = calculate_loss(outputs)
      loss.backward

      puts "0: #{loss.inspect}" if verbose

      epochs.times do |i|
        mlp.parameters.each do |parameter|
          parameter.data += -1 * learning_rate * parameter.grad
        end

        outputs = forward_pass
        loss = calculate_loss(outputs)
        loss.backward

        puts "#{i + 1}: #{loss.inspect}" if verbose
      end

      outputs.map(&:data)
    end

    private

    def forward_pass
      mlp.zero_grad!
      inputs.map { |input| mlp.call(input) }
    end

    def calculate_loss(outputs)
      targets.zip(outputs).map do |target, output|
        (output - target) ** 2
      end.sum
    end
  end
end
