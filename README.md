# Mutation Testing Toolkit

Mutation testing untuk tim: skill AI (`mutation-kill`) + example projects siap
jalan untuk **Rails + RSpec** (`mutant` gem) dan **Vue + Vitest** (Stryker).

## Apa ini?

Mutation testing ngetes **kualitas test** kamu, bukan cuma coverage. Tool-nya
"mutasi" kode asli (balik operator, ganti konstanta, hapus kondisi), terus cek
apakah test suite kamu nangkep perubahan itu. Mutant yang lolos = ada celah di
test kamu.

## Struktur repo

```
mutation-testing-toolkit/
├── README.md
├── skills/
│   └── mutation-kill/
│       └── SKILL.md              # Skill AI (Claude Code + OpenCode)
├── examples/
│   ├── rails-rspec/              # Ruby + RSpec + mutant
│   │   ├── Gemfile
│   │   ├── .mutant.yml
│   │   ├── lib/
│   │   └── spec/
│   └── vue-vitest/               # JS + Vitest + Stryker
│       ├── package.json
│       ├── stryker.config.mjs
│       └── src/
└── flowchart/
    └── mutation-testing-workflow.html   # Diagram alur (buka di browser)
```

## Install skill ke Claude Code / OpenCode

Skill udah ada di `skills/mutation-kill/SKILL.md`. Copy ke salah satu:

```bash
# Claude Code (user-level, global semua project)
cp -r skills/mutation-kill ~/.claude/skills/

# OpenCode (user-level)
cp -r skills/mutation-kill ~/.config/opencode/skills/

# Atau project-level (biar ke-commit bareng repo)
cp -r skills/mutation-kill ./.claude/skills/     # Claude Code
cp -r skills/mutation-kill ./.opencode/skills/   # OpenCode
```

Trigger: bilang aja **"kill mutants"**, **"bunuh mutant"**, **"naikin mutation score"**.

## Contoh: Rails + RSpec (mutant)

```bash
cd examples/rails-rspec
bundle install
bundle exec rspec            # test dulu harus hijau
bundle exec mutant run --use rspec --include lib "Pricing.calculate"
```

> Butuh Ruby >= 3.0 (mutant terbaru). Di Rails asli, tambah `--require ./config/environment`.

## Contoh: Vue + Vitest (Stryker)

```bash
cd examples/vue-vitest
npm install
npx stryker run              # laporan: reports/mutation/mutation.json
```

## Alur kerja (flowchart)

Buka `flowchart/mutation-testing-workflow.html` di browser, atau lihat ringkasnya:

```
Run mutation tool → baca surviving mutants → tulis killing test → re-run → score naik
```

Lihat `flowchart/` untuk diagram lengkap.
