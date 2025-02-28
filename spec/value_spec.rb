require "spec_helper"

RSpec.describe Micrograd::Value do
  it "has data and label attributes" do
    value = Micrograd::Value.new(data: 1, label: :a)

    expect(value.data).to eq(1)
    expect(value.label).to eq(:a)
  end

  it "has bracket short-hand constructor" do
    value = Micrograd::Value[a: 123]
    expect(value.data).to eq(123)
    expect(value.label).to eq(:a)
  end
end
