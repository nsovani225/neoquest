import React from 'react';
import { Text } from 'react-native';
import { auth, font } from '../theme';

/** Google sign-in is web-only for now; native needs expo-auth-session and per-platform client IDs. */
export function GoogleSignInButton(_props: { width: number; onSignedIn: () => void }) {
  return <Text style={{ fontFamily: font.interBold, fontSize: 14, color: auth.ink, textAlign: 'center' }}>Google sign-in is available on web.</Text>;
}
