# frozen_string_literal: true

require "spec_helper"
require "micrograd/visualizer"

RSpec.describe Micrograd::Visualizer do
  context "with labels" do
    it "works without backward" do
      a = Micrograd::Value[a: 1]
      b = Micrograd::Value[b: 2]
      c = a + b
      Micrograd::Visualizer.new(c, output_file: "/dev/null").generate_image
    end

    it "works with backward" do
      a = Micrograd::Value[a: 1]
      b = Micrograd::Value[b: 2]
      c = a + b
      c.backward
      Micrograd::Visualizer.new(c, output_file: "/dev/null").generate_image
    end
  end

  context "without labels" do
    it "works without backward" do
      a = Micrograd::Value[1]
      b = Micrograd::Value[2]
      c = a + b
      Micrograd::Visualizer.new(c).generate_image
    end

    it "works with backward" do
      a = Micrograd::Value[a: 1]
      b = Micrograd::Value[b: 2]
      c = a + b
      c.backward
      Micrograd::Visualizer.new(c, output_file: "/dev/null").generate_image
    end
  end
end
