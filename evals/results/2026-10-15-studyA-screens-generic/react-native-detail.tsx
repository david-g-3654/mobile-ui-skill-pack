import React, { useMemo, useState } from 'react';
import {
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
  useColorScheme,
  useWindowDimensions,
} from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';
import * as Haptics from 'expo-haptics';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import Svg, { Circle, Ellipse, G, Path } from 'react-native-svg';

type Colorway = {
  id: string;
  name: string;
  upper: string;
  accent: string;
  sole: string;
  bg: [string, string];
};

type Review = {
  id: string;
  author: string;
  rating: number;
  date: string;
  title: string;
  body: string;
  fit: string;
};

const PRODUCT = {
  brand: 'Stride Athletics',
  name: 'Aero Runner 2',
  category: "Men's Road Running Shoe",
  price: 145,
  compareAt: 165,
  rating: 4.7,
  reviewCount: 1284,
  description:
    'A lightweight daily trainer built for tempo days and long runs alike. A dual-density foam midsole delivers springy cushioning, while the engineered knit upper breathes and flexes with every stride.',
  highlights: [
    { icon: 'flash-outline' as const, label: 'Responsive foam', detail: 'Dual-density midsole, 8 mm drop' },
    { icon: 'leaf-outline' as const, label: 'Recycled knit', detail: '50% recycled polyester upper' },
    { icon: 'barbell-outline' as const, label: '248 g', detail: 'Weight, US men’s size 9' },
  ],
  details: [
    ['Style code', 'AR2-0417'],
    ['Heel-to-toe drop', '8 mm'],
    ['Stack height', '36 mm heel / 28 mm forefoot'],
    ['Outsole', 'Carbon rubber, high-wear zones'],
    ['Best for', 'Daily training, tempo runs'],
  ] as const,
};

const COLORWAYS: Colorway[] = [
  { id: 'volt', name: 'Volt / Black', upper: '#1C1C1E', accent: '#C6F432', sole: '#F2F2F2', bg: ['#EEF9D0', '#D7EE9B'] },
  { id: 'coral', name: 'Coral / Sail', upper: '#FF6B57', accent: '#FFFFFF', sole: '#FFF4E6', bg: ['#FFE6E0', '#FFC9BD'] },
  { id: 'glacier', name: 'Glacier Blue', upper: '#5B8DEF', accent: '#0B1F4D', sole: '#E8F0FF', bg: ['#E3ECFF', '#C3D5FF'] },
  { id: 'bone', name: 'Bone / Gum', upper: '#E9E2D6', accent: '#6B4F3A', sole: '#C48A4A', bg: ['#F5F1EA', '#E6DCCB'] },
];

const SIZES: { size: string; stock: 'in' | 'low' | 'out' }[] = [
  { size: '7', stock: 'in' },
  { size: '7.5', stock: 'out' },
  { size: '8', stock: 'in' },
  { size: '8.5', stock: 'in' },
  { size: '9', stock: 'low' },
  { size: '9.5', stock: 'in' },
  { size: '10', stock: 'in' },
  { size: '10.5', stock: 'low' },
  { size: '11', stock: 'in' },
  { size: '12', stock: 'out' },
  { size: '13', stock: 'in' },
];

const REVIEWS: Review[] = [
  {
    id: 'r1',
    author: 'Marcus T.',
    rating: 5,
    date: 'Sep 28, 2026',
    title: 'My new go-to for long runs',
    body: 'Did a 20-miler in these last weekend and my legs felt fresh after. Bouncy without feeling unstable.',
    fit: 'True to size',
  },
  {
    id: 'r2',
    author: 'Priya S.',
    rating: 4,
    date: 'Sep 14, 2026',
    title: 'Great cushioning, snug toe box',
    body: 'Love the ride and the colorway gets compliments. Toe box runs a little narrow, so I went up half a size.',
    fit: 'Runs slightly small',
  },
];

