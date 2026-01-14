import Fastify from 'fastify';
import cors from '@fastify/cors';

import { env } from './lib/env.js';
import { registerAuthRoutes } from './routes/auth.js';
import { registerSettingsRoutes } from './routes/settings.js';
import { registerOrderRoutes } from './routes/orders.js';

const server = Fastify({
  logger: true
});

await server.register(cors, {
  origin: env.CORS_ORIGIN,
  credentials: true
});

await registerAuthRoutes(server);
await registerSettingsRoutes(server);
await registerOrderRoutes(server);

try {
  await server.listen({ port: Number(env.PORT), host: '0.0.0.0' });
} catch (error) {
  server.log.error(error);
  process.exit(1);
}
