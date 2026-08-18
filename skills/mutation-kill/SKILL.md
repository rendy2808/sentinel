---
name: mutation-kill
description: Kill surviving mutation-testing mutants by writing targeted tests. Supports Rails+RSpec (mutant gem) and Vue+Vitest/Playwright (Stryker). Use when the user says "kill mutants", "kill surviving mutants", "bunuh mutant", "naikin mutation score", "mutation testing", "fix mutation report", or provides a Stryker/mutant report and asks to raise the mutation score.
---

# Mutation Kill

Kill surviving mutation-testing mutants by writing the minimal test(s) that
expose each mutation. Mutation testing mutates real code (flips operators,
changes constants, deletes conditions) and checks whether the existing test
suite catches it. A mutant that survives = a gap in the tests. This skill
turns the report into concrete test additions.

## Step 0 — Detect the stack

| Signal | Stack | Tool |
|--------|-------|------|
| `Gemfile` + `spec/` + `config/application.rb` | Rails + RSpec | `mutant` gem |
| `package.json` + `*.vue` + unit tests (`*.spec.ts`, `*.test.ts`, Vitest/Jest) | Vue + Vitest/Jest | `stryker` (vitest/jest runner) |
| `package.json` + `playwright.config.*` only (no unit runner) | Vue + Playwright E2E | ⚠️ see "Playwright note" |

Prefer project-level (`./.claude/skills/` or `./.opencode/skills/`) if the team
commits skills; otherwise user-level (`~/.claude/skills/`, `~/.config/opencode/skills/`).

---

## Rails + RSpec (mutant gem)

### Install (once)
Add to `Gemfile` and run `bundle install`:
```ruby
group :test do
  gem 'mutant-rspec'
end
```

### Run (target a specific class/method — never the whole suite)
```bash
bundle exec mutant run \
  --use rspec \
  --include app --include lib \
  --require ./config/environment \
  "User#full_name"
```

- `--include` = directories with the code under test (and the spec dir).
- `--require ./config/environment` is mandatory for Rails so mutant can boot the app.
- `--jobs N` to parallelize (mutant is slow; use CPU count).
- Target the smallest scope that matters (one class or method), not everything.

### Read mutant's report
Mutant prints each surviving mutation as an `evil:` line + a unified diff:
```
evil:User#full_name:/app/models/user.rb:12:abcd
@@ -1,2 +1,2 @@
-  "#{first_name} #{last_name}"
+  "#{first_name} #{first_name}"
```
The diff shows exactly what changed. `evil:` line = `class#method:file:line:hash`.

### Write a killing test
For the diff above, add an RSpec case that asserts the *other* branch/value:
```ruby
it "uses both names" do
  user = User.new(first_name: "Ada", last_name: "Lovelace")
  expect(user.full_name).to eq("Ada Lovelace")
end
```
A mutant survives when no assertion distinguishes the original from the mutated
behavior. Make the test assert the precise value/branch the mutant changed.

### Verify
Re-run mutant on the same scope and confirm the `evil:` is gone (Killed).

---

## Vue + Vitest/Jest (Stryker)

### Install (once)
```bash
npm i -D @stryker-mutator/core @stryker-mutator/vitest-runner
# or @stryker-mutator/jest-runner if the project uses Jest
```

### Config — `stryker.config.mjs`
```js
export default {
  testRunner: 'vitest',           // or 'jest'
  coverageAnalysis: 'perTest',    // faster, more accurate
  mutate: [
    'src/**/*.{ts,js,vue}',
    '!src/**/*.spec.{ts,js}',
    '!src/**/*.test.{ts,js}',
    '!src/**/__mocks__/**',
  ],
  thresholds: { high: 80, low: 60, break: null },
};
```
`break: null` so a low score does NOT fail CI while you're fixing mutants.
Set `break: <number>` later to gate it.

### Run
```bash
npx stryker run
```

### Read Stryker's report
Stryker writes JSON + HTML to `reports/mutation/`. Read `mutation.json`:
```json
{
  "files": {
    "src/utils/discount.js": {
      "mutants": [
        {
          "status": "Survived",
          "mutatorName": "ArithmeticOperator",
          "location": { "start": { "line": 12, "column": 20 } },
          "replacement": "*"
        }
      ]
    }
  }
}
```
Relevant fields: `status` (`Survived` = fix it, `Killed` = ok, `NoCoverage` =
not executed, `Timeout` = slow test caught it, `CompileError` = broken mutant),
`mutatorName`, `location` (line/col), `replacement`.

### Write a killing test
Open the file at `location`, read the mutated line, and write a Vitest/Jest test
that asserts the branch the mutation would break. Same principle as RSpec.

---

## Vue + Playwright (E2E) — important note

Mutation testing **E2E tests is almost never worth it**: each mutant re-runs the
whole browser test, so a run of 100 mutants can take hours and is flaky.

Do this instead:
1. Mutation-test the **unit layer** (Vitest + `@vue/test-utils`) with Stryker.
2. Keep Playwright for E2E coverage, but don't feed it into mutation testing.

If a user insists on Playwright mutation testing, use Stryker's command runner:
```bash
npm i -D @stryker-mutator/core
```
```js
// stryker.config.mjs
export default {
  testRunner: '@stryker-mutator/command-runner',
  commandRunner: { command: 'npx playwright test' },
  coverageAnalysis: 'off',   // required for command runner
  timeoutMS: 300000,
};
```
Expect very long runtimes; scope to one component/route at a time.

---

## Equivalent mutants — skip, don't fight

Some mutations are behaviorally identical (e.g. `i++` → `i += 1`, or `x && y`
→ `y && x` when commutative). No test can "kill" them because the behavior
never changes. When you can't write a distinguishing test after 1–2 attempts:
- Note it as **equivalent** and move on.
- Rails `mutant`: equivalent mutants still show; just document them.
- Stryker: they appear as `Survived`; exclude the file/line via `mutate: [...]`
  negation or `ignoreStatic: true` for static-equivalent cases.

Don't spend more than ~2 minutes proving a mutant is equivalent. Log it and
move to the next surviving mutant.

---

## Output format (final report to user)

When done, report a concise summary:

```
Mutation kill — <stack> (<tool>)
Score before: 62% → after: 81%
Killed: 14 mutants
Equivalent (skipped): 3
Files touched:
  - spec/models/user_spec.rb (5 tests)
  - src/utils/discount.spec.ts (4 tests)
```

## Pitfalls

- **Never run mutation testing on the whole codebase at once.** It's minutes-to-hours. Always scope to one class/module/file.
- **Rails mutant needs `--require ./config/environment`** or every spec fails to load.
- **Stryker `coverageAnalysis: 'perTest'`** is much faster than `'all'`; use it.
- **Don't let low scores block CI** (`break: null`) until the team agrees on a threshold.
- **Flaky Playwright E2E + mutation = noise.** Keep mutation testing at the unit layer.
- **A "NoCoverage" mutant ≠ a bug** — it just means the test never executes that line; add a test that reaches it, don't necessarily add an assertion.
- **Re-run only the changed scope** to verify, not the full suite.
