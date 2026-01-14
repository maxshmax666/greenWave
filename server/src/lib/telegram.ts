import crypto from 'node:crypto';

type TelegramUser = {
  id: number;
  username?: string;
  first_name?: string;
  last_name?: string;
  photo_url?: string;
};

export type TelegramInitData = {
  auth_date: number;
  query_id?: string;
  user?: TelegramUser;
};

const toHmac = (key: Buffer, data: string): string =>
  crypto.createHmac('sha256', key).update(data).digest('hex');

export const verifyInitData = (
  initData: string,
  botToken: string,
  maxAgeSeconds: number
): { ok: true; data: TelegramInitData } | { ok: false; error: string } => {
  if (!initData) {
    return { ok: false, error: 'Missing initData.' };
  }

  const params = new URLSearchParams(initData);
  const hash = params.get('hash');
  if (!hash) {
    return { ok: false, error: 'Missing hash.' };
  }
  params.delete('hash');

  const dataCheckString = [...params.entries()]
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([key, value]) => `${key}=${value}`)
    .join('\n');

  const secretKey = crypto.createHash('sha256').update(botToken).digest();
  const computedHash = toHmac(secretKey, dataCheckString);

  if (!crypto.timingSafeEqual(Buffer.from(computedHash), Buffer.from(hash))) {
    return { ok: false, error: 'Invalid initData signature.' };
  }

  const authDate = Number(params.get('auth_date'));
  if (!Number.isFinite(authDate)) {
    return { ok: false, error: 'Invalid auth_date.' };
  }

  const nowSeconds = Math.floor(Date.now() / 1000);
  if (nowSeconds - authDate > maxAgeSeconds) {
    return { ok: false, error: 'initData expired.' };
  }

  const userRaw = params.get('user');
  let user: TelegramUser | undefined;
  if (userRaw) {
    try {
      user = JSON.parse(userRaw) as TelegramUser;
    } catch (error) {
      return { ok: false, error: 'Invalid user payload.' };
    }
  }

  return {
    ok: true,
    data: {
      auth_date: authDate,
      query_id: params.get('query_id') ?? undefined,
      user
    }
  };
};
