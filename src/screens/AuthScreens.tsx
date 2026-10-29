import React, { useState } from 'react';
import { Alert, KeyboardAvoidingView, Platform, Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { Image } from 'expo-image';
import { SafeAreaView } from 'react-native-safe-area-context';
import { img } from '../assets';
import { auth, font } from '../theme';
import { useWide } from '../components/ui';
import { GoogleSignInButton } from '../components/GoogleSignInButton';
import type { ScreenProps } from '../navigation';

/** Grey top bar + card with the lavender offset shadow, shared by Sign In and Create Account. */
function AuthLayout({ children, onLogo }: { children: React.ReactNode; onLogo: () => void }) {
  const { wide } = useWide();
  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: auth.bar }} edges={['top']}>
      <View style={styles.bar}>
        <Pressable accessibilityRole="link" onPress={onLogo}>
          <Text style={styles.brand}>neoquest</Text>
        </Pressable>
      </View>
      <KeyboardAvoidingView style={{ flex: 1, backgroundColor: auth.bg }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        <ScrollView contentContainerStyle={{ paddingTop: wide ? 92 : 40, paddingBottom: 60, paddingHorizontal: 20, alignItems: 'center' }} keyboardShouldPersistTaps="handled">
          <View style={{ width: '100%', maxWidth: 537 }}>
            <View style={styles.cardShadow} />
            <View style={[styles.card, { paddingHorizontal: wide ? 51 : 24, paddingTop: wide ? 90 : 40, paddingBottom: wide ? 90 : 40, minHeight: wide ? 760 : undefined }]}>
              {children}
            </View>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

function Field({
  placeholder,
  value,
  onChangeText,
  secure,
  keyboardType,
  autoComplete,
}: {
  placeholder: string;
  value: string;
  onChangeText: (t: string) => void;
  secure?: boolean;
  keyboardType?: 'email-address';
  autoComplete?: 'email' | 'password' | 'name' | 'new-password';
}) {
  const { wide } = useWide();
  const [hidden, setHidden] = useState(true);
  return (
    <View style={[styles.field, { height: wide ? 74 : 60 }]}>
      <TextInput
        value={value}
        onChangeText={onChangeText}
        placeholder={placeholder}
        placeholderTextColor={auth.ink}
        secureTextEntry={secure && hidden}
        keyboardType={keyboardType}
        autoCapitalize={keyboardType || secure ? 'none' : 'words'}
        autoComplete={autoComplete}
        style={[styles.input, { fontSize: wide ? 24 : 18 }]}
      />
      {secure && (
        <Pressable accessibilityRole="button" accessibilityLabel={hidden ? 'Show password' : 'Hide password'} onPress={() => setHidden((h) => !h)} hitSlop={10}>
          <Image source={img.eye} style={{ width: 24, height: 24, opacity: hidden ? 1 : 0.5 }} />
        </Pressable>
      )}
    </View>
  );
}

function PrimaryButton({ label, onPress, disabled }: { label: string; onPress: () => void; disabled?: boolean }) {
  const { wide } = useWide();
  return (
    <Pressable
      accessibilityRole="button"
      onPress={onPress}
      disabled={disabled}
      style={({ pressed }) => [styles.button, { height: wide ? 74 : 60, opacity: disabled ? 0.5 : pressed ? 0.85 : 1 }]}
    >
      <Text style={[styles.buttonText, { fontSize: wide ? 24 : 20 }]}>{label}</Text>
    </Pressable>
  );
}

/** "or" divider + Google button, shared by both screens. */
function GoogleOption({ onSignedIn }: { onSignedIn: () => void }) {
  const { wide } = useWide();
  return (
    <View style={{ marginTop: wide ? 26 : 22, gap: 16 }}>
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
        <View style={styles.rule} />
        <Text style={[styles.or, { fontSize: wide ? 20 : 16 }]}>or</Text>
        <View style={styles.rule} />
      </View>
      <GoogleSignInButton width={wide ? 380 : 280} onSignedIn={onSignedIn} />
    </View>
  );
}

function SwitchLine({ text, link, onPress }: { text: string; link: string; onPress: () => void }) {
  const { wide } = useWide();
  return (
    <Text style={[styles.switch, { fontSize: wide ? 24 : 18 }]}>
      {text}
      <Text accessibilityRole="link" onPress={onPress} style={styles.link}>
        {link}
      </Text>
    </Text>
  );
}

export function SignInScreen({ navigation }: ScreenProps<'SignIn'>) {
  const { wide } = useWide();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  return (
    <AuthLayout onLogo={() => navigation.navigate('Home')}>
      <Text style={[styles.h1, { fontSize: wide ? 48 : 36 }]}>Welcome Back!</Text>
      <Text style={[styles.sub, { fontSize: wide ? 24 : 18 }]}>Sign in to continue to your account</Text>
      <View style={{ gap: wide ? 26 : 16, marginTop: wide ? 26 : 22 }}>
        <Field placeholder="Email" value={email} onChangeText={setEmail} keyboardType="email-address" autoComplete="email" />
        <View style={{ gap: 12 }}>
          <Field placeholder="Password" value={password} onChangeText={setPassword} secure autoComplete="password" />
          <Pressable accessibilityRole="link" style={{ alignSelf: 'flex-end' }} onPress={() => Alert.alert('Forgot password', 'Password reset isn’t connected yet.')}>
            <Text style={[styles.forgot, { fontSize: wide ? 24 : 18 }]}>Forgot password?</Text>
          </Pressable>
        </View>
      </View>
      <View style={{ marginTop: wide ? 26 : 24 }}>
        {/* No backend yet: signing in just takes you to Home. */}
        <PrimaryButton label="Sign In" onPress={() => navigation.navigate('Home')} disabled={!email || !password} />
      </View>
      <GoogleOption onSignedIn={() => navigation.navigate('Home')} />
      <View style={{ marginTop: wide ? 40 : 28, alignItems: 'center' }}>
        <SwitchLine text="Don’t have an account? " link="Sign up" onPress={() => navigation.replace('SignUp')} />
      </View>
    </AuthLayout>
  );
}

export function SignUpScreen({ navigation }: ScreenProps<'SignUp'>) {
  const { wide } = useWide();
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const passwordOk = password.length >= 8 && /\d/.test(password);

  return (
    <AuthLayout onLogo={() => navigation.navigate('Home')}>
      <View style={{ marginTop: wide ? 17 : 0 }}>
        <Text style={[styles.h1, { fontSize: wide ? 40 : 32 }]}>Create your account!</Text>
        <Text style={[styles.sub, { fontSize: wide ? 24 : 18 }]}>Start in less than a minute</Text>
      </View>
      <View style={{ gap: 12, marginTop: wide ? 12 : 20 }}>
        <Field placeholder="Full name" value={name} onChangeText={setName} autoComplete="name" />
        <Field placeholder="Email" value={email} onChangeText={setEmail} keyboardType="email-address" autoComplete="email" />
        <View style={{ gap: 6 }}>
          <Field placeholder="Password" value={password} onChangeText={setPassword} secure autoComplete="new-password" />
          <Text style={[styles.hint, password.length > 0 && !passwordOk && { color: '#C0352B' }]}>At least 8 characters, with a number</Text>
        </View>
      </View>
      <View style={{ marginTop: wide ? 26 : 24 }}>
        {/* No backend yet: creating an account just takes you to Home. */}
        <PrimaryButton label="Create Account" onPress={() => navigation.navigate('Home')} disabled={!name || !email || !passwordOk} />
      </View>
      <GoogleOption onSignedIn={() => navigation.navigate('Home')} />
      <View style={{ marginTop: wide ? 25 : 28, alignItems: 'center' }}>
        <SwitchLine text="Already have an account? " link="Sign in" onPress={() => navigation.replace('SignIn')} />
      </View>
    </AuthLayout>
  );
}

const styles = StyleSheet.create({
  bar: { height: 77, backgroundColor: auth.bar, justifyContent: 'center', paddingHorizontal: 31 },
  brand: { fontFamily: font.interBold, fontSize: 24, color: '#000000' },
  cardShadow: { position: 'absolute', left: 15, top: 15, right: -15, bottom: -15, backgroundColor: auth.cardShadow, borderRadius: 10 },
  card: { backgroundColor: auth.card, borderRadius: 10 },
  h1: { fontFamily: font.interBold, color: '#000000' },
  sub: { fontFamily: font.interBold, color: '#000000', marginTop: 4 },
  field: { backgroundColor: '#FFFFFF', borderRadius: 15, flexDirection: 'row', alignItems: 'center', paddingLeft: 18, paddingRight: 22 },
  input: { flex: 1, minWidth: 0, height: '100%', fontFamily: font.interBold, color: auth.ink },
  forgot: { fontFamily: font.interBold, color: auth.link },
  button: { backgroundColor: auth.ink, borderRadius: 15, alignItems: 'center', justifyContent: 'center' },
  buttonText: { fontFamily: font.interBold, color: '#FFFFFF' },
  switch: { fontFamily: font.interBold, color: '#000000', textAlign: 'center' },
  link: { color: auth.link, textDecorationLine: 'underline' },
  rule: { flex: 1, height: 1, backgroundColor: auth.ink, opacity: 0.25 },
  or: { fontFamily: font.interBold, color: auth.ink },
  hint: { fontFamily: font.interBold, fontSize: 16, color: auth.ink, paddingLeft: 8 },
});
