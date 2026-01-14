import type { FastifyInstance } from 'fastify';
import { z } from 'zod';

import { requireAuth } from '../middleware/auth.js';
import { supabaseAdmin } from '../lib/supabase.js';

const orderPayloadSchema = z.object({
  items: z
    .array(
      z.object({
        sku: z.string().min(1),
        title: z.string().min(1),
        quantity: z.number().int().positive(),
        price: z.number().nonnegative()
      })
    )
    .min(1),
  note: z.string().max(500).optional()
});

const getSettings = async () => {
  const { data, error } = await supabaseAdmin
    .from('ordering_settings')
    .select('*')
    .single();
  if (error || !data) {
    throw error ?? new Error('Missing settings.');
  }
  return data;
};

export const registerOrderRoutes = async (
  fastify: FastifyInstance
): Promise<void> => {
  fastify.post('/orders', async (request, reply) => {
    const user = await requireAuth(request, reply);
    if (!user) {
      return;
    }

    const parsed = orderPayloadSchema.safeParse(request.body);
    if (!parsed.success) {
      reply.status(400).send({ error: 'Invalid payload.' });
      return;
    }

    let settings;
    try {
      settings = await getSettings();
    } catch (error) {
      reply.status(500).send({ error: 'Failed to load settings.' });
      return;
    }

    if (!settings.ordering_enabled && !settings.preorder_enabled) {
      reply.status(409).send({
        error: 'Ordering is disabled.',
        preorder_available: false
      });
      return;
    }

    const orderType = settings.ordering_enabled ? 'regular' : 'preorder';

    const { data: order, error } = await supabaseAdmin
      .from('orders')
      .insert({
        user_profile_id: user.userId,
        order_type: orderType,
        status: 'pending',
        payload: parsed.data
      })
      .select()
      .single();

    if (error || !order) {
      reply.status(500).send({ error: 'Failed to create order.' });
      return;
    }

    reply.send({ order, order_type: orderType });
  });
};
