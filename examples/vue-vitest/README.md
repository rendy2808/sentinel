# Vue + Vitest + Stryker

Example project demonstrating mutation testing on JS/Vue business logic.

## Setup

```bash
npm install
```

## Run the tests

```bash
npx vitest run
```

## Run mutation testing

```bash
npx stryker run
```

Report: `reports/mutation/mutation.json` (JSON) and `reports/mutation/html/` (browser).

## Expected output (before you fix the weak test)

Two mutants survive:

```
[Survived] EqualityOperator        `>=`  ->  `>`
[Survived] ConditionalExpression   `age >= 18`  ->  `true`
```

## Fix it

Uncomment the "killing tests" in `src/eligibility.spec.js`, then re-run
`npx stryker run`. Mutation score goes from 60% to 100%.

## Note on Playwright (E2E)

Don't feed Playwright E2E tests into Stryker — each mutant re-runs the browser,
so it's slow and flaky. Mutation-test the unit layer (Vitest + `@vue/test-utils`),
keep Playwright for E2E coverage separately. See the skill's "Playwright note".
