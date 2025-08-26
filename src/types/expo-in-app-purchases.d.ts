declare module 'expo-in-app-purchases' {
  export interface Purchase {
    productId: string;
  }
  export interface PurchaseHistory {
    results?: Purchase[];
  }
  export function connectAsync(): Promise<void>;
  export function disconnectAsync(): Promise<void>;
  export function getPurchaseHistoryAsync(): Promise<PurchaseHistory>;
  export function purchaseItemAsync(productId: string): Promise<void>;
}
