jest.mock('../../../services/supabase', () => ({
  supabase: { from: jest.fn() },
}));
jest.mock('../../../services/logger', () => ({ log: jest.fn() }));

import { uploadCycle } from './uploadLightData';
import { supabase } from '../../../services/supabase';
import { log } from '../../../services/logger';

describe('uploadCycle', () => {
  it('logs and throws on insert error', async () => {
    const error = new Error('bad');
    (supabase.from as jest.Mock).mockReturnValueOnce({
      insert: jest.fn().mockResolvedValue({ error }),
    });
    await expect(uploadCycle(1, 2, 3, [])).rejects.toThrow('bad');
    expect(log).toHaveBeenCalledWith('ERROR', 'Failed to upload cycle: bad');
  });
});
