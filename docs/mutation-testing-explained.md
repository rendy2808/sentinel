# Mutation Testing — Simple Explanation

> A plain-language guide to what mutation testing is and how to use it.
> English 🇬🇧 + Bahasa Indonesia 🇮🇩

---

## 🇬🇧 English

### What is mutation testing?

Mutation testing checks **how good your tests really are**.

Normal code coverage only answers: *"Did this line of code run?"*
Mutation testing asks: *"If someone quietly broke this code, would your tests catch it?"*

**How it works:**

1. The tool makes small "mutations" to your code (flip `>` to `>=`, change `0.9` to `0.8`, delete a condition).
2. It runs your tests against each mutation.
3. If your tests **fail**, the mutation was "killed" 🟢 — your tests are good.
4. If your tests **pass**, the mutation "survived" 🔴 — you have a gap.

**Analogy:**
> Coverage = "you visited every room in the house."
> Mutation testing = "you checked that every light switch actually works."

### A quick example

```javascript
function isAdult(age) {
  return age >= 18;
}
```

```javascript
// Weak test — only checks age 25, never the boundary
expect(isAdult(25)).toBe(true);
```

The tool mutates `>=` to `>`. Since `25 > 18` is also true, the test still passes → **the mutant survives**. You missed the boundary.

The fix — assert the boundary:

```javascript
expect(isAdult(17)).toBe(false);  // under 18
expect(isAdult(18)).toBe(true);   // exactly 18
```

Now the mutant is killed. ✅

### How to use it

**Rails + RSpec (mutant):**

```bash
cd your-rails-app
bundle add mutant-rspec --group test
bundle exec mutant run --use rspec --include app --include lib \
  --require ./config/environment "User#full_name"
```

**Vue + Vitest (Stryker):**

```bash
npm i -D @stryker-mutator/core @stryker-mutator/vitest-runner
npx stryker run
```

**The loop:**

```
run tool → read surviving mutants → write killing tests → re-run → score up
```

### When to use it

- ✅ Core business logic (billing, pricing, validation)
- ✅ Shared libraries
- ❌ CRUD boilerplate, UI glue, small projects (overkill)

---

## 🇮🇩 Bahasa Indonesia

### Apa itu mutation testing?

Mutation testing ngecek **seberapa bagus test kamu sebenarnya**.

Coverage biasa cuma jawab: *"Baris kode ini ke-run ga?"*
Mutation testing tanya: *"Kalau ada yang diam-diam ngerusak kode ini, test kamu bisa nangkep ga?"*

**Cara kerjanya:**

1. Tool bikin "mutasi" kecil di kode kamu (balik `>` jadi `>=`, ganti `0.9` jadi `0.8`, hapus kondisi).
2. Test kamu dijalankan ke tiap mutasi.
3. Kalau test **gagal** → mutasi "terbunuh" 🟢 (killed), test kamu bagus.
4. Kalau test **lolos** → mutasi "selamat" 🔴 (survived), ada celah di test kamu.

**Analogi:**
> Coverage = "kamu udah masuk ke semua ruangan rumah."
> Mutation testing = "kamu cek semua saklar lampunya beneran nyala."

### Contoh singkat

```javascript
function isAdult(age) {
  return age >= 18;
}
```

```javascript
// Test lemah — cuma ngecek umur 25, ga pernah ngecek batasnya
expect(isAdult(25)).toBe(true);
```

Tool mutasi `>=` jadi `>`. Karena `25 > 18` juga true, test tetap lolos → **mutant selamat**. Kamu kelewat boundary-nya.

Benerinnya — assert boundary-nya:

```javascript
expect(isAdult(17)).toBe(false);  // di bawah 18
expect(isAdult(18)).toBe(true);   // pas 18
```

Sekarang mutant-nya kebunuh. ✅

### Cara pakainya

**Rails + RSpec (mutant):**

```bash
cd your-rails-app
bundle add mutant-rspec --group test
bundle exec mutant run --use rspec --include app --include lib \
  --require ./config/environment "User#full_name"
```

**Vue + Vitest (Stryker):**

```bash
npm i -D @stryker-mutator/core @stryker-mutator/vitest-runner
npx stryker run
```

**Loop-nya:**

```
jalankan tool → baca surviving mutants → tulis killing test → re-run → skor naik
```

### Kapan pakainya

- ✅ Core business logic (billing, pricing, validasi)
- ✅ Library yang dipake banyak orang
- ❌ CRUD boilerplate, UI glue, project kecil (overkill)
