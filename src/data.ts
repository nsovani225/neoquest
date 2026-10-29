// Activity data from your /list frame. Pin positions are the pins on its map (365×570 map).
export type Activity = {
  id: number;
  name: string;
  tags: string[];
  miles: number;
  rating: number;
  vibe: string;
  durationLabel: string;
  hours: [number, number]; // min/max duration, used by the Duration filter
  price: 'Free' | '$' | '$$' | '$$$';
  pin: { x: number; y: number };
  coords: { lat: number; lng: number }; // real location, used by the Google Map
};

export const activities: Activity[] = [
  { id: 1, name: 'Berkeley Marina', tags: ['Outdoor', 'Water'], miles: 2.1, rating: 4.5, vibe: 'Great for groups', durationLabel: 'Around 1–2 hours', hours: [1, 2], price: '$$', pin: { x: 127.4, y: 142.25 }, coords: { lat: 37.8693, lng: -122.3153 } },
  { id: 2, name: 'Lake Anza', tags: ['Outdoor', 'Scenic'], miles: 4.3, rating: 4.7, vibe: 'Scenic spot', durationLabel: 'Around 2 hours', hours: [2, 2], price: 'Free', pin: { x: 254.45, y: 238.81 }, coords: { lat: 37.8975, lng: -122.2415 } },
  { id: 3, name: 'Adventure Playground', tags: ['Adventure', 'Recreation'], miles: 2.8, rating: 4.6, vibe: 'Casual & fun', durationLabel: 'Around 1 hour', hours: [1, 1], price: 'Free', pin: { x: 167.33, y: 324.01 }, coords: { lat: 37.8728, lng: -122.3157 } },
  { id: 4, name: 'Tilden Regional Park', tags: ['Recreation', 'Explore'], miles: 5.1, rating: 4.8, vibe: 'Lots to explore', durationLabel: '2+ hours', hours: [2, 4], price: '$', pin: { x: 290, y: 376 }, coords: { lat: 37.9056, lng: -122.254 } },
];

export const MAP_SIZE = { w: 365, h: 570 };

// ---- Filters ----------------------------------------------------------------
// Only the Activity editor is designed in Figma. The options for the other seven
// categories are placeholders that follow the same pattern — edit them here.

export type FilterKey =
  | 'activity'
  | 'distance'
  | 'budget'
  | 'group'
  | 'duration'
  | 'rating'
  | 'transport'
  | 'availability';

export type FilterCategory = {
  key: FilterKey;
  icon: string;
  label: string;
  anyLabel: string;
  description: string;
  question: string;
  multi: boolean;
  options: string[];
};

export const filterCategories: FilterCategory[] = [
  { key: 'activity', icon: '✳', label: 'Activity', anyLabel: 'Any activity', description: 'Choose the kind of side quest your group is in the mood for.', question: 'What sounds good?', multi: true, options: ['Food & drinks', 'Outdoor', 'Sports', 'Adventure', 'Arts & culture', 'Explore', 'Games', 'Chill'] },
  { key: 'distance', icon: '⌖', label: 'Distance', anyLabel: 'Any distance', description: 'How far is everyone willing to go?', question: 'Maximum distance', multi: false, options: ['Under 1 mi', 'Under 3 mi', 'Under 5 mi', 'Under 10 mi'] },
  { key: 'budget', icon: '$', label: 'Budget', anyLabel: 'Any budget', description: 'Set a price range that works for the whole group.', question: 'Price range', multi: true, options: ['Free', '$', '$$', '$$$'] },
  { key: 'group', icon: '+', label: 'Group size', anyLabel: 'Any group size', description: 'How many people are coming along?', question: 'Group size', multi: false, options: ['Solo', '2–3', '4–6', '7+'] },
  { key: 'duration', icon: '◷', label: 'Duration', anyLabel: 'Any duration', description: 'How much time does your group have?', question: 'Time available', multi: false, options: ['Up to 1 hour', 'Up to 2 hours', '2+ hours'] },
  { key: 'rating', icon: '☆', label: 'Rating', anyLabel: 'Any rating', description: 'Only show places other explorers loved.', question: 'Minimum rating', multi: false, options: ['4.0+', '4.5+', '4.7+'] },
  { key: 'transport', icon: '↗', label: 'Transportation', anyLabel: 'Any transport', description: 'How is your group getting there?', question: 'Getting there', multi: true, options: ['Walk', 'Bike', 'Transit', 'Car'] },
  { key: 'availability', icon: '◉', label: 'Availability', anyLabel: 'Any time', description: 'When does your group want to go?', question: 'When', multi: false, options: ['Open now', 'This evening', 'This weekend'] },
];

export type FilterState = Record<FilterKey, string[]>;

export const emptyFilters = (): FilterState => ({
  activity: [], distance: [], budget: [], group: [], duration: [], rating: [], transport: [], availability: [],
});

/**
 * Applies the filters the sample data can answer (activity, distance, budget, duration, rating).
 * Group size, transportation and availability need real venue data, so they don't narrow results yet.
 */
export function applyFilters(items: Activity[], f: FilterState): Activity[] {
  return items.filter((a) => {
    if (f.activity.length && !f.activity.some((t) => a.tags.includes(t))) return false;
    if (f.distance.length) {
      const max = parseFloat(f.distance[0].replace(/[^0-9.]/g, ''));
      if (a.miles >= max) return false;
    }
    if (f.budget.length && !f.budget.includes(a.price)) return false;
    if (f.duration.length) {
      const d = f.duration[0];
      if (d === 'Up to 1 hour' && a.hours[1] > 1) return false;
      if (d === 'Up to 2 hours' && a.hours[1] > 2) return false;
      if (d === '2+ hours' && a.hours[1] < 2) return false;
    }
    if (f.rating.length && a.rating < parseFloat(f.rating[0])) return false;
    return true;
  });
}

export const countActive = (f: FilterState) => Object.values(f).reduce((n, v) => n + v.length, 0);
