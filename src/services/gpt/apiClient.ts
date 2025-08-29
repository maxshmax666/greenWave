import { log } from '../logger';

export interface GptClient {
  complete(prompt: string): Promise<string>;
}

export function createGptClient(
  apiKey: string,
  fetchImpl: typeof fetch = fetch,
): GptClient {
  return {
    async complete(prompt: string): Promise<string> {
      const res = await fetchImpl(
        'https://api.openai.com/v1/chat/completions',
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${apiKey}`,
          },
          body: JSON.stringify({
            model: 'gpt-3.5-turbo',
            messages: [{ role: 'user', content: prompt }],
          }),
        },
      );
      if (!res.ok) {
        throw new Error(await res.text());
      }

      let data: { choices: { message: { content: string } }[] };
      try {
        data = (await res.json()) as {
          choices: { message: { content: string } }[];
        };
      } catch (error) {
        await log('ERROR', `Failed to parse GPT response: ${String(error)}`);
        throw error;
      }

      return data.choices[0]?.message.content ?? '';
    },
  };
}
