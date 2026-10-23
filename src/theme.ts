// Colors and fonts taken from your NeoQuest frames in Figma (Cover page).
export const home = {
  bg: '#090D16',
  lavender: '#C4D1E8', // the "--background" variable: borders, Sign In button, numbers
  ink: '#333333', // the "--back" variable
  accent: '#DFECC6', // pill buttons
  navPill: 'rgba(45,212,191,0.4)',
  body: 'rgba(255,255,255,0.85)',
  divider: '#E9E9E9',
  gradient: ['#2DD4BF', '#99F6E4', '#8B5CF6'] as const,
};

export const auth = {
  bg: '#FFFFFF',
  bar: '#D9D9D9',
  card: '#D9D9D9',
  cardShadow: '#C4D1E8',
  ink: '#333333',
  link: '#1362EF',
};

export const list = {
  bg: '#F5F5F1',
  ink: '#171717',
  border: '#E4E4DF',
  muted: '#666666',
  subtle: '#747474',
  faint: '#777777',
  mapBorder: '#DDDCD6',
};

export const filters = {
  bg: '#F4F4EF',
  lime: '#D9FA62',
  ink: '#191A18',
  dark: '#1D1E1B',
  button: '#1C1D1A',
  muted: '#777971',
  muted2: '#686A62',
  muted3: '#989A91',
  label: '#74766D',
  border: '#E5E6DF',
  chipBorder: '#D4D6CE',
  chipText: '#5D5F57',
  sidebar: '#FAFAF7',
  iconBg: '#EEEFE8',
  panel: '#F8F8F5',
  tag: '#F1F2EC',
  avatar: '#E2E3DC',
};

export const font = {
  display: 'PlusJakartaSans_800ExtraBold',
  title: 'Outfit_300Light', // stand-in for the "NeoQuest" code layer (its source isn't readable)
  sans: 'DMSans_400Regular',
  sansBold: 'DMSans_700Bold',
  mono: 'RobotoMono_400Regular',
  serif: 'CrimsonText_400Regular',
  inter: 'Inter_400Regular',
  interSemi: 'Inter_600SemiBold',
  interBold: 'Inter_700Bold',
};

/** Below this width screens switch to their phone layout. */
export const WIDE = 900;
