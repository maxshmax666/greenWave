export const validateLight = (name: string, direction: string): string | null => {
  if (!name.trim()) {
    return 'Name is required';
  }
  const allowed = ['MAIN', 'SECONDARY', 'PEDESTRIAN'];
  if (!allowed.includes(direction)) {
    return 'Direction is invalid';
  }
  return null;
};

export interface CycleFields {
  cycleSeconds: string;
  mainStart: string;
  mainEnd: string;
  secStart: string;
  secEnd: string;
  pedStart: string;
  pedEnd: string;
}

export const validateCycle = ({
  cycleSeconds,
  mainStart,
  mainEnd,
  secStart,
  secEnd,
  pedStart,
  pedEnd,
}: CycleFields): string | null => {
  const values = [cycleSeconds, mainStart, mainEnd, secStart, secEnd, pedStart, pedEnd].map(Number);
  if (values.some(v => Number.isNaN(v))) {
    return 'All numeric fields must be valid numbers';
  }
  if (Number(mainStart) >= Number(mainEnd)) {
    return 'Main start must be less than end';
  }
  if (Number(secStart) >= Number(secEnd)) {
    return 'Secondary start must be less than end';
  }
  if (Number(pedStart) >= Number(pedEnd)) {
    return 'Pedestrian start must be less than end';
  }
  return null;
};
