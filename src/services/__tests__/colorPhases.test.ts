import { finalizePhase, ColorPhase } from '../colorPhases';

describe('finalizePhase', () => {
  it('records duration using start time', () => {
    const phases: ColorPhase[] = [];
    let current = 'red';
    let start = 0;

    finalizePhase(phases, current, start, 1000); // switch to green at 1s
    current = 'green';
    start = 1000;

    finalizePhase(phases, current, start, 2500); // switch to yellow at 2.5s
    current = 'yellow';
    start = 2500;

    finalizePhase(phases, current, start, 4000); // stop at 4s

    expect(phases).toEqual([
      { color: 'red', duration: 1000 },
      { color: 'green', duration: 1500 },
      { color: 'yellow', duration: 1500 },
    ]);
  });
});
