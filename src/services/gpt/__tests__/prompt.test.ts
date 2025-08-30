import { formatPrompt } from '../prompt';

describe('formatPrompt', () => {
  it('replaces variables in template', () => {
    const result = formatPrompt('Hello {name}', { name: 'Alice' });
    expect(result).toBe('Hello Alice');
  });
});
