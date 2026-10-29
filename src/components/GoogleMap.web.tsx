import React, { useEffect, useRef, useState } from 'react';
import { Text, View } from 'react-native';
import { Activity } from '../data';
import { font, list } from '../theme';

declare const google: any;

const API_KEY = process.env.EXPO_PUBLIC_GOOGLE_MAPS_API_KEY;

let loader: Promise<void> | undefined;
/** Loads the Google Maps JavaScript API once per page. */
function loadMaps(): Promise<void> {
  if (loader) return loader;
  loader = new Promise((resolve, reject) => {
    if ((window as any).google?.maps) return resolve();
    (window as any).__neoquestMapsReady = () => resolve();
    const s = document.createElement('script');
    s.src = `https://maps.googleapis.com/maps/api/js?key=${API_KEY}&callback=__neoquestMapsReady&loading=async`;
    s.async = true;
    s.onerror = () => reject(new Error('Google Maps failed to load'));
    document.head.appendChild(s);
  });
  loader.catch(() => (loader = undefined));
  return loader;
}

/** Live Google Map with one marker per activity. Clicking a marker opens its info window. */
export function GoogleMap({
  items,
  selectedId,
  onSelect,
  infoWindow = true,
  zoom,
}: {
  items: Activity[];
  selectedId?: number;
  onSelect?: (id: number) => void;
  infoWindow?: boolean;
  zoom?: number;
}) {
  const el = useRef<HTMLDivElement>(null);
  const mapRef = useRef<any>(null);
  const markersRef = useRef<Map<number, any>>(new Map());
  const [ready, setReady] = useState(false);
  const onSelectRef = useRef(onSelect);
  onSelectRef.current = onSelect;
  const [error, setError] = useState<string | undefined>(API_KEY ? undefined : 'Add EXPO_PUBLIC_GOOGLE_MAPS_API_KEY to .env to show the map.');

  useEffect(() => {
    if (!API_KEY) return;
    let markers: any[] = [];
    let cancelled = false;
    loadMaps()
      .then(() => {
        if (cancelled || !el.current) return;
        const map = new google.maps.Map(el.current, {
          center: items[0]?.coords ?? { lat: 37.8715, lng: -122.273 },
          zoom: 12,
          mapTypeControl: false,
          streetViewControl: false,
          fullscreenControl: true,
        });
        const info = new google.maps.InfoWindow();
        const bounds = new google.maps.LatLngBounds();
        markers = items.map((a) => {
          const m = new google.maps.Marker({
            map,
            position: a.coords,
            title: a.name,
          });
          markersRef.current.set(a.id, m);
          bounds.extend(a.coords);
          m.addListener('click', () => {
            if (!infoWindow) return onSelectRef.current?.(a.id);
            const box = document.createElement('div');
            const b = document.createElement('strong');
            b.textContent = a.name;
            const meta = document.createElement('div');
            meta.textContent = `${a.rating}★ · ${a.price} · ${a.miles} mi`;
            const link = document.createElement('a');
            link.href = `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(a.name)}`;
            link.target = '_blank';
            link.rel = 'noopener noreferrer';
            link.textContent = 'Open in Google Maps';
            box.append(b, meta, link);
            info.setContent(box);
            if (infoWindow) info.open({ map, anchor: m });
            onSelectRef.current?.(a.id);
          });
          return m;
        });
        if (items.length > 1) map.fitBounds(bounds, 60);
        else if (items.length === 1) map.setZoom(zoom ?? 15);
        mapRef.current = map;
        setReady(true);
      })
      .catch((e) => setError(e.message));
    return () => {
      cancelled = true;
      markers.forEach((m) => m.setMap(null));
      markersRef.current.clear();
      mapRef.current = null;
      setReady(false);
    };
  }, [items, infoWindow, zoom]);

  // Restyle markers when the selection changes: lime + enlarged when selected.
  useEffect(() => {
    if (!ready) return;
    markersRef.current.forEach((m, id) => {
      const sel = id === selectedId;
      m.setIcon({
        path: google.maps.SymbolPath.CIRCLE,
        scale: sel ? 16 : 13,
        fillColor: sel ? '#D9FA62' : '#171717',
        fillOpacity: 1,
        strokeColor: sel ? '#171717' : '#FFFFFF',
        strokeWeight: 2,
      });
      m.setLabel({ text: String(id), color: sel ? '#171717' : '#FFFFFF', fontWeight: '700', fontSize: '12px' });
      m.setZIndex(sel ? 10 : 1);
    });
    const sel = selectedId != null ? markersRef.current.get(selectedId) : undefined;
    if (sel && items.length > 1) mapRef.current?.panTo(sel.getPosition());
  }, [ready, selectedId, items]);

  if (error) {
    return (
      <View style={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, alignItems: 'center', justifyContent: 'center', padding: 24, backgroundColor: '#E9E9E4' }}>
        <Text style={{ fontFamily: font.inter, fontSize: 14, color: list.ink, textAlign: 'center' }}>{error}</Text>
      </View>
    );
  }
  return <div ref={el} style={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0 }} />;
}
