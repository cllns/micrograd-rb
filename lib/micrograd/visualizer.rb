require "set"
require "open3"

module Micrograd
  class Visualizer
    attr_reader :node, :output_file

    def initialize(node, output_file: "graph.png")
      @node = node
      @output_file = output_file
    end

    def build_graph(node, nodes = {}, edges = [])
      return [nodes, edges] if nodes.key?(node.label)

      new_nodes = nodes.merge(node.label => node)
      new_edges = edges + node.previous.map { |prev| [prev.label, node.label, node.operation] }
      node.previous.reduce([new_nodes, new_edges]) { |acc, prev| build_graph(prev, *acc) }
    end

    def to_d2
      nodes, edges = build_graph(node)
      d2_representation = "direction: right\n"
      d2_representation += nodes.map { |label, node| %(#{label}: "#{label}: #{node.data}") }.join("\n")
      d2_representation += "\n"
      d2_representation += edges.map { |from, to, op| %(#{from} -> #{to}: #{op})}.join("\n")
      d2_representation
    end

    def generate_d2
      File.write("graph.d2", to_d2)
    end
  end
end
