import type { Processor } from '../processors';

export interface GroupedProcessor<TGroup, TInput, TOutput>
  extends Processor<TInput, TOutput> {
  readonly group: TGroup;
}
