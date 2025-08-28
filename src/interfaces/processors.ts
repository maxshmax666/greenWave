export interface Processor<TInput, TOutput> {
  process(input: TInput): Promise<TOutput>;
}
