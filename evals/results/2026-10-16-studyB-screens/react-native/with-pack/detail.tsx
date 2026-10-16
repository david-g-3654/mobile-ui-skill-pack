import React, { useState } from 'react';
import { Alert, Pressable, Share, StyleSheet, View } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import Svg, { Circle, Defs, Ellipse, G, Path, Pattern, Rect } from 'react-native-svg';
import { metrics, palettes, radius, space, tabular, useQTheme } from '../../pack04/theme';
import {
  QBottomActionBar,
  QIconButton,
  QPrimaryButton,
  QScreen,
  QSwatch,
  QText,
  useQLargeText,
} from '../../pack04/components';

const colorways = [
  { name: 'Chalk / stone', color: palettes.light.canvas, panel: palettes.light.track },
  { name: 'Graphite / chalk', color: palettes.light.ink2, panel: palettes.light.ink2 },
];
const sizes = ['7', '8', '8.5', '9', '9.5', '10'];
const price = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(138);

function SneakerArtwork({ graphite }: { graphite: boolean }) {
  const shoe = palettes.light;
  const upper = graphite ? shoe.ink2 : shoe.canvas;
  const overlay = graphite ? shoe.ink : shoe.track;

  return (
    <Svg width="100%" height="100%" viewBox="0 0 480 400" accessible={false}>
      <Defs>
        <Pattern id="mesh" width="5" height="5" patternUnits="userSpaceOnUse">
          <Circle cx="2" cy="2" r="0.65" fill={graphite ? shoe.track : shoe.ink3} opacity="0.55" />
        </Pattern>
      </Defs>
      <Ellipse cx="246" cy="302" rx="174" ry="16" fill={shoe.ink} opacity="0.05" />
      <Ellipse cx="247" cy="302" rx="133" ry="9" fill={shoe.ink} opacity="0.05" />
      <G rotation="-14" origin="240,210">
        <Path d="M57 245 C49 258 61 277 84 280 L365 282 Q413 279 428 261 L429 250 L57 245Z" fill={shoe.ink2} />
        <Path d="M59 230 Q48 242 57 258 Q61 271 94 273 L354 275 Q405 275 431 254 L430 238 Q400 244 367 238 L59 230Z" fill={shoe.canvas} stroke={shoe.track} strokeWidth="1.5" />
        <Path d="M59 251 Q191 259 322 261 Q395 264 427 246" fill="none" stroke={shoe.track} strokeWidth="2" />
        <Path d="M70 266 L74 277 M90 268 L94 280 M114 269 L117 281 M140 269 L142 282 M168 270 L169 282 M198 270 L198 282 M227 271 L227 283 M258 272 L257 283 M288 271 L287 283 M318 272 L316 283 M348 272 L345 282 M377 267 L374 278 M402 260 L401 269" stroke={shoe.ink2} strokeWidth="3" />
        <Path d="M62 233 L67 146 Q69 135 84 139 L122 164 Q148 176 171 153 L196 121 Q207 109 222 124 L286 188 Q304 200 334 205 L383 214 Q414 220 428 239 Q397 256 350 252 L103 248 Q73 247 62 233Z" fill={upper} stroke={shoe.track} strokeWidth="1.5" />
        <Path d="M82 164 Q102 173 119 182 Q153 194 180 166 L201 138 L280 203 Q295 216 323 216 L376 225 Q399 230 408 239 Q352 246 281 241 L88 234Z" fill="url(#mesh)" />
        <Path d="M72 144 Q82 134 95 145 L125 167 Q147 178 168 154 L190 126 L201 133 L181 173 Q159 200 123 188 L79 165Z" fill={overlay} />
        <Path d="M86 147 L119 171 Q140 184 164 161 L184 138 Q171 167 157 174 Q138 185 120 177Z" fill={shoe.ink2} />
        <Path d="M63 224 L69 172 L86 175 L108 215 L139 243 L97 244 Q76 244 63 235Z" fill={overlay} />
        <Path d="M75 186 L84 185 L102 218 L123 238 L97 236 Q82 234 74 227Z" fill="none" stroke={graphite ? shoe.ink2 : shoe.canvas} strokeWidth="1.5" strokeDasharray="3 3" />
        <Path d="M201 120 Q213 107 224 122 L283 184 L261 207 L183 159Z" fill={shoe.canvas} stroke={shoe.track} strokeWidth="2" />
        <Path d="M215 125 L232 139 L226 148 L209 133Z" fill={shoe.ink2} />
        <Path d="M165 177 L183 156 L263 199 L276 213 L259 228 L229 219 L207 194 L189 199Z" fill={overlay} />
        <Path d="M165 185 L146 213 L167 216 L186 194 L195 216 L217 220 L204 183 L189 180 L167 201 L176 184Z" fill={graphite ? shoe.canvas : shoe.ink2} />
        <Path d="M287 204 Q308 210 338 210 L378 218 Q406 224 420 239 L389 246 Q373 226 350 227 L305 225 L277 231 L254 227Z" fill={overlay} />
        <Path d="M290 214 Q317 221 345 218 Q383 220 400 238" fill="none" stroke={shoe.canvas} strokeWidth="1.5" strokeDasharray="3 3" />
        <Path d="M175 169 L195 158 M189 182 L209 170 M203 193 L222 182 M218 203 L236 194 M233 213 L250 204" stroke={shoe.ink2} strokeWidth="7" strokeLinecap="round" />
        <Path d="M175 167 L195 156 M189 180 L209 168 M203 191 L222 180 M218 201 L236 192 M233 211 L250 202" stroke={shoe.surface} strokeWidth="4" strokeLinecap="round" />
        <Path d="M185 162 Q167 144 175 141 Q189 140 195 159 Q206 139 213 144 Q218 153 196 163" fill="none" stroke={shoe.surface} strokeWidth="3" strokeLinecap="round" />
        <Path d="M193 161 Q187 177 174 183 M196 162 Q203 175 207 182" fill="none" stroke={shoe.surface} strokeWidth="3" strokeLinecap="round" />
        <Path d="M63 226 Q88 250 144 248 L350 253 Q400 254 428 240" fill="none" stroke={shoe.surface} strokeWidth="4" />
        <Path d="M87 151 L85 174" stroke={shoe.canvas} strokeWidth="3" />
      </G>
    </Svg>
  );
}

