# NeoQuest — React Native (Expo)

React Native version of the NeoQuest screens from the Figma file
[NEOQUEST-WEBAPP](https://www.figma.com/design/KQIMUbY9eN13IMvK09UH9y/NEOQUEST-WEBAPP) (Cover page).
Runs on iOS, Android and the web.

## Getting started

You need [Node.js](https://nodejs.org) (which includes npm). Open a new Terminal window and run
these one at a time.

1. **Get the project.** If you have the zip, unzip it (skip this if double-clicking the zip
   already made a `neoquest` folder in Downloads):

   ```bash
   cd ~/Downloads && unzip -o neoquest.zip
   ```

   If you're getting it from GitHub instead, clone it:

   ```bash
   git clone https://github.com/YOUR-USERNAME/neoquest.git
   ```

2. **Go into the folder:**

   ```bash
   cd ~/Downloads/neoquest
   ```

   (or `cd neoquest` if you just cloned it)

3. **Install the packages and download the Figma images:**

   ```bash
   npm install
   ```

   It should end with `10/10 Figma images in assets/figma/`. You only need to do this once.

4. **Start the app:**

   ```bash
   npx expo start
   ```

   When the QR code appears, press `w` to open it in your browser. To run it on your phone,
   install **Expo Go** and scan the QR code (phone and computer on the same Wi-Fi). Press `i`
   for the iOS simulator if Xcode is installed.

To stop the app, press `Ctrl + C`. Next time, you only need steps 2 and 4.

### Troubleshooting

- **Expo asks to use another port:** press `Y`. Another Expo app is still running in the background.
- **`Unable to resolve "../assets/figma/..."`:** an image didn't download. Run `npm run fetch-assets`
  and check which file it reports. The Figma download links expire after about a week, so once
  `assets/figma/` is filled, keep those files committed.
- **"high severity vulnerabilities" after `npm install`:** normal for a new Expo project; they're
  in development tools, not the app. Don't run `npm audit fix --force`, which can break Expo's
  package versions.

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

## Differences from the Figma design

- **"NeoQuest" title:** it's a code layer in Figma whose source couldn't be read, so it's text in
  the Outfit Light font. Change `font.title` in `src/theme.ts` to use the real font.
- **/map screen:** in Figma it's an empty embed placeholder, so the Map screen is built from the
  map, pins and cards on the /list frame. It's a static picture, not a live map.
- **Home embeds:** the box beside the hero headline uses the Figma placeholder image (link icon);
  the big box under "Explore the Map" shows the map picture and opens the Map screen.
- **Filter options:** only the Activity editor is designed in Figma. The other seven categories
  use placeholder options in `src/data.ts`.
- **"View option" on the Map** opens Google Maps directions, since there's no detail screen.
- **"Get In Touch"** doesn't go anywhere yet (marked `TODO` in `HomeScreen.tsx`).
- The hidden "Testimonial section" in the Home frame (1px wide in Figma) isn't included.

## Project structure

| Path | What it is |
| --- | --- |
| `App.tsx` | Fonts, navigation, web URLs |
| `src/theme.ts` | Colors and fonts per screen, from Figma |
| `src/data.ts` | The 4 activities, filter categories, and filter logic |
| `src/FiltersContext.tsx` | Shares applied filters between Filters, List and Map |
| `src/components/` | Gradient text, pill button, activity card, map with pins |
| `src/screens/` | One file per screen (Sign In and Create Account share `AuthScreens.tsx`) |
| `assets/figma/` | Images exported from Figma |
| `scripts/fetch-assets.mjs` | Downloads the Figma images (runs automatically on `npm install`) |
