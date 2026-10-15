// Fixture: what an agent typically produces without the pack. The linter must flag it.
import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, ActivityIndicator, TextInput } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

export default function ProfileScreen({ loading }: { loading: boolean }) {
  if (loading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator size="large" color="#007AFF" />
      </View>
    );
  }
  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity>
          <Text style={styles.back}>{'< Back'}</Text>
        </TouchableOpacity>
        <Text style={styles.title}>Profile</Text>
        <TouchableOpacity onPress={() => {}}>
          <Ionicons name="menu" size={24} color="#333" />
        </TouchableOpacity>
      </View>
      <View style={styles.card}>
        <Text style={styles.name}>Jane Smith</Text>
        <Text style={styles.subtitle}>⭐ Premium Member</Text>
      </View>
      <View style={styles.card}>
        <TextInput placeholder="Email" style={styles.input} />
      </View>
      <View style={styles.card}>
        <Text style={styles.item}>Item 1</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f2f2f2', paddingTop: 44, padding: 15 },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  header: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 10 },
  back: { color: '#007AFF', fontSize: 17 },
  title: { fontSize: 20, fontWeight: 'bold' },
  card: { backgroundColor: 'white', borderRadius: 10, padding: 15, marginBottom: 10, shadowOpacity: 0.1, elevation: 4 },
  name: { fontSize: 22, fontWeight: 'bold' },
  subtitle: { fontSize: 14, color: 'gray', fontWeight: '700' },
  input: { borderWidth: 1, borderColor: '#ccc', padding: 10, fontSize: 16 },
  item: { fontSize: 15, fontWeight: 'bold' },
});
