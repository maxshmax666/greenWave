export enum PremiumFeature {
  AddLight = 'addLight',
  SpeedPanel = 'speedPanel',
}

const premiumFeatures: Record<PremiumFeature, boolean> = {
  [PremiumFeature.AddLight]: true,
  [PremiumFeature.SpeedPanel]: true,
};

export function requiresPremium(feature: PremiumFeature): boolean {
  return premiumFeatures[feature];
}
