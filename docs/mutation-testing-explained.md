# Mutation Testing — In-Depth Guide

> A thorough guide to mutation testing: why it exists, how it works, and how
> to use it well. English 🇬🇧 + Bahasa Indonesia 🇮🇩

---

## 🇬🇧 English

### 1. The problem: code coverage lies

Coverage tells you *which lines ran*, not *whether anything checked them*.
A test that calls a function but never asserts its result still counts as
"covered". This is why a codebase can report 95% coverage and still ship bugs
on every release.

```javascript
// 100% covered, 0% verified
it('processes a payment', () => {
  processPayment({ amount: 100 });   // no assertion!
});
```

Mutation testing exists to answer the question coverage can't: **if a line of
code were wrong, would any test fail?**

### 2. What mutation testing is

Mutation testing (a.k.a. *mutation analysis*) is a **fault-injection technique**.
It deliberately introduces small, mechanical bugs — called **mutants** — into
your source code, then runs your test suite against each one.

- A mutant your tests **fail on** is **killed** 🟢 — your tests verified that logic.
- A mutant your tests **pass on** is **survived** 🔴 — no test caught it; you have a gap.
- A mutant your tests **never even execute** is **uncovered** (no coverage).

The result is a **mutation score** — the percentage of mutants killed — which is
a far stronger signal of test quality than line coverage.

### 3. Mutation operators

Each "bug" comes from a **mutation operator**: a rule that transforms code in a
specific, realistic way.

| Operator | Original | Mutant | What it models |
|----------|----------|--------|----------------|
| Arithmetic | `a * b` | `a / b`, `a + b`, `a - b` | wrong operator |
| Relational | `>` | `>=`, `<`, `<=`, `==`, `!=` | off-by-one / flipped logic |
| Logical | `&&` | `\|\|`, `&`, `\|` | wrong boolean logic |
| Conditional | `cond ? x : y` | `x`, `y`, `true`, `false` | missing branch |
| Constant | `x = 0.9` | `x = 0.8`, `x = 1` | wrong value |
| Negation | `if (ok)` | `if (!ok)` | inverted condition |
| Statement deletion | `validate(x)` | *(removed)* | missing side-effect |
| Return value | `return x` | `return null` / `return 0` | wrong return |

Different tools ship different operator sets — e.g. StrykerJS defaults to
`ArithmeticOperator`, `EqualityOperator`, `ConditionalExpression`, `LogicalOperator`,
`StringLiteral`, and others, while Ruby's `mutant` focuses on expression-level
substitutions.

### 4. How it works (the algorithm)

```
1. Instrument each candidate source file.
2. For each mutation operator applicable to a line, generate a mutant
   (a copy of the code with that one change).
3. Run the test suite against each mutant.
   - any test fails   → mutant KILLED
   - all tests pass   → mutant SURVIVED
   - tests never hit it → mutant UNCOVERED
4. Score = killed / (killed + survived)  [× 100]
```

Because every mutant runs the suite, the cost is `(number of mutants) ×
(test suite runtime)` — which is why naive mutation testing is slow and why
scoping and parallelism matter (see §6).

### 5. Reading the mutation score

| Score | Interpretation |
|-------|----------------|
| **< 40%** | Weak suite — many logic bugs would slip through |
| **40–70%** | Moderate — core paths tested, edge branches leaky |
| **70–90%** | Solid — good enough for most business code |
| **> 90%** | Strong — expensive to maintain; reserve for critical code |

Target ~**80% on core business logic**, not on every file. CRUD, DTOs, config
and UI glue have almost no logic worth mutation-testing.

### 6. Equivalent mutants — the hard part

Some mutants are **behaviorally identical** to the original, so no test can
ever distinguish them:

```javascript
// original                          // mutant
for (let i = 0; i < n; i++)          for (let i = 0; i < n; ++i)
const a = x && y;                    const a = x && y;   // (same)
```

These are **equivalent mutants**. They survive *not* because your tests are
weak, but because the "bug" isn't actually a bug. Handling them is the main
source of manual effort: you have to review each survivor and decide "real gap"
vs "equivalent". Good tools (Stryker's `ignoreStatic`, PIT's filters) can
auto-skip some, but the rest need human judgment.

### 7. Performance & how to keep it fast

Mutation testing is **orders of magnitude slower** than running tests normally.
Strategies to make it tractable:

