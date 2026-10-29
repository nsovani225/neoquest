// Auth API: verifies Google ID tokens server-side and keeps the session in an httpOnly cookie.
//   POST /auth/google  { credential }  -> verifies the token, sets the session cookie, returns the user
//   GET  /auth/me                      -> the signed-in user, or 401
//   POST /auth/logout                  -> clears the cookie
import express from 'express';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import jwt from 'jsonwebtoken';
import { OAuth2Client } from 'google-auth-library';

const CLIENT_ID = process.env.EXPO_PUBLIC_GOOGLE_CLIENT_ID?.trim();
const SECRET = process.env.SESSION_SECRET?.trim();
const PORT = Number(process.env.PORT ?? 3001);
const ORIGINS = (process.env.ALLOWED_ORIGINS ?? 'http://localhost:8081').split(',').map((s) => s.trim());
const PROD = process.env.NODE_ENV === 'production';
const COOKIE = 'nq_session';
const WEEK = 7 * 24 * 60 * 60;

if (!CLIENT_ID || !SECRET) {
  console.error('Set EXPO_PUBLIC_GOOGLE_CLIENT_ID and SESSION_SECRET in .env before starting the server.');
  process.exit(1);
}

const google = new OAuth2Client(CLIENT_ID);
const app = express();
app.use(cors({ origin: ORIGINS, credentials: true }));
app.use(express.json({ limit: '10kb' }));
app.use(cookieParser());

const cookieOptions = { httpOnly: true, sameSite: PROD ? 'none' : 'lax', secure: PROD, maxAge: WEEK * 1000, path: '/' };

app.post('/auth/google', async (req, res) => {
  const credential = req.body?.credential;
  if (typeof credential !== 'string') return res.status(400).json({ error: 'Missing credential' });
  try {
    // Checks the signature against Google's keys, plus audience, issuer and expiry.
    const ticket = await google.verifyIdToken({ idToken: credential, audience: CLIENT_ID });
    const p = ticket.getPayload();
    if (!p?.sub || !p.email || !p.email_verified) return res.status(401).json({ error: 'Unverified Google account' });
    const user = { id: p.sub, name: p.name ?? p.email, email: p.email, picture: p.picture };
    res.cookie(COOKIE, jwt.sign(user, SECRET, { algorithm: 'HS256', expiresIn: WEEK }), cookieOptions);
    res.json({ user });
  } catch {
    res.status(401).json({ error: 'Invalid Google credential' });
  }
});

app.get('/auth/me', (req, res) => {
  try {
    const { id, name, email, picture } = jwt.verify(req.cookies[COOKIE] ?? '', SECRET, { algorithms: ['HS256'] });
    res.json({ user: { id, name, email, picture } });
  } catch {
    res.status(401).json({ error: 'Not signed in' });
  }
});

app.post('/auth/logout', (_req, res) => {
  res.clearCookie(COOKIE, { ...cookieOptions, maxAge: undefined });
  res.json({ ok: true });
});

app.listen(PORT, () => console.log(`Auth API on http://localhost:${PORT} (allowing ${ORIGINS.join(', ')})`));
