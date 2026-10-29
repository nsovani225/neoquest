import React, { createContext, useCallback, useContext, useEffect, useMemo, useState } from 'react';

export const GOOGLE_CLIENT_ID = process.env.EXPO_PUBLIC_GOOGLE_CLIENT_ID;
const API_URL = process.env.EXPO_PUBLIC_API_URL ?? 'http://localhost:3001';

export type User = { id: string; name: string; email: string; picture?: string };

type AuthValue = {
  user: User | null;
  /** Sends the ID token Google returned to the server to be verified. Resolves true once signed in. */
  signInWithGoogle: (credential: string) => Promise<boolean>;
  signOut: () => void;
};

const AuthCtx = createContext<AuthValue | null>(null);

/** The session lives in an httpOnly cookie set by the server (see server/index.mjs). */
const api = (path: string, init?: RequestInit) =>
  fetch(`${API_URL}${path}`, { credentials: 'include', headers: { 'Content-Type': 'application/json' }, ...init });

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);

  // Restore the session after a refresh. A missing or unreachable server just means signed out.
  useEffect(() => {
    api('/auth/me')
      .then((r) => (r.ok ? r.json() : null))
      .then((d) => d && setUser(d.user))
      .catch(() => {});
  }, []);

  const signInWithGoogle = useCallback(async (credential: string) => {
    try {
      const r = await api('/auth/google', { method: 'POST', body: JSON.stringify({ credential }) });
      if (!r.ok) return false;
      setUser((await r.json()).user);
      return true;
    } catch {
      return false;
    }
  }, []);

  const signOut = useCallback(() => {
    setUser(null);
    api('/auth/logout', { method: 'POST' }).catch(() => {});
    try {
      (window as any).google?.accounts?.id?.disableAutoSelect();
    } catch {}
  }, []);

  const value = useMemo(() => ({ user, signInWithGoogle, signOut }), [user, signInWithGoogle, signOut]);
  return <AuthCtx.Provider value={value}>{children}</AuthCtx.Provider>;
}

export function useAuth() {
  const v = useContext(AuthCtx);
  if (!v) throw new Error('useAuth must be used inside AuthProvider');
  return v;
}
