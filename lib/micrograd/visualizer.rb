# frozen_string_literal: true

require "open3"

module Micrograd
  class Visualizer
    attr_reader :node, :output_file

    def initialize(node, output_file: "graph.svg")
      @node = node
      @output_file = output_file
    end

    def build_graph(node, nodes = {}, edges = [])
      return [nodes, edges] if nodes.key?(node.id)

      new_nodes = nodes.merge(node.id => node)
      new_edges = edges + node.previous.map { |prev| [prev.id, node.id, node.operation] }
      node.previous.reduce([new_nodes, new_edges]) { |acc, prev| build_graph(prev, *acc) }
    end

    def to_d2
      nodes, edges = build_graph(node)
      d2_representation = "direction: right\n"
      d2_representation += nodes.map do |node_id, node|
        %("#{node_id}": "#{node.label}: #{round(node.data)}\\ngrad: #{round(node.grad) || 'nil'}"\n)
      end.join
      d2_representation += edges.map { |from, to, op| %(#{from} -> "#{to}": #{op}\n) }.join
      d2_representation
    end

    def generate_image
      File.write("graph.d2", to_d2)
      _, err, status = Open3.capture3("d2 graph.d2 --layout=elk #{output_file}")
      raise "Error: #{err}" unless status.success?
    end

    def round(float)
      if float.nil?
        "nil"
      else
        format("%.4f", float)
      end
    end
  end
end
