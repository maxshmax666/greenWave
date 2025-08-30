export interface ColorPhase {
  color: string;
  duration: number;
}

export function finalizePhase(
  phases: ColorPhase[],
  currentColor: string | null,
  startTime: number | null,
  now: number,
): void {
  if (currentColor && startTime !== null) {
    phases.push({ color: currentColor, duration: now - startTime });
  }
}
