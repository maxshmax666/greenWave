export interface Processor<TInput, TOutput> {
  process(input: TInput): Promise<TOutput>;
}

export interface GroupedProcessor<TGroup, TInput, TOutput>
  extends Processor<TInput, TOutput> {
  readonly group: TGroup;
}
