module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: [
    '**/src/**/*.test.ts?(x)',
    '**/src/**/__tests__/**/*.ts?(x)',
  ],
  testPathIgnorePatterns: ['lights\.test\.ts$'],
  transform: {
    '^.+\\.(ts|tsx)$': 'ts-jest',
    '^.+\\.(js|jsx)$': 'babel-jest',
  },
};
