export interface Message {
  type: string;
  payload?: unknown;
}

export type MessageHandler = (message: Message) => void | Promise<void>;

export type HandlerMap = Record<string, MessageHandler>;
