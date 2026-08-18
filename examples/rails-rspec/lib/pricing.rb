# frozen_string_literal: true

# Business logic with two mutation opportunities:
# 1. The `>` boundary (a mutant could flip it to `>=`, changing behavior at exactly 100)
# 2. The constant DISCOUNT_RATE (a mutant could change 0.9 -> 0.8)
#
# The shipped spec only checks `150` (clearly above threshold) with a weak
# assertion, so both kinds of mutation would survive.
class Pricing
  DISCOUNT_RATE = 0.9
  DISCOUNT_THRESHOLD = 100

  def self.calculate(total)
    return total * DISCOUNT_RATE if total > DISCOUNT_THRESHOLD

    total
  end
end
