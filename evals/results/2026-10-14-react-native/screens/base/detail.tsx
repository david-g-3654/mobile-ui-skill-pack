import React, { useMemo, useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  Pressable,
  StyleSheet,
  useWindowDimensions,
  NativeSyntheticEvent,
  NativeScrollEvent,
} from 'react-native';
import { Stack } from 'expo-router';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';
import * as Haptics from 'expo-haptics';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import Svg, { Path, Ellipse, Circle } from 'react-native-svg';
import { StatusBar } from 'expo-status-bar';

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
  price: 149.0,
  compareAt: 175.0,
  rating: 4.6,
  reviewCount: 1284,
  sku: 'AR2-0417',
  description:
    'Built for daily miles, the Aero Runner 2 pairs a responsive nitrogen-infused foam midsole with an engineered mesh upper that breathes on hot runs. A redesigned heel counter locks you in without pressure points.',
  highlights: [
    { icon: 'flash-outline' as const, label: 'Responsive foam' },
    { icon: 'leaf-outline' as const, label: '30% recycled' },
    { icon: 'barbell-outline' as const, label: '262 g (9.2 oz)' },
    { icon: 'trending-down-outline' as const, label: '8 mm drop' },
  ],
  specs: [
    ['Upper', 'Engineered jacquard mesh'],
    ['Midsole', 'N-Flow nitrogen foam'],
    ['Outsole', 'Carbon rubber, multi-directional lugs'],
    ['Stack height', '36 mm heel / 28 mm forefoot'],
    ['Best for', 'Daily training, tempo runs'],
  ] as [string, string][],
};

const COLORWAYS: Colorway[] = [
  { id: 'volt', name: 'Volt / Black', upper: '#D7F23A', accent: '#111111', sole: '#F4F4F0', bg: ['#F3F8D6', '#E3EDB0'] },
  { id: 'ocean', name: 'Ocean / White', upper: '#2F6FED', accent: '#FFFFFF', sole: '#F4F4F0', bg: ['#E3ECFD', '#C9DAFB'] },
  { id: 'ember', name: 'Ember / Sail', upper: '#F2542D', accent: '#FFF4E6', sole: '#EDE4D6', bg: ['#FDE7E0', '#F9CDBF'] },
  { id: 'onyx', name: 'Triple Onyx', upper: '#2A2A2E', accent: '#8B8B93', sole: '#3A3A40', bg: ['#E9E9EC', '#D3D3D8'] },
];

const SIZES: { us: string; stock: number }[] = [
  { us: '7', stock: 4 },
  { us: '7.5', stock: 0 },
  { us: '8', stock: 9 },
  { us: '8.5', stock: 12 },
  { us: '9', stock: 2 },
  { us: '9.5', stock: 15 },
  { us: '10', stock: 7 },
  { us: '10.5', stock: 0 },
  { us: '11', stock: 5 },
  { us: '12', stock: 3 },
  { us: '13', stock: 1 },
];

const RATING_BREAKDOWN = [
  { stars: 5, pct: 0.71 },
  { stars: 4, pct: 0.18 },
  { stars: 3, pct: 0.06 },
  { stars: 2, pct: 0.03 },
  { stars: 1, pct: 0.02 },
];

const REVIEWS: Review[] = [
  {
    id: 'r1',
    author: 'Marcus T.',
    rating: 5,
    date: 'Sep 28, 2026',
    title: 'Best daily trainer I have owned',
    body: 'About 180 miles in and the foam still feels lively. Upper is soft and I had zero hot spots on a 20 miler.',
    fit: 'True to size',
  },
  {
    id: 'r2',
    author: 'Priya S.',
    rating: 4,
    date: 'Sep 15, 2026',
    title: 'Great cushion, slightly narrow',
    body: 'Love the bounce for tempo days. Toe box runs a bit narrow for me, so I went up half a size.',
    fit: 'Runs small',
  },
];

const ANGLES = ['side', 'front', 'top'] as const;

