import { useState, useCallback } from 'react';

export function useMenu(initial = false) {
  const [visible, setVisible] = useState(initial);
  const toggle = useCallback(() => setVisible((v) => !v), []);
  const hide = useCallback(() => setVisible(false), []);
  return { visible, toggle, hide };
}
