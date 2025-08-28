import type {
  CliCommand,
  VoiceCommand,
  Processor,
  GroupedProcessor,
  Source,
  Store,
} from '../index';

const cli: CliCommand = async (argv) => {
  void argv;
};

const voice: VoiceCommand = async (phrase) => {
  void phrase;
};

const proc: Processor<number, string> = {
  process: async (n) => n.toString(),
};

const grouped: GroupedProcessor<string, number, string> = {
  group: 'main',
  process: async (n) => n.toString(),
};

const source: Source<number> = {
  fetch: async () => 1,
};

const store: Store<number> = {
  get: async () => 1,
  set: async (value) => {
    void value;
  },
};

test('types compile', () => {
  expect(cli).toBeDefined();
  expect(voice).toBeDefined();
  expect(proc).toBeDefined();
  expect(grouped).toBeDefined();
  expect(source).toBeDefined();
  expect(store).toBeDefined();
});