function SneakerArt({ c, angle, width }: { c: Colorway; angle: (typeof ANGLES)[number]; width: number }) {
  const h = width * 0.62;
  if (angle === 'front') {
    return (
      <Svg width={width} height={h} viewBox="0 0 320 200">
        <Ellipse cx={160} cy={186} rx={80} ry={8} fill="rgba(0,0,0,0.12)" />
        <Path d="M100 175 Q100 60 160 40 Q220 60 220 175 Z" fill={c.upper} />
        <Path d="M96 168 L224 168 L222 182 Q160 190 98 182 Z" fill={c.sole} />
        <Path d="M130 70 L190 70 M128 88 L192 88 M126 106 L194 106" stroke={c.accent} strokeWidth={5} strokeLinecap="round" />
        <Circle cx={160} cy={130} r={14} fill={c.accent} opacity={0.9} />
      </Svg>
    );
  }
  if (angle === 'top') {
    return (
      <Svg width={width} height={h} viewBox="0 0 320 200">
        <Path d="M70 100 Q70 50 150 45 Q260 40 275 100 Q260 160 150 155 Q70 150 70 100 Z" fill={c.sole} />
        <Path d="M82 100 Q82 60 150 57 Q250 54 262 100 Q250 146 150 143 Q82 140 82 100 Z" fill={c.upper} />
        <Ellipse cx={120} cy={100} rx={30} ry={24} fill={c.accent} opacity={0.85} />
        <Path d="M160 80 L160 120 M180 78 L180 122 M200 80 L200 120" stroke={c.accent} strokeWidth={4} strokeLinecap="round" />
      </Svg>
    );
  }
  return (
    <Svg width={width} height={h} viewBox="0 0 320 200">
      <Ellipse cx={165} cy={180} rx={130} ry={9} fill="rgba(0,0,0,0.12)" />
      <Path d="M30 150 Q30 170 50 172 L285 172 Q305 170 300 150 L295 140 L35 140 Z" fill={c.sole} />
      <Path
        d="M38 142 Q30 100 60 82 Q80 72 92 50 Q100 38 120 44 Q140 52 150 76 Q170 100 220 108 Q280 116 296 140 Z"
        fill={c.upper}
      />
      <Path d="M70 132 Q140 90 270 128" stroke={c.accent} strokeWidth={10} fill="none" strokeLinecap="round" />
      <Path d="M118 62 L134 72 M124 54 L142 66 M112 72 L128 82" stroke={c.accent} strokeWidth={4} strokeLinecap="round" />
      <Path d="M38 142 Q36 120 46 104 L62 108 Q54 124 56 142 Z" fill={c.accent} opacity={0.35} />
    </Svg>
  );
}

function Stars({ rating, size = 14 }: { rating: number; size?: number }) {
  return (
    <View style={{ flexDirection: 'row' }} accessibilityLabel={`${rating} out of 5 stars`}>
      {[1, 2, 3, 4, 5].map((i) => {
        const name = rating >= i ? 'star' : rating >= i - 0.5 ? 'star-half' : 'star-outline';
        return <Ionicons key={i} name={name} size={size} color="#F5A524" />;
      })}
    </View>
  );
}

