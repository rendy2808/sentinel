// Business logic with a boundary condition.
// The shipped spec only checks a clearly-adult age (25), never the boundary.
// Mutating `>=` -> `>` will SURVIVE: 25 > 18 and 25 >= 18 are both true.
export function isEligible(age) {
  return age >= 18;
}
