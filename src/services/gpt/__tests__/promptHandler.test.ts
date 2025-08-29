import { buildPrompt } from '../promptHandler';

describe('buildPrompt', () => {
  it('replaces variables in template', () => {
    const result = buildPrompt('Hello {name}', { name: 'Alice' });
    expect(result).toBe('Hello Alice');
  });
});
