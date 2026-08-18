# Ruby/Rails + RSpec + mutant

Example project demonstrating mutation testing on Ruby business logic.

## Requirements

- Ruby >= 3.0 (mutant requires it; Rails apps should already be on 3.x)
- Bundler

## Setup

```bash
bundle install
```

## Run the tests

```bash
bundle exec rspec
```

The spec ships with a **deliberately weak test** so you can see mutation
testing catch it. The weak test executes the discount branch but doesn't assert
the exact rate, so a mutant changing `DISCOUNT_RATE` (or the `>` boundary) would
survive.

## Run mutation testing

```bash
# Target one method (never the whole app — mutant is slow)
bundle exec mutant run --use rspec --include lib "Pricing.calculate"
```

In a real Rails app, add the environment require:

```bash
bundle exec mutant run \
  --use rspec \
  --include app --include lib \
  --require ./config/environment \
  "User#full_name"
```

## Expected output (before you fix the weak test)

```
evil:Pricing.calculate:/lib/pricing.rb:LINE:HASH
@@ -1,2 +1,2 @@
-      return total * DISCOUNT_RATE if total > DISCOUNT_THRESHOLD
+      return total * DISCOUNT_RATE if total >= DISCOUNT_THRESHOLD
```

## Fix it

Strengthen the spec (see `spec/pricing_spec.rb` — the "killing tests" are
commented as the fix), then re-run mutant. Surviving mutants should drop to 0.
