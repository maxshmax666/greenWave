import type { FastifyInstance } from 'fastify';
import { z } from 'zod';

import { env } from '../lib/env.js';
import { supabaseAdmin } from '../lib/supabase.js';

const settingsSchema = z.object({
  ordering_enabled: z.boolean(),
  preorder_enabled: z.boolean()
});

const ensureSettings = async () => {
  const { data, error } = await supabaseAdmin
    .from('ordering_settings')
    .select('*')
    .single();

  if (data) {
    return data;
  }

  if (error && error.code !== 'PGRST116') {
    throw error;
  }

  const { data: inserted, error: insertError } = await supabaseAdmin
    .from('ordering_settings')
    .insert({ ordering_enabled: true, preorder_enabled: true })
    .select()
    .single();

  if (insertError || !inserted) {
    throw insertError ?? new Error('Failed to create settings.');
  }

  return inserted;
};

export const registerSettingsRoutes = async (
  fastify: FastifyInstance
): Promise<void> => {
  fastify.get('/ordering-settings', async (_, reply) => {
    try {
      const settings = await ensureSettings();
      reply.send(settings);
    } catch (error) {
      reply.status(500).send({ error: 'Failed to load settings.' });
    }
  });

  fastify.patch('/ordering-settings', async (request, reply) => {
    const adminKey = request.headers['x-admin-key'];
    if (adminKey !== env.ADMIN_API_KEY) {
      reply.status(403).send({ error: 'Forbidden.' });
      return;
    }

    const parsed = settingsSchema.safeParse(request.body);
    if (!parsed.success) {
      reply.status(400).send({ error: 'Invalid payload.' });
      return;
    }

    const { data, error } = await supabaseAdmin
      .from('ordering_settings')
      .update({ ...parsed.data, updated_at: new Date().toISOString() })
      .eq('id', 1)
      .select()
      .single();

    if (error || !data) {
      reply.status(500).send({ error: 'Failed to update settings.' });
      return;
    }

    reply.send(data);
  });
};
