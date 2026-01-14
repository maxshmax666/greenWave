import type { FastifyInstance } from 'fastify';
import jwt from 'jsonwebtoken';
import { z } from 'zod';

import { env } from '../lib/env.js';
import { supabaseAdmin } from '../lib/supabase.js';
import { verifyInitData } from '../lib/telegram.js';

const telegramAuthSchema = z.object({
  initData: z.string().min(1)
});

export const registerAuthRoutes = async (
  fastify: FastifyInstance
): Promise<void> => {
  fastify.post('/auth/telegram', async (request, reply) => {
    const parsed = telegramAuthSchema.safeParse(request.body);
    if (!parsed.success) {
      reply.status(400).send({ error: 'Invalid payload.' });
      return;
    }

    const { initData } = parsed.data;
    const verification = verifyInitData(
      initData,
      env.TELEGRAM_BOT_TOKEN,
      env.TELEGRAM_AUTH_MAX_AGE_SECONDS
    );

    if (!verification.ok) {
      reply.status(401).send({ error: verification.error });
      return;
    }

    const telegramUser = verification.data.user;
    if (!telegramUser?.id) {
      reply.status(400).send({ error: 'Telegram user missing.' });
      return;
    }

    const displayName = [
      telegramUser.first_name,
      telegramUser.last_name
    ]
      .filter(Boolean)
      .join(' ')
      .trim();

    const { data: profile, error } = await supabaseAdmin
      .from('user_profiles')
      .upsert(
        {
          telegram_id: telegramUser.id,
          username: telegramUser.username ?? null,
          display_name: displayName || telegramUser.username || null,
          avatar_url: telegramUser.photo_url ?? null,
          last_login_at: new Date().toISOString()
        },
        { onConflict: 'telegram_id' }
      )
      .select()
      .single();

    if (error || !profile) {
      reply.status(500).send({ error: 'Failed to persist profile.' });
      return;
    }

    const token = jwt.sign(
      { userId: profile.id, telegramId: telegramUser.id },
      env.AUTH_JWT_SECRET,
      { expiresIn: '7d' }
    );

    reply.send({ token, profile });
  });
};
