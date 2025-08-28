export interface Command {
  run(): Promise<void>;
}

export type CliCommand = (argv: string[]) => Promise<void>;
export type VoiceCommand = (phrase: string) => Promise<void>;
