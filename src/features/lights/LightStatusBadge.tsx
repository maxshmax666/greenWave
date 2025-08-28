import React, { useEffect, useRef, useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { getUpcomingPhase, UpcomingPhase } from '../../services/lights';

const overlay = '#00000088';

interface Props {
  lightId: string;
}

export function LightStatusBadge({ lightId }: Props) {
  const [phase, setPhase] = useState<UpcomingPhase | null>(null);
  const nextRef = useRef<UpcomingPhase | null>(null);
  const [seconds, setSeconds] = useState(0);

  useEffect(() => {
    let mounted = true;
    async function load() {
      const current = await getUpcomingPhase(lightId);
      if (!mounted || !current) return;
      setPhase(current);
      const upcoming = await getUpcomingPhase(
        lightId,
        new Date(Date.now() + current.startIn * 1000),
      );
      if (mounted) nextRef.current = upcoming;
      setSeconds(Math.ceil(current.startIn));
    }
    load();
    const id = setInterval(() => {
      setSeconds((s) => {
        if (s <= 1) {
          const next = nextRef.current;
          if (next) {
            setPhase(next);
            getUpcomingPhase(
              lightId,
              new Date(Date.now() + next.startIn * 1000),
            ).then((p) => {
              nextRef.current = p;
            });
            return Math.ceil(next.startIn);
          }
          return 0;
        }
        return s - 1;
      });
    }, 1000);
    return () => {
      mounted = false;
      clearInterval(id);
    };
  }, [lightId]);

  if (!phase) return null;

  const icon =
    phase.direction === 'MAIN'
      ? '🟢'
      : phase.direction === 'SECONDARY'
        ? '🟡'
        : '🚶';

  return (
    <View style={styles.badge}>
      <Text>
        {icon} {seconds}s
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  badge: {
    backgroundColor: overlay,
    borderRadius: 4,
    padding: 4,
  },
});
