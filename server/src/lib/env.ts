import { z } from 'zod';

const envSchema = z.object({
  PORT: z.string().optional().default('3001'),
  CORS_ORIGIN: z.string().optional().default('*'),
  SUPABASE_URL: z.string().url(),
  SUPABASE_SERVICE_ROLE_KEY: z.string().min(1),
  TELEGRAM_BOT_TOKEN: z.string().min(1),
  TELEGRAM_AUTH_MAX_AGE_SECONDS: z.preprocess(
    (value) => (value ? Number(value) : 86400),
    z.number().int().positive()
  ),
  AUTH_JWT_SECRET: z.string().min(32),
  ADMIN_API_KEY: z.string().min(16)
});

export type Env = z.infer<typeof envSchema>;

export const env = envSchema.parse(process.env);
