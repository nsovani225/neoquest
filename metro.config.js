const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

// The Figma icons and illustrations are SVG files rendered with expo-image,
// so Metro has to treat .svg as an image asset.
if (!config.resolver.assetExts.includes('svg')) {
  config.resolver.assetExts.push('svg');
}

module.exports = config;
