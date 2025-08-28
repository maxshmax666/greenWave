import { useEffect, useState } from 'react';
import * as InAppPurchases from 'expo-in-app-purchases';

const SUBSCRIPTION_ID = 'premium_subscription';

export async function purchasePremium() {
  await InAppPurchases.purchaseItemAsync(SUBSCRIPTION_ID);
}

export function usePremium() {
  const [isPremium, setPremium] = useState(false);

  useEffect(() => {
    let mounted = true;
    async function init() {
      try {
        await InAppPurchases.connectAsync();
        const history = await InAppPurchases.getPurchaseHistoryAsync();
        const active = history.results?.some(
          (r) => r.productId === SUBSCRIPTION_ID,
        );
        if (mounted) setPremium(!!active);
      } catch (e) {
        console.warn('IAP error', e);
      }
    }
    init();
    return () => {
      mounted = false;
      InAppPurchases.disconnectAsync();
    };
  }, []);

  return { isPremium };
}
