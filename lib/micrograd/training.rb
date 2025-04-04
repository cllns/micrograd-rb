# frozen_string_literal: true

require_relative "mlp"

module Micrograd
  class Training
    attr_reader :mlp, :inputs, :targets

    Result = Data.define(:mlp, :outputs)

    def initialize(layer_sizes:, inputs:, targets:, random: Random.new)
      n_in, *n_outs = layer_sizes
      # TODO: Ensure n_in == inputs.length, n_outs == targets.length
      @mlp = MLP.new(n_in, n_outs, random:)
      @inputs = inputs
      @targets = targets
    end

    def call(epochs:, learning_rate:, verbose: false)
      # Assign the last iterate! result to outputs
      outputs = epochs.times.reduce(nil) do |_, i|
        # Skip the first pass because it's the initialization
        gradient_descent!(learning_rate) unless i == 0

        iterate!((i if verbose))
      end

      print_summary(outputs) if verbose

      Result.new(mlp:, outputs: outputs.map(&:data))
    end

    private

    def iterate!(i)
      outputs = forward_pass
      loss = calculate_loss(outputs)
      loss.backward!
      puts "#{i}: #{loss.data}" if i
      outputs
    end

    def gradient_descent!(learning_rate)
      mlp.parameters.each do |parameter|
        parameter.gradient_step!(learning_rate)
      end
    end

    def forward_pass
      mlp.zero_grad!
      inputs.map { |input| mlp.call(input) }
    end

    def calculate_loss(outputs)
      # Difference of two squares
      targets.zip(outputs).map do |target, output|
        (output - target) ** 2
      end.sum
    end

    def print_summary(outputs)
      puts "Final loss: #{calculate_loss(outputs).data}"
      puts "Targets: #{targets}"
      print "Outputs: "
    end
  end
end
