import { extractContent } from '../parse';

describe('extractContent', () => {
  it('returns first message content', () => {
    const result = extractContent({
      choices: [{ message: { content: 'hi' } }],
    });
    expect(result).toBe('hi');
  });

  it('returns empty string when missing', () => {
    const result = extractContent({ choices: [] });
    expect(result).toBe('');
  });
});
