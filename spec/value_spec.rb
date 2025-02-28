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

    it "supports bracket short-hand constructor" do
      value = Micrograd::Value[a: 123]
      expect(value.data).to eq(123)
      expect(value.label).to eq(:a)
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