function SneakerArt({ colorway, width }: { colorway: Colorway; width: number }) {
  const h = width * 0.56;
  return (
    <Svg width={width} height={h} viewBox="0 0 320 180" accessibilityElementsHidden importantForAccessibility="no-hide-descendants">
      <Ellipse cx={165} cy={160} rx={130} ry={10} fill="#000" opacity={0.12} />
      <G>
        {/* Sole */}
        <Path
          d="M28 128 C 28 146, 50 152, 80 152 L 268 152 C 292 152, 304 140, 300 126 L 296 118 L 34 118 Z"
          fill={colorway.sole}
          stroke="#00000022"
          strokeWidth={1.5}
        />
        <Path d="M36 140 L 292 140" stroke="#00000018" strokeWidth={2} />
        {/* Upper */}
        <Path
          d="M34 120 C 30 96, 40 72, 66 62 C 86 54, 100 40, 118 34 C 132 30, 146 36, 154 50 C 168 72, 200 86, 236 94 C 268 101, 294 106, 298 122 Z"
          fill={colorway.upper}
        />
        {/* Heel tab */}
        <Path d="M60 66 C 48 74, 40 90, 40 112 L 58 112 C 58 94, 62 80, 72 70 Z" fill={colorway.accent} opacity={0.9} />
        {/* Swoosh-like stripe */}
        <Path
          d="M78 112 C 120 108, 190 92, 262 102 C 210 100, 150 116, 96 120 Z"
          fill={colorway.accent}
        />
        {/* Laces */}
        {[0, 1, 2, 3, 4].map((i) => (
          <Path
            key={i}
            d={`M${138 + i * 14} ${52 + i * 7} l 14 -8`}
            stroke={colorway.sole}
            strokeWidth={4}
            strokeLinecap="round"
          />
        ))}
        {/* Eyelets */}
        {[0, 1, 2, 3, 4].map((i) => (
          <Circle key={`e${i}`} cx={136 + i * 14} cy={56 + i * 7} r={2.2} fill={colorway.accent} />
        ))}
        {/* Toe cap */}
        <Path d="M250 98 C 274 102, 294 108, 298 122 L 262 122 C 262 112, 258 104, 250 98 Z" fill="#FFFFFF" opacity={0.18} />
      </G>
    </Svg>
  );
}

function Stars({ rating, size, color }: { rating: number; size: number; color: string }) {
  return (
    <View style={{ flexDirection: 'row' }} accessibilityElementsHidden importantForAccessibility="no-hide-descendants">
      {[1, 2, 3, 4, 5].map((i) => {
        const name = rating >= i ? 'star' : rating >= i - 0.5 ? 'star-half' : 'star-outline';
        return <Ionicons key={i} name={name} size={size} color={color} />;
      })}
    </View>
  );
}

