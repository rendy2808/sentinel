# frozen_string_literal: true

require "pricing"

RSpec.describe Pricing do
  # ⚠️ WEAK test — executes the discount branch but only asserts "< 150".
  # A mutant changing DISCOUNT_RATE 0.9 -> 0.8 (135 -> 120, both < 150)
  # or `>` -> `>=` would SURVIVE this.
  it "returns full price at or under threshold" do
    expect(described_class.calculate(50)).to eq(50)
  end

  it "applies a discount above threshold" do
    expect(described_class.calculate(150)).to be < 150
  end

  # --- Killing tests (uncomment to fix the weak test) -----------------------
  # it "uses the exact discount rate" do
  #   expect(described_class.calculate(150)).to eq(135)   # kills 0.9 -> 0.8
  # end
  #
  # it "does not discount exactly at the threshold" do
  #   expect(described_class.calculate(100)).to eq(100)   # kills > -> >=
  # end
end
