import { validateLight, validateCycle } from '../validation';

describe('validateLight', () => {
  test('requires name', () => {
    expect(validateLight('', 'MAIN')).toBe('Name is required');
  });

  test('requires valid direction', () => {
    expect(validateLight('name', 'WRONG')).toBe('Direction is invalid');
  });

  test('passes for valid data', () => {
    expect(validateLight('name', 'MAIN')).toBeNull();
  });
});

describe('validateCycle', () => {
  const base = {
    cycleSeconds: '60',
    mainStart: '0',
    mainEnd: '10',
    secStart: '10',
    secEnd: '20',
    pedStart: '20',
    pedEnd: '30',
  };

  test('numbers required', () => {
    expect(
      validateCycle({ ...base, cycleSeconds: 'abc' })
    ).toBe('All numeric fields must be valid numbers');
  });

  test('main start must be less than end', () => {
    expect(
      validateCycle({ ...base, mainStart: '5', mainEnd: '5' })
    ).toBe('Main start must be less than end');
  });

  test('secondary start must be less than end', () => {
    expect(
      validateCycle({ ...base, secStart: '15', secEnd: '15' })
    ).toBe('Secondary start must be less than end');
  });

  test('pedestrian start must be less than end', () => {
    expect(
      validateCycle({ ...base, pedStart: '25', pedEnd: '25' })
    ).toBe('Pedestrian start must be less than end');
  });

  test('passes for valid data', () => {
    expect(validateCycle(base)).toBeNull();
  });
});
