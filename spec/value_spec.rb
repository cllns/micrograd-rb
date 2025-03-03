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

    it "supports bracket short-hand constructor" do
      value = Micrograd::Value[a: 123]
      expect(value.data).to eq(123)
      expect(value.label).to eq(:a)
    end

    it "supports bracket short-hand constructor with operation and previous" do
      previous1 = Micrograd::Value[a: 1]
      previous2 = Micrograd::Value[b: 2]
      value = Micrograd::Value[c: 3, op: :*, previous: [previous1, previous2]]

      expect(value.data).to eq(3)
      expect(value.label).to eq(:c)
      expect(value.operation).to eq(:*)
      expect(value.previous).to eq(Set[previous1, previous2])
    end
  end

  describe "operations" do
    it "supports addition" do
      value = Micrograd::Value[a: 1] + Micrograd::Value[b: 2]
      expect(value.data).to eq(3)
      expect(value.label).to eq(:"a+b")
    end

    it "supports multiplication" do
      value = Micrograd::Value[a: 2] * Micrograd::Value[b: 3]
      expect(value.data).to eq(6)
      expect(value.label).to eq(:"a*b")
    end
  end
end
