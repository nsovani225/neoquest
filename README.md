# NeoQuest — React Native (Expo)

React Native version of your NeoQuest screens from the Figma file
[NEOQUEST-WEBAPP](https://www.figma.com/design/KQIMUbY9eN13IMvK09UH9y/NEOQUEST-WEBAPP) (Cover page).
The Figma file was only read, never changed.

## Run it

```bash
npm install        # also downloads your Figma images into assets/figma/
npx expo start     # then press w (browser), i (iOS simulator), or scan the QR code with Expo Go
```

The app needs all 10 images in `assets/figma/` before it will start. To fetch them again:
`npm run fetch-assets` (add `-- --force` to re-download).

## Screens and how they connect

| Screen | Figma section | Web URL | Gets you to |
| --- | --- | --- | --- |
| Home | Home | `/` | Map, Activities (List), Sign In; "Contact" scrolls down |
| Map | /map | `/map` | Filters, List view |
| List | /list | `/list` | Filters, Map (from "View option"), Home |
| Filters | /filters | `/filters` | List (with filters applied), Sign In (avatar) |
| Sign In | /signin | `/signin` | Create Account, Home |
| Create Account | /signup | `/signup` | Sign In, Home |

At 900px wide and up, screens follow the 1280px desktop frames. Below that (phones) they stack:
the list hides its side map behind a "Map" button, and the filter categories become a swipeable row.

## What works

- **Filters** are real: pick options in any of the 8 categories, apply, and the List and Map
  show only matching activities. Activity, distance, budget, duration and rating narrow the
  results. Group size, transportation and availability are saved but need real venue data
  to filter anything. "Side quest mode" picks three random activities.
- **Map pins** highlight when you tap them or the matching card.
- **Sign In / Create Account** have working fields, a show/hide password eye, and a live password
  check. There's no backend yet, so both buttons just take you to Home.

## Things that differ from Figma

- **"NeoQuest" title**: it's a code layer in Figma whose source I couldn't read, so it's text in
  the Outfit Light font. Swap `font.title` in `src/theme.ts` if you know the real font.
- **/map screen**: in Figma it's an empty embed placeholder, so the Map screen is built from the
  map, pins and cards on your /list frame.
- **Home embeds**: the box beside the hero headline uses the Figma placeholder image (link icon);
  the big box under "Explore the Map" shows the map picture and opens the Map screen.
- **Filter options**: only the Activity editor is designed in Figma. The other seven categories
  use placeholder options in `src/data.ts`; edit them there.
- **"View option" on the Map** opens Google Maps directions, since there's no detail screen.
- **"Get In Touch"** doesn't go anywhere yet (marked `TODO` in `HomeScreen.tsx`).
- The hidden "Testimonial section" in the Home frame (1px wide in Figma) isn't included.

## Structure

| Path | What it is |
| --- | --- |
| `App.tsx` | Fonts, navigation, web URLs |
| `src/theme.ts` | Colors and fonts per screen, from Figma |
| `src/data.ts` | The 4 activities, filter categories, and filter logic |
| `src/FiltersContext.tsx` | Shares applied filters between Filters, List and Map |
| `src/components/` | Gradient text, pill button, activity card, map with pins |
| `src/screens/` | One file per screen (Sign In and Create Account share `AuthScreens.tsx`) |
| `scripts/fetch-assets.mjs` | Downloads the Figma images |