export default function SneakerDetail() {
  const { c } = useQTheme();
  const largeText = useQLargeText();
  const [colorIndex, setColorIndex] = useState(0);
  const [size, setSize] = useState('9');
  const [saved, setSaved] = useState(false);
  const [expanded, setExpanded] = useState<string | null>(null);
  const [bagCount, setBagCount] = useState(0);
  const colorway = colorways[colorIndex];

  function addToBag() {
    setBagCount((count) => count + 1);
    void Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success).catch(() => {});
    Alert.alert('Added to your bag', `Forme Track 02\n${colorway.name} · US men's ${size}\n${price}`, [{ text: 'Keep exploring' }]);
  }

  async function shareProduct() {
    try {
      await Share.share({ message: `Forme Track 02 — ${colorway.name}. An everyday runner, ${price}.` });
    } catch {
      Alert.alert('Couldn’t share this pair', 'Please try again.');
    }
  }

  return (
    <View style={[styles.root, { backgroundColor: c.canvas }]}>
      <StatusBar style="auto" />
      <Stack.Screen options={{
        title: 'Forme',
        headerLargeTitle: false,
        headerShadowVisible: false,
        headerStyle: { backgroundColor: c.canvas },
        headerTintColor: c.ink,
        contentStyle: { backgroundColor: c.canvas },
        headerRight: () => (
          <View style={styles.navActions}>
            <QIconButton
              icon={saved ? 'heart' : 'heart-outline'}
              label={saved ? 'Remove from saved sneakers' : 'Save sneaker'}
              onPress={() => {
                setSaved((value) => !value);
                void Haptics.selectionAsync().catch(() => {});
              }}
            />
            <QIconButton icon="share-outline" label="Share sneaker" onPress={shareProduct} />
          </View>
        ),
      }} />

      <QScreen contentContainerStyle={styles.scrollContent}>
        <View
          style={[styles.media, { backgroundColor: c.surface2 }]}
          accessible
          accessibilityRole="image"
          accessibilityLabel={`Side profile of the Forme Track 02 sneaker in ${colorway.name}, with mesh panels and a sculpted sole`}
        >
          <SneakerArtwork graphite={colorIndex === 1} />
          <View style={styles.mediaCaption} accessible={false}>
            <QText variant="footnote" color="ink2">The daily rotation</QText>
            <QText variant="footnote" color="ink2" style={tabular}>01 / 01</QText>
          </View>
        </View>

        <View style={styles.productContent}>
          <View style={styles.intro}>
            <QText variant="subhead" color="ink2">Unisex everyday sneakers</QText>
            <View style={[styles.titleRow, largeText && styles.stacked]}>
              <QText variant="title" role="header" style={styles.grow}>Track 02</QText>
              <QText variant="title" style={tabular}>{price}</QText>
            </View>
            <View style={styles.rating} accessible accessibilityLabel="Rated 4.8 out of 5 from 128 reviews">
              <Ionicons name="star-outline" size={space.md} color={c.accent} />
              <QText variant="subhead" color="ink2">4.8 · 128 reviews</QText>
            </View>
          </View>

          <View style={styles.optionSection}>
            <View style={styles.inlineLabel}>
              <QText variant="headline">Color</QText>
              <QText variant="subhead" color="ink2">{colorway.name}</QText>
            </View>
            <View style={styles.swatches} accessibilityRole="radiogroup" accessibilityLabel="Sneaker color">
              {colorways.map((option, index) => (
                <QSwatch key={option.name} name={option.name} color={option.color} selected={index === colorIndex} onPress={() => setColorIndex(index)} size={space.xxl} />
              ))}
            </View>
          </View>

          <View style={styles.optionSection}>
            <View style={[styles.sizeHeading, largeText && styles.stacked]}>
              <QText variant="headline">Size · US men’s</QText>
              <Pressable
                accessibilityRole="button"
                onPress={() => Alert.alert('Find your fit', 'Fits true to size. Between sizes? Go half a size up.\n\nUS 7 · 25 cm\nUS 8 · 26 cm\nUS 8.5 · 26.5 cm\nUS 9 · 27 cm\nUS 9.5 · 27.5 cm\nUS 10 · 28 cm\n\nMeasure from heel to longest toe. For US women’s sizing, add 1.5.')}
                style={({ pressed }) => [styles.guide, pressed && { opacity: 0.6 }]}
              >
                <QText variant="subhead" color="ink2" style={styles.underlined}>Size guide</QText>
              </Pressable>
            </View>
            <View style={styles.sizes} accessibilityRole="radiogroup" accessibilityLabel="US men's shoe size">
              {sizes.map((option) => (
                <Pressable
                  key={option}
                  accessibilityRole="radio"
                  accessibilityLabel={`US men's ${option}`}
                  accessibilityState={{ selected: option === size }}
                  onPress={() => {
                    setSize(option);
                    void Haptics.selectionAsync().catch(() => {});
                  }}
                  style={({ pressed }) => [styles.size, {
                    borderColor: option === size ? c.ink : c.hairline,
                    borderWidth: option === size ? 2 : StyleSheet.hairlineWidth,
                    backgroundColor: pressed ? c.surface2 : c.canvas,
                  }]}
                >
                  <QText variant="subhead" style={tabular}>{option}</QText>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.reassurance}>
            <Ionicons name="cube-outline" size={space.lg} color={c.ink2} />
            <QText variant="footnote" color="ink2" style={styles.grow}>Free shipping & 30-day returns</QText>
          </View>

          <View>
            {[
              { title: 'A little retro. All day ready.', body: 'Inspired by track classics. Built for everything after. Breathable mesh meets soft suede, with a cushioned footbed and a durable rubber outsole.\n\nSuede and recycled-mesh upper. Removable footbed. Designed for everyday wear.' },
              { title: 'Delivery & returns', body: 'Complimentary standard shipping in 3–5 business days. Return unworn sneakers in their original box within 30 days for a full refund.' },
            ].map((section) => (
              <View key={section.title} style={{ borderTopWidth: StyleSheet.hairlineWidth, borderTopColor: c.hairline }}>
                <Pressable
                  accessibilityRole="button"
                  accessibilityLabel={section.title}
                  accessibilityState={{ expanded: expanded === section.title }}
                  onPress={() => setExpanded(expanded === section.title ? null : section.title)}
                  style={({ pressed }) => [styles.disclosure, pressed && { backgroundColor: c.surface2 }]}
                >
                  <QText variant="headline" style={styles.grow}>{section.title}</QText>
                  <Ionicons name={expanded === section.title ? 'remove-outline' : 'add-outline'} size={space.lg} color={c.ink2} />
                </Pressable>
                {expanded === section.title && <QText variant="subhead" color="ink2" style={styles.description}>{section.body}</QText>}
              </View>
            ))}
          </View>
        </View>
      </QScreen>

      <QBottomActionBar>
        {bagCount > 0 && !largeText && (
          <QText variant="footnote" color="ink2" style={styles.bagStatus}>{bagCount === 1 ? '1 pair' : `${bagCount} pairs`} in your bag</QText>
        )}
        <QPrimaryButton title="Add to bag" onPress={addToBag} accessibilityHint={`Add Track 02, ${colorway.name}, size ${size}, ${price}, to your bag`} />
      </QBottomActionBar>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1 },
  navActions: { flexDirection: 'row', alignItems: 'center', gap: space.xs },
  scrollContent: { paddingHorizontal: 0, paddingTop: 0, gap: 0 },
  media: { width: '100%', aspectRatio: 1, maxHeight: 440 },
  mediaCaption: { position: 'absolute', bottom: space.md, left: space.margin, right: space.margin, flexDirection: 'row', justifyContent: 'space-between' },
  productContent: { paddingHorizontal: space.margin, paddingTop: space.xl, gap: space.xxl, width: '100%', maxWidth: 640, alignSelf: 'center' },
  intro: { gap: space.xs },
  titleRow: { flexDirection: 'row', justifyContent: 'space-between', gap: space.sm, alignItems: 'baseline' },
  stacked: { flexDirection: 'column', alignItems: 'flex-start', gap: space.xs },
  grow: { flex: 1 },
  rating: { flexDirection: 'row', alignItems: 'center', gap: space.xxs },
  optionSection: { gap: space.sm },
  inlineLabel: { flexDirection: 'row', alignItems: 'baseline', flexWrap: 'wrap', gap: space.xs },
  swatches: { flexDirection: 'row', gap: space.md, alignItems: 'center' },
  sizeHeading: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', gap: space.xs },
  guide: { minHeight: metrics.minTap, justifyContent: 'center' },
  underlined: { textDecorationLine: 'underline' },
  sizes: { flexDirection: 'row', flexWrap: 'wrap', gap: space.xs },
  size: { minWidth: metrics.minTap, minHeight: metrics.minTap, paddingHorizontal: space.sm, paddingVertical: space.sm, borderRadius: radius.s, alignItems: 'center', justifyContent: 'center', flexGrow: 1 },
  reassurance: { flexDirection: 'row', alignItems: 'center', gap: space.xs },
  disclosure: { flexDirection: 'row', alignItems: 'center', gap: space.sm, paddingVertical: space.md, minHeight: metrics.rowMinHeight },
  description: { paddingBottom: space.lg },
  bagStatus: { textAlign: 'center' },
});