export default function SneakerDetailScreen() {
  const { width } = useWindowDimensions();
  const insets = useSafeAreaInsets();
  const [colorIdx, setColorIdx] = useState(0);
  const [size, setSize] = useState<string | null>(null);
  const [qty, setQty] = useState(1);
  const [fav, setFav] = useState(false);
  const [page, setPage] = useState(0);
  const [specsOpen, setSpecsOpen] = useState(false);
  const [sizeError, setSizeError] = useState(false);
  const [added, setAdded] = useState(false);

  const color = COLORWAYS[colorIdx];
  const selectedStock = useMemo(() => SIZES.find((s) => s.us === size)?.stock ?? 0, [size]);
  const discount = Math.round((1 - PRODUCT.price / PRODUCT.compareAt) * 100);

  const onScroll = (e: NativeSyntheticEvent<NativeScrollEvent>) => {
    const p = Math.round(e.nativeEvent.contentOffset.x / width);
    if (p !== page) setPage(p);
  };

  const pickSize = (s: string, stock: number) => {
    if (stock === 0) return;
    Haptics.selectionAsync();
    setSize(s);
    setSizeError(false);
    setQty(1);
  };

  const addToBag = () => {
    if (!size) {
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning);
      setSizeError(true);
      return;
    }
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    setAdded(true);
    setTimeout(() => setAdded(false), 2000);
  };

  return (
    <View style={styles.root}>
      <StatusBar style="dark" />
      <Stack.Screen options={{ headerShown: false }} />

      <SafeAreaView edges={['top']} style={styles.topBar}>
        <Pressable style={styles.iconBtn} accessibilityRole="button" accessibilityLabel="Go back" hitSlop={8}>
          <Ionicons name="chevron-back" size={22} color="#111" />
        </Pressable>
        <View style={{ flexDirection: 'row', gap: 10 }}>
          <Pressable style={styles.iconBtn} accessibilityRole="button" accessibilityLabel="Share" hitSlop={8}>
            <Ionicons name="share-outline" size={20} color="#111" />
          </Pressable>
          <Pressable
            style={styles.iconBtn}
            accessibilityRole="button"
            accessibilityLabel={fav ? 'Remove from favorites' : 'Add to favorites'}
            hitSlop={8}
            onPress={() => {
              Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
              setFav((f) => !f);
            }}
          >
            <Ionicons name={fav ? 'heart' : 'heart-outline'} size={20} color={fav ? '#E5383B' : '#111'} />
          </Pressable>
        </View>
      </SafeAreaView>

      <ScrollView contentContainerStyle={{ paddingBottom: 120 + insets.bottom }} showsVerticalScrollIndicator={false}>
        <LinearGradient colors={color.bg} style={[styles.hero, { paddingTop: insets.top + 56 }]}>
          <ScrollView horizontal pagingEnabled showsHorizontalScrollIndicator={false} onScroll={onScroll} scrollEventThrottle={16}>
            {ANGLES.map((a) => (
              <View key={a} style={{ width, alignItems: 'center', justifyContent: 'center' }}>
                <SneakerArt c={color} angle={a} width={width * 0.86} />
              </View>
            ))}
          </ScrollView>
          <View style={styles.dots}>
            {ANGLES.map((a, i) => (
              <View key={a} style={[styles.dot, i === page && styles.dotActive]} />
            ))}
          </View>
          <View style={styles.badge}>
            <Text style={styles.badgeText}>-{discount}%</Text>
          </View>
        </LinearGradient>

        <View style={styles.body}>
          <Text style={styles.brand}>{PRODUCT.brand.toUpperCase()}</Text>
          <Text style={styles.title}>{PRODUCT.name}</Text>
          <Text style={styles.category}>{PRODUCT.category}</Text>

          <View style={styles.row}>
            <Stars rating={PRODUCT.rating} />
            <Text style={styles.ratingText}>
              {PRODUCT.rating} · {PRODUCT.reviewCount.toLocaleString()} reviews
            </Text>
          </View>

          <View style={[styles.row, { marginTop: 12, alignItems: 'baseline' }]}>
            <Text style={styles.price}>${PRODUCT.price.toFixed(2)}</Text>
            <Text style={styles.compare}>${PRODUCT.compareAt.toFixed(2)}</Text>
          </View>
          <Text style={styles.muted}>or 4 interest-free payments of ${(PRODUCT.price / 4).toFixed(2)}</Text>

          <View style={styles.section}>
            <View style={styles.sectionHead}>
              <Text style={styles.sectionTitle}>Color</Text>
              <Text style={styles.muted}>{color.name}</Text>
            </View>
            <View style={styles.swatches}>
              {COLORWAYS.map((cw, i) => (
                <Pressable
                  key={cw.id}
                  onPress={() => {
                    Haptics.selectionAsync();
                    setColorIdx(i);
                  }}
                  accessibilityRole="radio"
                  accessibilityState={{ selected: i === colorIdx }}
                  accessibilityLabel={cw.name}
                  style={[styles.swatchRing, i === colorIdx && styles.swatchRingActive]}
                >
                  <View style={[styles.swatch, { backgroundColor: cw.upper }]}>
                    <View style={[styles.swatchHalf, { backgroundColor: cw.accent }]} />
                  </View>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.section}>
            <View style={styles.sectionHead}>
              <Text style={[styles.sectionTitle, sizeError && { color: '#D62828' }]}>
                {sizeError ? 'Please select a size' : 'Size (US Men)'}
              </Text>
              <Pressable hitSlop={8} accessibilityRole="link">
                <Text style={styles.link}>Size guide</Text>
              </Pressable>
            </View>
            <View style={styles.sizeGrid}>
              {SIZES.map((s) => {
                const out = s.stock === 0;
                const active = s.us === size;
                return (
                  <Pressable
                    key={s.us}
                    onPress={() => pickSize(s.us, s.stock)}
                    disabled={out}
                    accessibilityRole="radio"
                    accessibilityState={{ selected: active, disabled: out }}
                    accessibilityLabel={`Size ${s.us}${out ? ', sold out' : ''}`}
                    style={[
                      styles.sizeChip,
                      active && styles.sizeChipActive,
                      out && styles.sizeChipOut,
                      sizeError && !out && styles.sizeChipError,
                    ]}
                  >
                    <Text style={[styles.sizeText, active && { color: '#fff' }, out && styles.sizeTextOut]}>{s.us}</Text>
                  </Pressable>
                );
              })}
            </View>
            {size && selectedStock <= 3 ? (
              <View style={[styles.row, { marginTop: 10 }]}>
                <Ionicons name="alert-circle" size={16} color="#E07A00" />
                <Text style={styles.lowStock}> Only {selectedStock} left in size {size}</Text>
              </View>
            ) : null}
          </View>

          <View style={[styles.section, styles.sectionHead]}>
            <Text style={styles.sectionTitle}>Quantity</Text>
            <View style={styles.stepper}>
              <Pressable
                style={styles.stepBtn}
                disabled={qty <= 1}
                accessibilityLabel="Decrease quantity"
                onPress={() => {
                  Haptics.selectionAsync();
                  setQty((q) => Math.max(1, q - 1));
                }}
              >
                <Ionicons name="remove" size={18} color={qty <= 1 ? '#BBB' : '#111'} />
              </Pressable>
              <Text style={styles.qty}>{qty}</Text>
              <Pressable
                style={styles.stepBtn}
                accessibilityLabel="Increase quantity"
                disabled={size !== null && qty >= Math.min(selectedStock, 5)}
                onPress={() => {
                  Haptics.selectionAsync();
                  setQty((q) => Math.min(size ? Math.min(selectedStock, 5) : 5, q + 1));
                }}
              >
                <Ionicons name="add" size={18} color="#111" />
              </Pressable>
            </View>
          </View>

          <View style={styles.perks}>
            <View style={styles.perk}>
              <Ionicons name="cube-outline" size={20} color="#111" />
              <View style={{ flex: 1 }}>
                <Text style={styles.perkTitle}>Free delivery by Fri, Oct 17</Text>
                <Text style={styles.muted}>On orders over $75</Text>
              </View>
            </View>
            <View style={styles.divider} />
            <View style={styles.perk}>
              <Ionicons name="refresh-outline" size={20} color="#111" />
              <View style={{ flex: 1 }}>
                <Text style={styles.perkTitle}>30-day test run</Text>
                <Text style={styles.muted}>Run in them. Return them free if they are not right.</Text>
              </View>
            </View>
          </View>

          <View style={styles.section}>
            <Text style={styles.sectionTitle}>About this shoe</Text>
            <Text style={styles.desc}>{PRODUCT.description}</Text>
            <View style={styles.highlights}>
              {PRODUCT.highlights.map((h) => (
                <View key={h.label} style={styles.highlight}>
                  <Ionicons name={h.icon} size={18} color="#111" />
                  <Text style={styles.highlightText}>{h.label}</Text>
                </View>
              ))}
            </View>
          </View>

          <Pressable
            style={styles.accordion}
            onPress={() => setSpecsOpen((o) => !o)}
            accessibilityRole="button"
            accessibilityState={{ expanded: specsOpen }}
          >
            <Text style={styles.sectionTitle}>Specifications</Text>
            <Ionicons name={specsOpen ? 'chevron-up' : 'chevron-down'} size={20} color="#111" />
          </Pressable>
          {specsOpen ? (
            <View style={{ paddingBottom: 8 }}>
              {PRODUCT.specs.map(([k, v]) => (
                <View key={k} style={styles.specRow}>
                  <Text style={styles.specKey}>{k}</Text>
                  <Text style={styles.specVal}>{v}</Text>
                </View>
              ))}
              <View style={styles.specRow}>
                <Text style={styles.specKey}>Style</Text>
                <Text style={styles.specVal}>{PRODUCT.sku}</Text>
              </View>
            </View>
          ) : null}

          <View style={styles.section}>
            <View style={styles.sectionHead}>
              <Text style={styles.sectionTitle}>Reviews</Text>
              <Pressable hitSlop={8}>
                <Text style={styles.link}>See all {PRODUCT.reviewCount.toLocaleString()}</Text>
              </Pressable>
            </View>
            <View style={styles.ratingCard}>
              <View style={{ alignItems: 'center', marginRight: 20 }}>
                <Text style={styles.bigRating}>{PRODUCT.rating}</Text>
                <Stars rating={PRODUCT.rating} size={12} />
                <Text style={[styles.muted, { marginTop: 4 }]}>94% recommend</Text>
              </View>
              <View style={{ flex: 1, gap: 4 }}>
                {RATING_BREAKDOWN.map((r) => (
                  <View key={r.stars} style={styles.row}>
                    <Text style={styles.barLabel}>{r.stars}</Text>
                    <View style={styles.barTrack}>
                      <View style={[styles.barFill, { width: `${r.pct * 100}%` }]} />
                    </View>
                  </View>
                ))}
              </View>
            </View>
            {REVIEWS.map((r) => (
              <View key={r.id} style={styles.review}>
                <View style={styles.sectionHead}>
                  <Stars rating={r.rating} size={12} />
                  <Text style={styles.muted}>{r.date}</Text>
                </View>
                <Text style={styles.reviewTitle}>{r.title}</Text>
                <Text style={styles.desc}>{r.body}</Text>
                <Text style={[styles.muted, { marginTop: 6 }]}>
                  {r.author} · Fit: {r.fit}
                </Text>
              </View>
            ))}
          </View>
        </View>
      </ScrollView>

      <View style={[styles.cta, { paddingBottom: Math.max(insets.bottom, 12) }]}>
        <View>
          <Text style={styles.muted}>Total</Text>
          <Text style={styles.ctaPrice}>${(PRODUCT.price * qty).toFixed(2)}</Text>
        </View>
        <Pressable
          onPress={addToBag}
          accessibilityRole="button"
          style={({ pressed }) => [styles.addBtn, added && { backgroundColor: '#1F9D55' }, pressed && { opacity: 0.85 }]}
        >
          <Ionicons name={added ? 'checkmark' : 'bag-add-outline'} size={20} color="#fff" />
          <Text style={styles.addText}>{added ? 'Added to bag' : size ? `Add size ${size} to bag` : 'Add to bag'}</Text>
        </Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: '#fff' },
  topBar: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    zIndex: 10,
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 8,
  },
  iconBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(255,255,255,0.9)',
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 4,
  },
  hero: { paddingBottom: 20 },
  dots: { flexDirection: 'row', justifyContent: 'center', gap: 6, marginTop: 8 },
  dot: { width: 6, height: 6, borderRadius: 3, backgroundColor: 'rgba(0,0,0,0.2)' },
  dotActive: { width: 18, backgroundColor: '#111' },
  badge: {
    position: 'absolute',
    bottom: 20,
    left: 20,
    backgroundColor: '#111',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 999,
  },
  badgeText: { color: '#fff', fontWeight: '700', fontSize: 12 },
  body: { paddingHorizontal: 20, paddingTop: 20 },
  brand: { fontSize: 12, letterSpacing: 1.5, color: '#6B6B6B', fontWeight: '600' },
  title: { fontSize: 28, fontWeight: '800', color: '#111', marginTop: 4 },
  category: { fontSize: 15, color: '#6B6B6B', marginTop: 2 },
  row: { flexDirection: 'row', alignItems: 'center' },
  ratingText: { marginLeft: 8, color: '#444', fontSize: 13 },
  price: { fontSize: 24, fontWeight: '800', color: '#111' },
  compare: { marginLeft: 10, fontSize: 16, color: '#999', textDecorationLine: 'line-through' },
  muted: { color: '#6B6B6B', fontSize: 13 },
  section: { marginTop: 28 },
  sectionHead: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  sectionTitle: { fontSize: 17, fontWeight: '700', color: '#111' },
  link: { fontSize: 14, color: '#111', textDecorationLine: 'underline', fontWeight: '500' },
  swatches: { flexDirection: 'row', gap: 12, marginTop: 12 },
  swatchRing: { padding: 3, borderRadius: 28, borderWidth: 2, borderColor: 'transparent' },
  swatchRingActive: { borderColor: '#111' },
  swatch: { width: 44, height: 44, borderRadius: 22, overflow: 'hidden', borderWidth: 1, borderColor: 'rgba(0,0,0,0.08)' },
  swatchHalf: { position: 'absolute', bottom: 0, left: 0, right: 0, height: 14 },
  sizeGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 12 },
  sizeChip: {
    width: '22.5%',
    height: 48,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: '#DDD',
    alignItems: 'center',
    justifyContent: 'center',
  },
  sizeChipActive: { backgroundColor: '#111', borderColor: '#111' },
  sizeChipOut: { backgroundColor: '#F5F5F5', borderColor: '#EEE' },
  sizeChipError: { borderColor: '#F2A0A0' },
  sizeText: { fontSize: 15, fontWeight: '600', color: '#111' },
  sizeTextOut: { color: '#BBB', textDecorationLine: 'line-through' },
  lowStock: { color: '#E07A00', fontSize: 13, fontWeight: '600' },
  stepper: { flexDirection: 'row', alignItems: 'center', borderWidth: 1, borderColor: '#DDD', borderRadius: 999 },
  stepBtn: { width: 44, height: 40, alignItems: 'center', justifyContent: 'center' },
  qty: { minWidth: 24, textAlign: 'center', fontSize: 16, fontWeight: '700' },
  perks: { marginTop: 28, backgroundColor: '#F6F6F4', borderRadius: 16, padding: 16 },
  perk: { flexDirection: 'row', gap: 12, alignItems: 'flex-start' },
  perkTitle: { fontSize: 14, fontWeight: '600', color: '#111', marginBottom: 2 },
  divider: { height: StyleSheet.hairlineWidth, backgroundColor: '#D6D6D6', marginVertical: 12 },
  desc: { fontSize: 15, lineHeight: 22, color: '#333', marginTop: 8 },
  highlights: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 14 },
  highlight: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 999,
    backgroundColor: '#F2F2F0',
  },
  highlightText: { fontSize: 13, fontWeight: '500', color: '#111' },
  accordion: {
    marginTop: 24,
    paddingVertical: 16,
    borderTopWidth: StyleSheet.hairlineWidth,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderColor: '#DDD',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  specRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 10,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderColor: '#EEE',
    gap: 16,
  },
  specKey: { color: '#6B6B6B', fontSize: 14 },
  specVal: { color: '#111', fontSize: 14, fontWeight: '500', flexShrink: 1, textAlign: 'right' },
  ratingCard: { flexDirection: 'row', alignItems: 'center', marginTop: 14, padding: 16, borderRadius: 16, backgroundColor: '#F6F6F4' },
  bigRating: { fontSize: 36, fontWeight: '800', color: '#111' },
  barLabel: { width: 14, fontSize: 12, color: '#444' },
  barTrack: { flex: 1, height: 6, borderRadius: 3, backgroundColor: '#E2E2E2', overflow: 'hidden' },
  barFill: { height: 6, borderRadius: 3, backgroundColor: '#111' },
  review: { paddingVertical: 16, borderBottomWidth: StyleSheet.hairlineWidth, borderColor: '#EEE' },
  reviewTitle: { fontSize: 15, fontWeight: '700', color: '#111', marginTop: 8 },
  cta: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    paddingTop: 12,
    backgroundColor: '#fff',
    borderTopWidth: StyleSheet.hairlineWidth,
    borderColor: '#DDD',
    gap: 16,
  },
  ctaPrice: { fontSize: 20, fontWeight: '800', color: '#111' },
  addBtn: {
    flex: 1,
    height: 54,
    borderRadius: 999,
    backgroundColor: '#111',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
  },
  addText: { color: '#fff', fontSize: 16, fontWeight: '700' },
});
