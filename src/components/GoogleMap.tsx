import React from 'react';
import { StyleSheet } from 'react-native';
import { Image } from 'expo-image';
import { img } from '../assets';
import { Activity } from '../data';

/** Native fallback: the live Google Map is web-only for now, so show the static map image. */
export function GoogleMap(_props: { items: Activity[]; selectedId?: number; onSelect?: (id: number) => void; infoWindow?: boolean; zoom?: number }) {
  return <Image source={img.map} style={StyleSheet.absoluteFill} contentFit="cover" />;
}
