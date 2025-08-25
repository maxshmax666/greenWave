import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://example.supabase.co';
const SUPABASE_ANON_KEY = 'public-anon-key';

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
