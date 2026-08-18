import { describe, it, expect } from 'vitest';
import { isEligible } from './eligibility.js';

describe('isEligible', () => {
  // ⚠️ WEAK test — only checks a clearly-adult age. The boundary is never asserted.
  // Mutating `>=` -> `>` survives because 25 passes either way.
  it('returns true for a clearly adult age', () => {
    expect(isEligible(25)).toBe(true);
  });

  // --- Killing tests (uncomment to fix) -------------------------------------
  // it('rejects someone under 18', () => {
  //   expect(isEligible(17)).toBe(false);   // kills `>= 18` -> `true`
  // });
  // it('accepts someone exactly 18', () => {
  //   expect(isEligible(18)).toBe(true);    // kills `>=` -> `>`
  // });
});
