import React, { useEffect, useRef, useState } from 'react';
import { Text, View } from 'react-native';
import { GOOGLE_CLIENT_ID, useAuth } from '../AuthContext';
import { auth, font } from '../theme';

declare const google: any;

let loader: Promise<void> | undefined;
/** Loads Google Identity Services once per page. */
function loadGis(): Promise<void> {
  if (loader) return loader;
  loader = new Promise((resolve, reject) => {
    if ((window as any).google?.accounts?.id) return resolve();
    const s = document.createElement('script');
    s.src = 'https://accounts.google.com/gsi/client';
    s.async = true;
    s.onload = () => resolve();
    s.onerror = () => reject(new Error('Google sign-in failed to load'));
    document.head.appendChild(s);
  });
  loader.catch(() => (loader = undefined));
  return loader;
}

/** Google's own "Sign in with Google" button. `onSignedIn` fires after the profile is saved. */
export function GoogleSignInButton({ width, onSignedIn }: { width: number; onSignedIn: () => void }) {
  const el = useRef<HTMLDivElement>(null);
  const { signInWithGoogle } = useAuth();
  const [error, setError] = useState<string | undefined>(GOOGLE_CLIENT_ID ? undefined : 'Add EXPO_PUBLIC_GOOGLE_CLIENT_ID to .env to enable Google sign-in.');
  const cb = useRef({ signInWithGoogle, onSignedIn });
  cb.current = { signInWithGoogle, onSignedIn };

  useEffect(() => {
    if (!GOOGLE_CLIENT_ID) return;
    let cancelled = false;
    loadGis()
      .then(() => {
        if (cancelled || !el.current) return;
        google.accounts.id.initialize({
          client_id: GOOGLE_CLIENT_ID,
          callback: async (r: { credential: string }) => {
            if (await cb.current.signInWithGoogle(r.credential)) cb.current.onSignedIn();
            else setError('Sign-in failed. Is the auth server running (npm run server)?');
          },
        });
        google.accounts.id.renderButton(el.current, { type: 'standard', theme: 'outline', size: 'large', text: 'continue_with', shape: 'pill', width });
      })
      .catch((e) => setError(e.message));
    return () => {
      cancelled = true;
    };
  }, [width]);

  if (error) return <Text style={{ fontFamily: font.interBold, fontSize: 14, color: auth.ink, textAlign: 'center' }}>{error}</Text>;
  return (
    <View style={{ alignItems: 'center' }}>
      <div ref={el} />
    </View>
  );
}
