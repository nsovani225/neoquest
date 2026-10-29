import React from 'react';
import { Platform, Pressable, StyleSheet, Text, View } from 'react-native';
import { Image } from 'expo-image';
import { img } from '../assets';
import { Activity, MAP_SIZE } from '../data';
import { GoogleMap } from './GoogleMap';
import { filters, font, list } from '../theme';

/**
 * The map from your /list frame: the map image, a title chip and numbered pins.
 * Pin positions are in the 365×570 Figma coordinates and scale with the map's width.
 * On web it's a live Google Map with the same selection behaviour; native still shows the static picture.
 */
export function ActivityMap({
  items,
  selectedId,
  onSelect,
  width,
  height,
  title = 'Nearby options · click a card',
  rounded = true,
}: {
  items: Activity[];
  selectedId?: number;
  onSelect?: (id: number) => void;
  width: number;
  height: number;
  title?: string;
  rounded?: boolean;
}) {
  const sx = width / MAP_SIZE.w;
  const sy = height / MAP_SIZE.h;
  return (
    <View style={[styles.map, { width, height }, rounded ? { borderRadius: 21, borderWidth: 1 } : null]}>
      {Platform.OS === 'web' ? (
        <GoogleMap items={items} selectedId={selectedId} onSelect={onSelect} infoWindow={false} />
      ) : (
        /* "fill" keeps the pins lined up with the map when its shape changes. */
        <Image source={img.map} style={StyleSheet.absoluteFill} contentFit="fill" />
      )}
      <View style={styles.titleChip}>
        <Text style={styles.titleText}>{title}</Text>
      </View>
      {Platform.OS !== 'web' && items.map((a) => {
        const selected = a.id === selectedId;
        return (
          <Pressable
            key={a.id}
            accessibilityRole="button"
            accessibilityLabel={`${a.name} on map`}
            onPress={() => onSelect?.(a.id)}
            hitSlop={6}
            style={{ position: 'absolute', left: a.pin.x * sx, top: a.pin.y * sy, width: 52.326, height: 52.326, alignItems: 'center', justifyContent: 'center', zIndex: selected ? 2 : 1 }}
          >
            {/* Teardrop pin: three rounded corners, rotated so the sharp corner points down. */}
            <View style={[styles.pin, selected && { backgroundColor: filters.lime, transform: [{ rotate: '-45deg' }, { scale: 1.15 }] }]}>
              <View style={{ transform: [{ rotate: '45deg' }] }}>
                <Text style={[styles.pinText, selected && { color: list.ink }]}>{a.id}</Text>
              </View>
            </View>
          </Pressable>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  map: { overflow: 'hidden', borderColor: list.mapBorder, backgroundColor: '#E9E9E4' },
  titleChip: { position: 'absolute', left: 13, right: 13, top: 13, height: 41, borderRadius: 13, backgroundColor: 'rgba(255,255,255,0.94)', justifyContent: 'center', paddingHorizontal: 13, zIndex: 3 },
  titleText: { fontFamily: font.interBold, fontSize: 13, color: list.ink },
  pin: {
    width: 37,
    height: 37,
    backgroundColor: list.ink,
    borderTopLeftRadius: 50,
    borderTopRightRadius: 50,
    borderBottomRightRadius: 50,
    transform: [{ rotate: '-45deg' }],
    alignItems: 'center',
    justifyContent: 'center',
  },
  pinText: { fontFamily: font.interBold, fontSize: 12, color: '#FFFFFF' },
});
