import type { FastifyReply, FastifyRequest } from 'fastify';
import jwt from 'jsonwebtoken';

import { env } from '../lib/env.js';

export type AuthUser = {
  userId: string;
  telegramId: number;
};

export const requireAuth = async (
  request: FastifyRequest,
  reply: FastifyReply
): Promise<AuthUser | null> => {
  const header = request.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    reply.status(401).send({ error: 'Missing bearer token.' });
    return null;
  }

  const token = header.replace('Bearer ', '').trim();
  try {
    const payload = jwt.verify(token, env.AUTH_JWT_SECRET) as AuthUser;
    if (!payload?.userId || !payload?.telegramId) {
      reply.status(401).send({ error: 'Invalid token payload.' });
      return null;
    }
    return payload;
  } catch (error) {
    reply.status(401).send({ error: 'Invalid or expired token.' });
    return null;
  }
};
