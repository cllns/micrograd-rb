# frozen_string_literal: true

module Micrograd
  class TopoSort
    def initialize(start_node)
      @start_node = start_node
    end

    def call
      build(node: @start_node)
    end

    private

    def build(node:, topo: [], visited: [])
      unless visited.include?(node)
        visited << node

        node.previous.each do |child|
          build(node: child, topo:, visited:)
        end

        topo << node
      end
    end
  end
end