export default function SneakerDetailScreen() {
  const scheme = useColorScheme();
  const dark = scheme === 'dark';
  const { width, fontScale } = useWindowDimensions();
  const insets = useSafeAreaInsets();
  const large = fontScale >= 1.35;

  const c = useMemo(
    () => ({
      bg: dark ? '#000000' : '#FFFFFF',
      surface: dark ? '#1C1C1E' : '#F2F2F7',
      card: dark ? '#1C1C1E' : '#FFFFFF',
      text: dark ? '#FFFFFF' : '#0A0A0A',
      secondary: dark ? '#A1A1A6' : '#5E5E63',
      border: dark ? '#38383A' : '#E3E3E8',
      tint: dark ? '#FFFFFF' : '#0A0A0A',
      onTint: dark ? '#000000' : '#FFFFFF',
      sale: '#D92D20',
      warn: dark ? '#FFB340' : '#B54708',
      star: '#F5A524',
      success: dark ? '#32D74B' : '#1E8E3E',
    }),
    [dark]
  );

  const [colorIdx, setColorIdx] = useState(0);
  const [size, setSize] = useState<string | null>(null);
  const [favorite, setFavorite] = useState(false);
  const [added, setAdded] = useState(false);
  const [showSizeError, setShowSizeError] = useState(false);
  const [detailsOpen, setDetailsOpen] = useState(false);

  const colorway = COLORWAYS[colorIdx];
  const selectedSize = SIZES.find((s) => s.size === size);
  const discount = Math.round((1 - PRODUCT.price / PRODUCT.compareAt) * 100);

  const onSelectColor = (i: number) => {
    Haptics.selectionAsync();
    setColorIdx(i);
  };

  const onSelectSize = (s: string) => {
    Haptics.selectionAsync();
    setSize(s);
    setShowSizeError(false);
    setAdded(false);
  };

  const onFavorite = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setFavorite((f) => !f);
  };

  const onAddToBag = () => {
    if (!size) {
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning);
      setShowSizeError(true);
      return;
    }
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    setAdded(true);
  };

  const sizeCols = large ? 3 : 4;
  const gutter = 16;
  const gap = 8;
  const sizeCellWidth = (width - gutter * 2 - gap * (sizeCols - 1)) / sizeCols;

  return (
    <View style={{ flex: 1, backgroundColor: c.bg }}>
      <Stack.Screen
        options={{
          title: '',
          headerTransparent: true,
          headerShadowVisible: false,
          headerBackTitle: 'Shop',
          headerTintColor: '#0A0A0A',
          headerRight: () => (
            <View style={{ flexDirection: 'row', gap: 4 }}>
              <Pressable
                onPress={() => Haptics.selectionAsync()}
                hitSlop={8}
                accessibilityRole="button"
                accessibilityLabel="Share"
                style={styles.headerBtn}
              >
                <Ionicons name={Platform.OS === 'ios' ? 'share-outline' : 'share-social-outline'} size={22} color="#0A0A0A" />
              </Pressable>
              <Pressable
                onPress={onFavorite}
                hitSlop={8}
                accessibilityRole="button"
                accessibilityLabel={favorite ? 'Remove from favorites' : 'Add to favorites'}
                accessibilityState={{ selected: favorite }}
                style={styles.headerBtn}
              >
                <Ionicons name={favorite ? 'heart' : 'heart-outline'} size={22} color={favorite ? c.sale : '#0A0A0A'} />
              </Pressable>
            </View>
          ),
        }}
      />
      <StatusBar style="dark" />

      <ScrollView
        contentInsetAdjustmentBehavior="never"
        contentContainerStyle={{ paddingBottom: 120 + insets.bottom }}
        showsVerticalScrollIndicator={false}
      >
        {/* Hero */}
        <LinearGradient colors={colorway.bg} start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }} style={{ paddingTop: insets.top + 56, paddingBottom: 24, alignItems: 'center' }}>
          <View
            accessible
            accessibilityRole="image"
            accessibilityLabel={`${PRODUCT.name} in ${colorway.name}`}
          >
            <SneakerArt colorway={colorway} width={Math.min(width - 32, 420)} />
          </View>
          <View style={styles.badgeRow}>
            <View style={[styles.badge, { backgroundColor: '#0A0A0A' }]}>
              <Text style={styles.badgeText} maxFontSizeMultiplier={1.6}>
                New season
              </Text>
            </View>
            <View style={[styles.badge, { backgroundColor: c.sale }]}>
              <Text style={styles.badgeText} maxFontSizeMultiplier={1.6}>
                {discount}% off
              </Text>
            </View>
          </View>
        </LinearGradient>

        <View style={{ paddingHorizontal: gutter, paddingTop: 20 }}>
          {/* Title block */}
          <Text style={[styles.brand, { color: c.secondary }]}>{PRODUCT.brand}</Text>
          <Text style={[styles.title, { color: c.text }]} accessibilityRole="header">
            {PRODUCT.name}
          </Text>
          <Text style={[styles.category, { color: c.secondary }]}>{PRODUCT.category}</Text>

          <View style={[styles.priceRow, large && { flexDirection: 'column', alignItems: 'flex-start' }]}>
            <View
              style={{ flexDirection: 'row', alignItems: 'baseline', gap: 8, flexWrap: 'wrap' }}
              accessible
              accessibilityLabel={`Price $${PRODUCT.price}, was $${PRODUCT.compareAt}`}
            >
              <Text style={[styles.price, { color: c.text }]}>${PRODUCT.price}</Text>
              <Text style={[styles.compareAt, { color: c.secondary }]}>${PRODUCT.compareAt}</Text>
            </View>
            <Pressable
              style={styles.ratingRow}
              accessibilityRole="button"
              accessibilityLabel={`Rated ${PRODUCT.rating} out of 5, ${PRODUCT.reviewCount.toLocaleString()} reviews`}
              hitSlop={6}
            >
              <Stars rating={PRODUCT.rating} size={16} color={c.star} />
              <Text style={[styles.ratingText, { color: c.secondary }]}>
                {PRODUCT.rating} ({PRODUCT.reviewCount.toLocaleString()})
              </Text>
            </Pressable>
          </View>

          {/* Colorways */}
          <View style={styles.section}>
            <Text style={[styles.sectionTitle, { color: c.text }]} accessibilityRole="header">
              Color: <Text style={{ fontWeight: '400', color: c.secondary }}>{colorway.name}</Text>
            </Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={{ gap: 12, paddingVertical: 4 }}>
              {COLORWAYS.map((cw, i) => {
                const selected = i === colorIdx;
                return (
                  <Pressable
                    key={cw.id}
                    onPress={() => onSelectColor(i)}
                    accessibilityRole="radio"
                    accessibilityLabel={cw.name}
                    accessibilityState={{ selected, checked: selected }}
                    style={({ pressed }) => [
                      styles.swatch,
                      {
                        borderColor: selected ? c.tint : c.border,
                        borderWidth: selected ? 2 : 1,
                        backgroundColor: c.surface,
                        opacity: pressed ? 0.7 : 1,
                      },
                    ]}
                  >
                    <LinearGradient colors={cw.bg} style={styles.swatchInner}>
                      <View style={[styles.swatchDot, { backgroundColor: cw.upper }]} />
                      <View style={[styles.swatchDotSmall, { backgroundColor: cw.accent }]} />
                    </LinearGradient>
                  </Pressable>
                );
              })}
            </ScrollView>
          </View>

          {/* Sizes */}
          <View style={styles.section}>
            <View style={[styles.sectionHeader, large && { flexDirection: 'column', alignItems: 'flex-start', gap: 4 }]}>
              <Text style={[styles.sectionTitle, { color: c.text, marginBottom: 0 }]} accessibilityRole="header">
                Select size (US)
              </Text>
              <Pressable accessibilityRole="link" hitSlop={8} style={{ flexDirection: 'row', alignItems: 'center', gap: 4, minHeight: 44 }}>
                <Ionicons name="resize-outline" size={16} color={c.secondary} />
                <Text style={[styles.link, { color: c.text }]}>Size guide</Text>
              </Pressable>
            </View>

            <View style={styles.sizeGrid} accessibilityRole="radiogroup">
              {SIZES.map((s) => {
                const selected = s.size === size;
                const disabled = s.stock === 'out';
                return (
                  <Pressable
                    key={s.size}
                    disabled={disabled}
                    onPress={() => onSelectSize(s.size)}
                    accessibilityRole="radio"
                    accessibilityLabel={`Size ${s.size}${disabled ? ', sold out' : s.stock === 'low' ? ', only a few left' : ''}`}
                    accessibilityState={{ selected, checked: selected, disabled }}
                    style={({ pressed }) => [
                      styles.sizeCell,
                      {
                        width: sizeCellWidth,
                        backgroundColor: selected ? c.tint : c.card,
                        borderColor: selected ? c.tint : showSizeError ? c.sale : c.border,
                        opacity: disabled ? 0.4 : pressed ? 0.75 : 1,
                      },
                    ]}
                  >
                    <Text
                      style={[
                        styles.sizeText,
                        { color: selected ? c.onTint : c.text, textDecorationLine: disabled ? 'line-through' : 'none' },
                      ]}
                    >
                      {s.size}
                    </Text>
                    {s.stock === 'low' && !selected && (
                      <View style={[styles.lowDot, { backgroundColor: c.warn }]} />
                    )}
                  </Pressable>
                );
              })}
            </View>

            {showSizeError ? (
              <View style={styles.inlineMsg} accessibilityLiveRegion="polite" accessibilityRole="alert">
                <Ionicons name="alert-circle" size={16} color={c.sale} />
                <Text style={[styles.inlineMsgText, { color: c.sale }]}>Please select a size to continue.</Text>
              </View>
            ) : selectedSize?.stock === 'low' ? (
              <View style={styles.inlineMsg}>
                <Ionicons name="time-outline" size={16} color={c.warn} />
                <Text style={[styles.inlineMsgText, { color: c.warn }]}>Only 3 left in size {selectedSize.size}.</Text>
              </View>
            ) : (
              <Text style={[styles.inlineMsgText, { color: c.secondary, marginTop: 10 }]}>
                Fits true to size. Wide feet? Consider going up half a size.
              </Text>
            )}
          </View>

          {/* Delivery */}
          <View style={[styles.infoCard, { backgroundColor: c.surface }]}>
            <View style={styles.infoRow}>
              <Ionicons name="cube-outline" size={22} color={c.text} />
              <View style={{ flex: 1 }}>
                <Text style={[styles.infoTitle, { color: c.text }]}>Free delivery Fri, Oct 18</Text>
                <Text style={[styles.infoSub, { color: c.secondary }]}>Order within 4 hr 12 min</Text>
              </View>
            </View>
            <View style={[styles.divider, { backgroundColor: c.border }]} />
            <View style={styles.infoRow}>
              <Ionicons name="refresh-outline" size={22} color={c.text} />
              <View style={{ flex: 1 }}>
                <Text style={[styles.infoTitle, { color: c.text }]}>30-day wear test</Text>
                <Text style={[styles.infoSub, { color: c.secondary }]}>Run in them. Return them free if they’re not right.</Text>
              </View>
            </View>
          </View>

          {/* Highlights */}
          <View style={styles.section}>
            <Text style={[styles.sectionTitle, { color: c.text }]} accessibilityRole="header">
              Highlights
            </Text>
            <View style={{ gap: 10 }}>
              {PRODUCT.highlights.map((h) => (
                <View key={h.label} style={styles.highlightRow} accessible>
                  <View style={[styles.highlightIcon, { backgroundColor: c.surface }]}>
                    <Ionicons name={h.icon} size={20} color={c.text} />
                  </View>
                  <View style={{ flex: 1 }}>
                    <Text style={[styles.infoTitle, { color: c.text }]}>{h.label}</Text>
                    <Text style={[styles.infoSub, { color: c.secondary }]}>{h.detail}</Text>
                  </View>
                </View>
              ))}
            </View>
          </View>

          {/* Description */}
          <View style={styles.section}>
            <Text style={[styles.sectionTitle, { color: c.text }]} accessibilityRole="header">
              About this shoe
            </Text>
            <Text style={[styles.body, { color: c.secondary }]}>{PRODUCT.description}</Text>

            <Pressable
              onPress={() => {
                Haptics.selectionAsync();
                setDetailsOpen((o) => !o);
              }}
              accessibilityRole="button"
              accessibilityState={{ expanded: detailsOpen }}
              style={[styles.disclosure, { borderColor: c.border }]}
            >
              <Text style={[styles.infoTitle, { color: c.text, flex: 1 }]}>Specifications</Text>
              <Ionicons name={detailsOpen ? 'chevron-up' : 'chevron-down'} size={18} color={c.secondary} />
            </Pressable>
            {detailsOpen && (
              <View style={{ paddingTop: 4 }}>
                {PRODUCT.details.map(([k, v]) => (
                  <View
                    key={k}
                    style={[styles.specRow, { borderColor: c.border }, large && { flexDirection: 'column', gap: 2 }]}
                    accessible
                  >
                    <Text style={[styles.infoSub, { color: c.secondary, flex: large ? undefined : 1 }]}>{k}</Text>
                    <Text style={[styles.infoSub, { color: c.text, flex: large ? undefined : 1.4, textAlign: large ? 'left' : 'right' }]}>
                      {v}
                    </Text>
                  </View>
                ))}
              </View>
            )}
          </View>

          {/* Reviews */}
          <View style={styles.section}>
            <View style={[styles.sectionHeader, large && { flexDirection: 'column', alignItems: 'flex-start', gap: 4 }]}>
              <Text style={[styles.sectionTitle, { color: c.text, marginBottom: 0 }]} accessibilityRole="header">
                Reviews
              </Text>
              <Pressable accessibilityRole="link" hitSlop={8} style={{ minHeight: 44, justifyContent: 'center' }}>
                <Text style={[styles.link, { color: c.text }]}>See all {PRODUCT.reviewCount.toLocaleString()}</Text>
              </Pressable>
            </View>
            <View style={{ gap: 12 }}>
              {REVIEWS.map((r) => (
                <View key={r.id} style={[styles.reviewCard, { backgroundColor: c.surface }]} accessible>
                  <View style={[styles.reviewHead, large && { flexDirection: 'column', alignItems: 'flex-start', gap: 4 }]}>
                    <Stars rating={r.rating} size={14} color={c.star} />
                    <Text style={[styles.caption, { color: c.secondary }]}>
                      {r.author} · {r.date}
                    </Text>
                  </View>
                  <Text style={[styles.infoTitle, { color: c.text, marginTop: 6 }]}>{r.title}</Text>
                  <Text style={[styles.body, { color: c.secondary, marginTop: 4 }]}>{r.body}</Text>
                  <View style={[styles.fitPill, { borderColor: c.border }]}>
                    <Text style={[styles.caption, { color: c.text }]}>Fit: {r.fit}</Text>
                  </View>
                </View>
              ))}
            </View>
          </View>
        </View>
      </ScrollView>

      {/* Sticky action bar */}
      <View
        style={[
          styles.bottomBar,
          {
            paddingBottom: Math.max(insets.bottom, 12),
            backgroundColor: dark ? 'rgba(18,18,18,0.97)' : 'rgba(255,255,255,0.97)',
            borderTopColor: c.border,
          },
        ]}
      >
        <View style={[{ flexDirection: 'row', gap: 12, alignItems: 'center' }, large && { flexDirection: 'column', alignItems: 'stretch' }]}>
          {!large && (
            <View style={{ flexShrink: 1 }}>
              <Text style={[styles.caption, { color: c.secondary }]} numberOfLines={1}>
                {size ? `Size ${size} · ${colorway.name}` : 'No size selected'}
              </Text>
              <Text style={[styles.barPrice, { color: c.text }]}>${PRODUCT.price}</Text>
            </View>
          )}
          <Pressable
            onPress={onAddToBag}
            accessibilityRole="button"
            accessibilityLabel={added ? `Added to bag, size ${size}` : `Add to bag, $${PRODUCT.price}`}
            accessibilityHint={size ? undefined : 'Select a size first'}
            style={({ pressed }) => [
              styles.cta,
              { backgroundColor: added ? c.success : c.tint, opacity: pressed ? 0.85 : 1, flex: large ? undefined : 1 },
            ]}
          >
            <Ionicons name={added ? 'checkmark-circle' : 'bag-add-outline'} size={20} color={added ? '#FFFFFF' : c.onTint} />
            <Text style={[styles.ctaText, { color: added ? '#FFFFFF' : c.onTint }]}>
              {added ? 'Added to Bag' : large ? `Add to Bag · $${PRODUCT.price}` : 'Add to Bag'}
            </Text>
          </Pressable>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  headerBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(255,255,255,0.75)',
  },
  badgeRow: { flexDirection: 'row', gap: 8, marginTop: 8, flexWrap: 'wrap', justifyContent: 'center' },
  badge: { paddingHorizontal: 10, paddingVertical: 4, borderRadius: 999 },
  badgeText: { color: '#FFFFFF', fontSize: 12, fontWeight: '700', letterSpacing: 0.3 },
  brand: { fontSize: 13, fontWeight: '600', textTransform: 'uppercase', letterSpacing: 0.8 },
  title: { fontSize: 28, fontWeight: '800', letterSpacing: -0.5, marginTop: 2 },
  category: { fontSize: 15, marginTop: 2 },
  priceRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    flexWrap: 'wrap',
    gap: 8,
    marginTop: 12,
  },
  price: { fontSize: 24, fontWeight: '700' },
  compareAt: { fontSize: 17, textDecorationLine: 'line-through' },
  ratingRow: { flexDirection: 'row', alignItems: 'center', gap: 6, minHeight: 44 },
  ratingText: { fontSize: 14, fontWeight: '500' },
  section: { marginTop: 28 },
  sectionHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 },
  sectionTitle: { fontSize: 17, fontWeight: '700', marginBottom: 12 },
  link: { fontSize: 15, fontWeight: '600', textDecorationLine: 'underline' },
  swatch: { width: 72, height: 72, borderRadius: 16, padding: 4 },
  swatchInner: { flex: 1, borderRadius: 12, alignItems: 'center', justifyContent: 'center', flexDirection: 'row', gap: 4 },
  swatchDot: { width: 22, height: 22, borderRadius: 11 },
  swatchDotSmall: { width: 12, height: 12, borderRadius: 6, borderWidth: StyleSheet.hairlineWidth, borderColor: '#00000033' },
  sizeGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  sizeCell: {
    minHeight: 48,
    paddingVertical: 10,
    borderRadius: 12,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  sizeText: { fontSize: 16, fontWeight: '600' },
  lowDot: { position: 'absolute', top: 6, right: 6, width: 6, height: 6, borderRadius: 3 },
  inlineMsg: { flexDirection: 'row', alignItems: 'center', gap: 6, marginTop: 10 },
  inlineMsgText: { fontSize: 14, flexShrink: 1 },
  infoCard: { marginTop: 24, borderRadius: 16, padding: 16 },
  infoRow: { flexDirection: 'row', alignItems: 'flex-start', gap: 12 },
  infoTitle: { fontSize: 16, fontWeight: '600' },
  infoSub: { fontSize: 14, marginTop: 2, lineHeight: 20 },
  divider: { height: StyleSheet.hairlineWidth, marginVertical: 14 },
  highlightRow: { flexDirection: 'row', alignItems: 'center', gap: 12 },
  highlightIcon: { width: 40, height: 40, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  body: { fontSize: 16, lineHeight: 24 },
  disclosure: {
    flexDirection: 'row',
    alignItems: 'center',
    minHeight: 52,
    marginTop: 16,
    borderTopWidth: StyleSheet.hairlineWidth,
    borderBottomWidth: StyleSheet.hairlineWidth,
  },
  specRow: { flexDirection: 'row', paddingVertical: 10, borderBottomWidth: StyleSheet.hairlineWidth, gap: 12 },
  reviewCard: { borderRadius: 16, padding: 16 },
  reviewHead: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: 8 },
  caption: { fontSize: 13 },
  fitPill: { alignSelf: 'flex-start', marginTop: 10, borderWidth: 1, borderRadius: 999, paddingHorizontal: 10, paddingVertical: 4 },
  bottomBar: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    paddingHorizontal: 16,
    paddingTop: 12,
    borderTopWidth: StyleSheet.hairlineWidth,
  },
  barPrice: { fontSize: 20, fontWeight: '700' },
  cta: {
    minHeight: 54,
    borderRadius: 999,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    paddingHorizontal: 20,
    paddingVertical: 12,
  },
  ctaText: { fontSize: 17, fontWeight: '700', textAlign: 'center', flexShrink: 1 },
});
