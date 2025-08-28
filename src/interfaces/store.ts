export interface Store<T> {
  get(): Promise<T>;
  set(value: T): Promise<void>;
}
