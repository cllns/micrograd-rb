require "spec_helper"

RSpec.describe Micrograd::Value do
  describe "constructors" do
    it "has data and label attributes" do
      value = Micrograd::Value.new(data: 1, label: :a)

      expect(value.data).to eq(1)
      expect(value.label).to eq(:a)
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
  end
end
