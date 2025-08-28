export interface Source<T> {
  fetch(): Promise<T>;
}
