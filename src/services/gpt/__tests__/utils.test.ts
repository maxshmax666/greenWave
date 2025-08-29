import { trimLines } from '../utils';

describe('trimLines', () => {
  it('trims whitespace per line', () => {
    const text = '  a  \n  b  ';
    expect(trimLines(text)).toBe('a\nb');
  });
});
