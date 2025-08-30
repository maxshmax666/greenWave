export interface GptResponse {
  choices: { message: { content: string } }[];
}

export function extractContent(data: GptResponse): string {
  return data.choices[0]?.message.content ?? '';
}