1. **Scope narrowly** — one class/method/file at a time, not the whole app.
2. **Run in parallel** — `mutant --jobs N`, Stryker uses multiple test-runner processes.
3. **Per-test coverage analysis** — Stryker's `coverageAnalysis: 'perTest'` only
   runs the tests that actually execute each mutant, massively cutting runtime.
4. **Incremental mode** — only re-test mutants in files that changed since last run.
5. **Run periodically, not per-commit** — a weekly CI job on core modules is the
   sweet spot; per-PR is usually too slow.

### 8. When to use it (decision framework)

**✅ High value:**
- Billing, pricing, discount, tax, permission logic
- Auth/session, input validation, serialization boundaries
- Shared libraries and SDKs with many consumers
- Code with a compliance or security requirement

**❌ Low value:**
- CRUD, DTOs, config, dependency wiring
- Pure UI / template glue, styling
- Small prototypes and throwaway scripts

### 9. Unit test vs mutation testing

| | **Unit test** | **Mutation testing** |
|---|---|---|
| **Tests** | your code | your tests |
| **Asks** | "Does this work?" | "Would the tests catch a bug?" |
| **Measures** | % of lines executed | % of mutants killed |
| **Catches** | bugs in code | gaps in tests |
| **Runs** | every commit | periodically (weekly CI) |

They're complementary: unit tests *write* the safety net, mutation testing
*checks* the net for holes.

### 10. Tools

| Language | Tool | Notes |
|----------|------|-------|
| Ruby / Rails | `mutant` + `mutant-rspec` | Ruby >= 3.0 |
| JavaScript / TS / Vue | `Stryker` (`stryker-mutator`) | vitest/jest runner |
| Java | `PIT` | most mature in the JVM world |
| C# | `Stryker.NET` | |
| Python | `mutmut`, `Cosmic Ray` | |

---

## 🇮🇩 Bahasa Indonesia

### 1. Masalahnya: code coverage itu menipu

Coverage cuma ngasih tau *baris mana yang ke-run*, bukan *apakah ada yang
ngecek hasilnya*. Test yang manggil function tapi nggak nge-assert hasilnya
tetap dihitung "ter-cover". Makanya codebase bisa klaim coverage 95% tapi tetap
rilis bug terus-terusan.

```javascript
// 100% covered, 0% terverifikasi
it('proses pembayaran', () => {
  processPayment({ amount: 100 });   // nggak ada assertion!
});
```

Mutation testing ada buat jawab pertanyaan yang coverage nggak bisa jawab:
**kalau baris kode ini salah, apa ada test yang bakal gagal?**

### 2. Apa itu mutation testing

Mutation testing (alias *mutation analysis*) adalah **teknik fault-injection**.
Tool-nya sengaja nambahin bug kecil & mekanis — disebut **mutant** — ke kode
kamu, lalu jalanin test suite ke tiap mutant.

- Mutant yang bikin test **gagal** = **killed** 🟢 — test kamu ngeverifikasi logika itu.
- Mutant yang lolos test = **survived** 🔴 — nggak ada test yang nangkep; ada celah.
- Mutant yang nggak pernah ke-eksekusi test = **uncovered**.

Hasilnya **mutation score** — persentase mutant yang kebunuh — sinyal kualitas
test yang jauh lebih kuat daripada line coverage.

### 3. Mutation operators

Tiap "bug" datang dari **mutation operator**: aturan yang mengubah kode dengan
cara spesifik & realistis.

| Operator | Asli | Mutant | Memodelkan |
|----------|------|--------|------------|
| Arithmetic | `a * b` | `a / b`, `a + b`, `a - b` | salah operator |
| Relational | `>` | `>=`, `<`, `<=`, `==`, `!=` | off-by-one / logika kebalik |
| Logical | `&&` | `\|\|`, `&`, `\|` | salah boolean |
| Conditional | `cond ? x : y` | `x`, `y`, `true`, `false` | branch hilang |
| Constant | `x = 0.9` | `x = 0.8`, `x = 1` | nilai keliru |
| Negation | `if (ok)` | `if (!ok)` | kondisi terbalik |
| Statement deletion | `validate(x)` | *(dihapus)* | side-effect hilang |
| Return value | `return x` | `return null` / `return 0` | return salah |

Setiap tool punya set operator beda — misal StrykerJS default-nya `ArithmeticOperator`,
`EqualityOperator`, `ConditionalExpression`, `LogicalOperator`, `StringLiteral`, dll,
sedangkan `mutant` (Ruby) fokus ke substitusi level ekspresi.

