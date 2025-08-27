import i18n from './i18n';

export const validateLight = (
  name: string,
  direction: string,
): string | null => {
  if (!name.trim()) {
    return i18n.t('validation.light.nameRequired');
  }
  const allowed = ['MAIN', 'SECONDARY', 'PEDESTRIAN'];
  if (!allowed.includes(direction)) {
    return i18n.t('validation.light.directionInvalid');
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
  const values = [
    cycleSeconds,
    mainStart,
    mainEnd,
    secStart,
    secEnd,
    pedStart,
    pedEnd,
  ].map(Number);
  if (values.some((v) => Number.isNaN(v))) {
    return i18n.t('validation.cycle.numeric');
  }
  if (Number(mainStart) >= Number(mainEnd)) {
    return i18n.t('validation.cycle.mainOrder');
  }
  if (Number(secStart) >= Number(secEnd)) {
    return i18n.t('validation.cycle.secondaryOrder');
  }
  if (Number(pedStart) >= Number(pedEnd)) {
    return i18n.t('validation.cycle.pedestrianOrder');
  }
  return null;
};
