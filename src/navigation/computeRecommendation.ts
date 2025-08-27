import { pickSpeed, applyHysteresis } from '../domain/advisor';
import { getNearestInfo } from './getNearestInfo';
import type { LightOnRoute } from '../index';

export function computeRecommendation(
  lightsOnRoute: LightOnRoute[],
  car: { speed: number },
  nowSec: number,
  prevRecommended: number,
) {
  const res = pickSpeed(nowSec, lightsOnRoute, car.speed * 3.6);
  const { nearestInfo, nearestStillGreen } = getNearestInfo(
    lightsOnRoute[0],
    res.recommended,
    nowSec,
  );
  const recommended = prevRecommended
    ? applyHysteresis(prevRecommended, res.recommended, nearestStillGreen)
    : res.recommended;
  return { recommended, nearestInfo };
}
