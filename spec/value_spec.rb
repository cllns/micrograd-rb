# frozen_string_literal: true

require "spec_helper"

RSpec.describe Micrograd::Value do
  describe "constructors" do
    it "has data and label attributes" do
      value = Micrograd::Value.new(data: 1, label: :a)

      expect(value.data).to eq(1)
      expect(value.label).to eq(:a)
    end

    it "can have operation" do
      value = Micrograd::Value.new(data: 1, label: :a, operation: :+)
      expect(value.operation).to eq(:+)
    end

    it "can have previous (passed in as an array, converted to set)" do
      previous1 = Micrograd::Value.new(data: 1, label: :a)
      previous2 = Micrograd::Value.new(data: 2, label: :b)
      value = Micrograd::Value.new(data: 3, label: :c, previous: Set[previous1, previous2])
      expect(value.previous).to eq(Set[previous1, previous2])
    end

    it "supports bracket short-hand constructor with value" do
      value = Micrograd::Value[a: 123]
      expect(value.data).to eq(123)
      expect(value.label).to eq(:a)
    end

    it "supports bracket short-hand constructor without value" do
      value = Micrograd::Value[123]
      expect(value.data).to eq(123)
      expect(value.label).to be_nil
    end
  end

  describe "operations" do
    it "supports addition" do
      a = Micrograd::Value[a: 1]
      b = Micrograd::Value[b: 2]
      value = a + b
      expect(value.data).to eq(3)
      expect(value.label).to eq(:"a+b")
      expect(value.operation).to eq(:+)
      expect(value.previous).to eq(Set[a, b])
    end

    it "supports subtraction" do
      a = Micrograd::Value[a: 1]
      b = Micrograd::Value[b: 2]
      value = a - b
      expect(value.data).to eq(-1)
      expect(value.label).to eq(:"a+b*scalar_-1")
      expect(value.operation).to eq(:+)
      # Skipping #previous test because it's two operations chained together
    end

    it "supports multiplication" do
      a = Micrograd::Value[a: 2]
      b = Micrograd::Value[b: 3]
      value = a * b
      expect(value.data).to eq(6)
      expect(value.label).to eq(:"a*b")
      expect(value.operation).to eq(:*)
      expect(value.previous).to eq(Set[a, b])
    end

    it "supports division" do
      a = Micrograd::Value[a: 6]
      b = Micrograd::Value[b: 3]
      value = a / b
      expect(value.data).to eq(2)
      # This is weird but due to how we handle division
      expect(value.label).to eq(:"a*b**-1")
      expect(value.operation).to eq(:*)
      # Skipping #previous test because it's two operations chained together
    end

    it "supports power" do
      a = Micrograd::Value[a: 2]
      value = a ** 3
      expect(value.data).to eq(8)
      expect(value.label).to eq(:"a**3")
      expect(value.operation).to eq(:**)
      expect(value.previous).to eq(Set[a])
    end

    it "supports tanh" do
      a = Micrograd::Value[a: 1]
      value = a.tanh
      expect(value.data).to eq(0.7615941559557649)
      expect(value.label).to eq(:"tanh(a)")
      expect(value.operation).to eq(:tanh)
      expect(value.previous).to eq(Set[a])
    end

    it "supports exponentiation" do
      a = Micrograd::Value[a: 2]
      value = a.exp
      expect(value.data).to be_close_to(7.389)
      expect(value.label).to eq(:"exp(a)")
      expect(value.operation).to eq(:exp)
      expect(value.previous).to eq(Set[a])
    end

    it "supports negation" do
      a = Micrograd::Value[a: 2]
      value = -a
      expect(value.data).to eq(-2)
      expect(value.label).to eq(:"a*scalar_-1")
      expect(value.operation).to eq(:*)
      # Skipping #previous test because it's two operations chained together
    end
  end

  describe "with_ methods" do
    it "allows re-assigning label" do
      a = Micrograd::Value[a: 2]
      b = Micrograd::Value[b: 3]
      value = (a * b).with_label(:c)

      expect(value.data).to eq(6)
      expect(value.label).to eq(:c)
      expect(value.operation).to eq(:*)
      expect(value.previous).to eq(Set[a, b])
    end

    it "allows re-assigning grad" do
      a = Micrograd::Value[a: 2]
      b = Micrograd::Value[b: 3]
      value = (a * b).with_grad(1)
      expect(value.grad).to eq(1)
    end
  end

  describe "backward" do
    it "calculates gradients for 2 sets of weights and inputs" do
      x1 = Micrograd::Value[x1: 2]
      x2 = Micrograd::Value[x2: 0]
      w1 = Micrograd::Value[w1: -3]
      w2 = Micrograd::Value[w2: 1]
      x1w1 = (x1 * w1).with_label(:x1w1)
      x2w2 = (x2 * w2).with_label(:x2w2)
      x1w1x2w2 = (x1w1 + x2w2).with_label(:x1w1x2w2)

      x1w1x2w2.backward
      expect(x1.grad).to eq(-3)
      expect(w1.grad).to eq(2)
      expect(x2.grad).to eq(1)
      expect(w2.grad).to eq(0)
    end

    it "calculates gradients for full example set of weights and inputs" do
      x1 = Micrograd::Value[x1: 2]
      x2 = Micrograd::Value[x2: 0]
      w1 = Micrograd::Value[w1: -3]
      w2 = Micrograd::Value[w2: 1]
      x1w1 = (x1 * w1).with_label(:x1w1)
      x2w2 = (x2 * w2).with_label(:x2w2)
      x1w1x2w2 = (x1w1 + x2w2).with_label(:x1w1x2w2)

      b = Micrograd::Value[b: 6.8813735870195432]
      n = (x1w1x2w2 + b).with_label(:n)
      o = n.tanh.with_label(:o)
      o.backward
      expect(x1.grad).to be_close_to(-1.5)
      expect(w1.grad).to be_close_to(1)
      expect(x2.grad).to be_close_to(0.5)
      expect(w2.grad).to eq(0)

      expect(x1w1.grad).to be_close_to(0.5)
      expect(x2w2.grad).to be_close_to(0.5)
      expect(x1w1x2w2.grad).to be_close_to(0.5)
      expect(b.grad).to be_close_to(0.5)
      expect(n.grad).to be_close_to(0.5)
    end

    it "handles node being used multiple times" do
      a = Micrograd::Value[a: 2]
      value = (a + a).with_label(:double_a)
      value.backward

      expect(a.grad).to eq(2)
    end
  end

  describe "conversion when computing with scalars" do
    it "converts scalar to value on addition" do
      a = Micrograd::Value[a: 1]
      value = a + 2
      expect(value.data).to eq(3)
      expect(value.label).to eq(:"a+scalar_2")
      expect(value.previous.map(&:label)).to include(:scalar_2)
      expect(value.previous.map(&:data)).to include(2)
    end

    it "converts scalar to value on multiplication" do
      a = Micrograd::Value[a: 1]
      value = a * 3
      expect(value.data).to eq(3)
      expect(value.label).to eq(:"a*scalar_3")
      expect(value.previous.map(&:label)).to include(:scalar_3)
      expect(value.previous.map(&:data)).to include(3)
    end

    it "coerces scalar to value on addition" do
      a = Micrograd::Value[a: 1]
      value = 2 + a
      expect(value.data).to eq(3)
      expect(value.label).to eq(:"scalar_2+a")
      expect(value.previous.map(&:label)).to include(:scalar_2)
      expect(value.previous.map(&:data)).to include(2)
    end

    it "coerces scalar to value on multiplication" do
      a = Micrograd::Value[a: 1]
      value = 3 * a
      expect(value.data).to eq(3)
      expect(value.label).to eq(:"scalar_3*a")
      expect(value.previous.map(&:label)).to include(:scalar_3)
      expect(value.previous.map(&:data)).to include(3)
    end
  end
end
