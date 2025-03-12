# frozen_string_literal: true

require "open3"

module Micrograd
  class Visualizer
    attr_reader :node, :output_file

    def initialize(node, output_file: "graph.svg")
      @node = node
      @output_file = output_file
    end

    def generate_image
      Open3.popen3("d2", "-", "--layout=elk") do |stdin, stdout, stderr, wait_thr|
        stdin.puts(to_d2)
        stdin.close

        if wait_thr.value.success?
          File.write(output_file, stdout.read)
        else
          raise "Error: #{stderr}"
        end
      end
    end

    private

    def to_d2
      nodes, edges = build_graph(node)
      d2_representation = "direction: right\n"
      d2_representation += nodes.map do |node_id, node|
        label_or_operation = node.label || node.operation
        rounded_data = round(node.data)
        grad_line = "grad: #{round(node.grad)}" if node.grad
        data_line = [label_or_operation, rounded_data].compact.join(": ")
        contents = [data_line, grad_line].compact.join("\\n")
        %("#{node_id}": #{contents}\n)
      end.join
      d2_representation += edges.map { |from, to, op| %(#{from} -> "#{to}": #{op}\n) }.join
      d2_representation
    end

    def build_graph(node, nodes = {}, edges = [])
      return [nodes, edges] if nodes.key?(node.id)

      new_nodes = nodes.merge(node.id => node)
      new_edges = edges + node.previous.map { |prev| [prev.id, node.id, node.operation] }
      node.previous.reduce([new_nodes, new_edges]) { |acc, prev| build_graph(prev, *acc) }
    end

    def round(float)
      format("%.4f", float)
    end
  end
end
