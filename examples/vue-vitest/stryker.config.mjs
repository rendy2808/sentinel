export default {
  testRunner: 'vitest',
  coverageAnalysis: 'perTest',
  mutate: ['src/**/*.{ts,js,vue}', '!src/**/*.spec.{ts,js}', '!src/**/*.test.{ts,js}'],
  reporters: ['clear-text', 'json'],
  thresholds: { high: 80, low: 60, break: null },
};
