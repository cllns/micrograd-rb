# frozen_string_literal: true

require "spec_helper"
require "micrograd/value"
require "micrograd/visualizer"

RSpec.describe Micrograd::Visualizer do
  describe "#generate_image" do
    describe "simple examples" do
      context "with labels" do
        it "works without backward" do
          a = Micrograd::Value[a: 1]
          b = Micrograd::Value[b: 2]
          c = a + b
          expect {
            Micrograd::Visualizer.new(c, output_file: "/dev/null").generate_image
          }.to_not raise_error
        end

        it "works with backward" do
          a = Micrograd::Value[a: 1]
          b = Micrograd::Value[b: 2]
          c = a + b
          c.backward!
          expect {
            Micrograd::Visualizer.new(c, output_file: "/dev/null").generate_image
          }
        end
      end

      context "without labels" do
        it "works without backward" do
          a = Micrograd::Value[1]
          b = Micrograd::Value[2]
          c = a + b
          expect {
            Micrograd::Visualizer.new(c, output_file: "/dev/null").generate_image
          }
        end

        it "works with backward" do
          a = Micrograd::Value[a: 1]
          b = Micrograd::Value[b: 2]
          c = a + b
          c.backward!
          expect {
            Micrograd::Visualizer.new(c, output_file: "/dev/null").generate_image
          }
        end
      end
    end

    describe "complex examples" do
      it "works with backward" do
        a = Micrograd::Value[a: 1]
        b = Micrograd::Value[b: 2]
        c = a * b
        d = c + 1
        e = d ** 2
        f = e - 3
        g = f / 2
        h = -g
        i = h.tanh
        i.backward!
        expect {
          Micrograd::Visualizer.new(c, output_file: "/dev/null").generate_image
        }
      end
    end
  end
end
