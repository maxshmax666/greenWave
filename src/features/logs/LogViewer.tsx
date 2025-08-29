import React, { useEffect, useState } from 'react';
import {
  Modal,
  View,
  ScrollView,
  Text,
  Button,
  StyleSheet,
} from 'react-native';
import * as FileSystem from 'expo-file-system';

export interface LogViewerProps {
  visible: boolean;
  onClose: () => void;
}

export default function LogViewer({ visible, onClose }: LogViewerProps) {
  const [lines, setLines] = useState<string[]>([]);

  useEffect(() => {
    if (!visible) return;
    FileSystem.readAsStringAsync('data/app.log')
      .then((content) => setLines(content.split('\n').filter((l) => l.length)))
      .catch(() => setLines([]));
  }, [visible]);

  return (
    <Modal transparent visible={visible} animationType="slide">
      <View style={styles.container}>
        <ScrollView style={styles.scroll}>
          {lines.map((line, i) => (
            <Text key={i} style={styles.line}>
              {line}
            </Text>
          ))}
        </ScrollView>
        <Button title="Close" onPress={onClose} />
      </View>
    </Modal>
  );
}

const BG = 'white';
const styles = StyleSheet.create({
  container: { backgroundColor: BG, flex: 1, padding: 16 },
  line: { fontFamily: 'monospace', fontSize: 12 },
  scroll: { flex: 1, marginBottom: 8 },
});