### 4. Cara kerjanya (algoritma)

```
1. Instrumentasi tiap file kandidat.
2. Untuk tiap mutation operator yang berlaku di satu baris, buat satu mutant
   (salinan kode dengan satu perubahan itu).
3. Jalanin test suite ke tiap mutant.
   - ada test gagal  → mutant KILLED
   - semua test lolos → mutant SURVIVED
   - test nggak nyentuh → mutant UNCOVERED
4. Score = killed / (killed + survived)  [× 100]
```

Karena tiap mutant ngejalanin suite, biayanya `(jumlah mutant) × (lama test
suite)` — makanya mutation testing naif itu lambat, dan scoping + paralelisasi
jadi penting (lihat §6).

### 5. Membaca mutation score

| Score | Interpretasi |
|-------|--------------|
| **< 40%** | Suite lemah — banyak bug logika bakal lolos |
| **40–70%** | Sedang — path inti teruji, branch tepi bocor |
| **70–90%** | Solid — cukup buat mayoritas kode bisnis |
| **> 90%** | Kuat — mahal dirawat; khusus kode kritis |

Bidik ~**80% di core business logic**, bukan di semua file. CRUD, DTO, config,
dan UI glue nyaris nggak ada logika yang worth di-mutation-test.

### 6. Equivalent mutants — bagian tersulit

Beberapa mutant **identik perilakunya** sama kode asli, jadi nggak ada test yang
bisa ngebedain:

```javascript
// asli                               // mutant
for (let i = 0; i < n; i++)           for (let i = 0; i < n; ++i)
const a = x && y;                     const a = x && y;   // (sama)
```

Ini **equivalent mutant**. Mereka survive *bukan* karena test kamu lemah, tapi
karena "bug"-nya bukan bug beneran. Nanganin ini sumber utama kerja manual:
kamu harus review tiap survivor dan nentuin "celah beneran" vs "equivalent".
Tool bagus (Stryker `ignoreStatic`, filter PIT) bisa auto-skip sebagian, sisanya
butuh judgment manusia.

### 7. Performa & cara bikin cepat

Mutation testing **jauh lebih lambat** dari jalanin test biasa. Strategi biar
ke-handle:

1. **Scope sempit** — satu class/method/file, bukan seluruh app.
2. **Paralel** — `mutant --jobs N`, Stryker pakai banyak proses test-runner.
3. **Per-test coverage analysis** — Stryker `coverageAnalysis: 'perTest'` cuma
   jalanin test yang beneran nge-eksekusi tiap mutant, motong runtime drastis.
4. **Mode incremental** — cuma re-test mutant di file yang berubah sejak run terakhir.
5. **Periodik, bukan tiap commit** — job CI mingguan di modul core paling pas;
   per-PR biasanya kelewat lambat.

### 8. Kapan pakainya (framework keputusan)

**✅ Nilai tinggi:**
- Logika billing, pricing, diskon, pajak, permission
- Auth/session, validasi input, batas serialisasi
- Library / SDK yang dipake banyak konsumen
- Kode dengan requirement compliance atau security

**❌ Nilai rendah:**
- CRUD, DTO, config, wiring dependency
- Pure UI / template glue, styling
- Prototipe kecil dan script sekali pakai

### 9. Unit test vs mutation testing

| | **Unit test** | **Mutation testing** |
|---|---|---|
| **Ngetes** | kode kamu | test kamu |
| **Nanya** | "Ini jalan ga?" | "Test-nya nangkep bug ga?" |
| **Ngukur** | % baris ke-eksekusi | % mutant kebunuh |
| **Nangkep** | bug di kode | celah di test |
| **Jalan** | tiap commit | berkala (CI mingguan) |

Keduanya saling melengkapi: unit test *nulis* jaring pengaman, mutation testing
*ngecek* jaringnya bolong atau enggak.

### 10. Tools

| Bahasa | Tool | Catatan |
|--------|------|---------|
| Ruby / Rails | `mutant` + `mutant-rspec` | Ruby >= 3.0 |
| JavaScript / TS / Vue | `Stryker` (`stryker-mutator`) | vitest/jest runner |
| Java | `PIT` | paling mature di dunia JVM |
| C# | `Stryker.NET` | |
| Python | `mutmut`, `Cosmic Ray` | |
