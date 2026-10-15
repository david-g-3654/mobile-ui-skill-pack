// Sneaker product detail — Detail archetype.
// Job: pick a colour + size and add to bag. Focal: the full-bleed product media, then name + price.
// Primary: "Add to bag · $138.00" pinned in the bottom action bar. Save/share live in the nav bar as glyphs.
// Cut: "Buy now" button, inline review list, spec table (moved behind disclosure rows).

import React, { useEffect, useState } from 'react';
import { NativeScrollEvent, NativeSyntheticEvent, Pressable, ScrollView, Share, StyleSheet, View, useWindowDimensions } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import * as Haptics from 'expo-haptics';
import { Ionicons } from '@expo/vector-icons';
import Svg, { Circle, Ellipse, G, Path } from 'react-native-svg';
import { metrics, radius, space, tabular, useQTheme } from '../../pack04/theme';
import {
  QBottomActionBar,
  QChip,
  QGroupedSection,
  QIconButton,
  QListRow,
  QPrimaryButton,
  QScreen,
  QSectionHeader,
  QSwatch,
  QTertiaryButton,
  QText,
  QToast,
  useQLargeText,
} from '../../pack04/components';

// ── Sample data ──────────────────────────────────────────────────────

type Colorway = { id: string; name: string; upper: string; panel: string; sole: string; stripe: string };

// Product colours are content, not UI chrome.
const COLORWAYS: Colorway[] = [
  { id: 'bone', name: 'Bone / Gum', upper: '#E9E4D8', panel: '#CFC6B4', sole: '#B5773F', stripe: '#2B2B2B' }, // mobile-ui: content-color
  { id: 'black', name: 'Black / Ember', upper: '#232323', panel: '#353535', sole: '#F2EFE8', stripe: '#E4572E' }, // mobile-ui: content-color
  { id: 'sage', name: 'Sage / Cream', upper: '#A9B8A0', panel: '#8E9F86', sole: '#F3EEE2', stripe: '#F3EEE2' }, // mobile-ui: content-color
];

const SIZES = ['7', '7.5', '8', '8.5', '9', '9.5', '10', '10.5', '11', '12'];
const SOLD_OUT: Record<string, string[]> = { bone: ['8', '12'], black: ['7'], sage: ['11', '12'] };
const LOW_STOCK: Record<string, Record<string, number>> = { bone: { '10.5': 2 }, black: { '9': 3 }, sage: { '9.5': 1 } };

const PRODUCT = {
  brand: 'Halden Running Co.',
  name: 'Arc Trainer 2 Suede',
  price: '$138.00',
  rating: '4.7',
  reviews: '1,284 reviews',
  description:
    'A daily trainer rebuilt around a softer, recycled foam midsole and a brushed suede upper that breaks in within a week. The rocker toe keeps easy miles rolling, and the gum rubber outsole grips wet pavement without the weight of a trail lug.',
};

const DISCLOSURES = [
  {
    title: 'Details',
    body: 'Suede and recycled mesh upper · EVA-blend foam midsole, 32 mm heel / 24 mm forefoot · Natural gum rubber outsole · 289 g (men’s US 9).',
  },
  {
    title: 'Size & fit',
    body: 'Runs true to size with a roomy toe box. Between sizes or wearing thick socks? Go up half a size.',
  },
  {
    title: 'Delivery & returns',
    body: 'Free standard delivery on orders over $75. Unworn pairs can be returned free within 30 days — we’ll email a prepaid label.',
  },
];

const RELATED: { id: string; name: string; price: string; colorway: Colorway }[] = [
  { id: 'mesh', name: 'Arc Trainer 2 Mesh', price: '$118.00', colorway: COLORWAYS[2] },
  { id: 'field', name: 'Field Runner', price: '$124.00', colorway: COLORWAYS[1] },
  { id: 'court', name: 'Low Court Leather', price: '$96.00', colorway: COLORWAYS[0] },
  { id: 'trail', name: 'Trail Arc GTX', price: '$162.00', colorway: COLORWAYS[1] },
];

const VIEWS = ['side view', 'inside view', 'toe close-up'];

// ── Product illustration (stands in for photography) ───────────────────

function Sneaker({ colorway, variant = 'side', size }: { colorway: Colorway; variant?: 'side' | 'inside' | 'toe'; size: number }) {
  const { c } = useQTheme();
  const flip = variant === 'inside';
  const zoom = variant === 'toe';
  const viewBox = zoom ? '150 20 170 150' : '0 0 320 180';
  return (
    <Svg width={size} height={zoom ? size * (150 / 170) : size * (180 / 320)} viewBox={viewBox}>
      <Ellipse cx={163} cy={166} rx={134} ry={6} fill={c.ink} fillOpacity={0.08} />
      <G transform={flip ? 'translate(326 0) scale(-1 1)' : undefined}>
        <Path
          d="M34 114 C30 92 40 74 62 70 L118 62 C132 40 150 28 172 28 L196 30 C206 31 210 38 208 48 L204 66 C232 72 262 84 286 98 C298 106 302 112 300 114 Z"
          fill={colorway.upper}
        />
        <Path d="M210 70 C238 76 266 88 286 100 C294 106 298 112 296 114 L240 114 C232 100 222 84 210 70 Z" fill={colorway.panel} />
        <Path d="M34 114 C30 94 40 76 62 72 L84 70 C78 86 76 100 80 114 Z" fill={colorway.panel} />
        <Path d="M120 62 C134 52 152 46 172 46" stroke={colorway.panel} strokeWidth={6} strokeLinecap="round" fill="none" />
        <Path d="M112 106 L150 68 M128 108 L166 70" stroke={colorway.stripe} strokeWidth={8} strokeLinecap="round" />
        <Circle cx={176} cy={50} r={3} fill={colorway.stripe} />
        <Circle cx={186} cy={58} r={3} fill={colorway.stripe} />
        <Circle cx={196} cy={66} r={3} fill={colorway.stripe} />
        <Path
          d="M20 128 C20 118 28 112 40 112 L282 112 C298 112 306 120 306 132 L306 140 C306 150 298 156 286 156 L44 156 C30 156 20 148 20 138 Z"
          fill={colorway.sole}
        />
        <Path d="M28 144 L300 144" stroke={c.ink} strokeOpacity={0.12} strokeWidth={2} />
      </G>
    </Svg>
  );
}

// ── Screen ───────────────────────────────────────────────────────────

export default function SneakerDetailScreen() {
  const { c } = useQTheme();
  const { width } = useWindowDimensions();
  const large = useQLargeText();

  const [colorId, setColorId] = useState(COLORWAYS[0].id);
  const [size, setSize] = useState<string | null>(null);
  const [sizeOpen, setSizeOpen] = useState(false);
  const [page, setPage] = useState(0);
  const [saved, setSaved] = useState(false);
  const [descOpen, setDescOpen] = useState(false);
  const [openSection, setOpenSection] = useState<string | null>(null);
  const [toast, setToast] = useState<string | null>(null);

  const colorway = COLORWAYS.find((cw) => cw.id === colorId) ?? COLORWAYS[0];
  const available = SIZES.filter((s) => !SOLD_OUT[colorId].includes(s));
  const soldOut = SOLD_OUT[colorId];
  const lowLeft = size ? LOW_STOCK[colorId][size] : undefined;

  useEffect(() => {
    if (!toast) return;
    const id = setTimeout(() => setToast(null), 2400);
    return () => clearTimeout(id);
  }, [toast]);

  const chooseColor = (id: string) => {
    setColorId(id);
    if (size && SOLD_OUT[id].includes(size)) setSize(null);
  };

  const chooseSize = (s: string) => {
    Haptics.selectionAsync();
    setSize(s);
    setSizeOpen(false);
  };

  const toggleSaved = () => {
    Haptics.selectionAsync();
    setSaved((v) => !v);
  };

  const share = () => {
    Share.share({ message: `${PRODUCT.name} in ${colorway.name} — ${PRODUCT.price}` });
  };

  const addToBag = () => {
    if (!size) {
      setSizeOpen(true);
      return;
    }
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    setToast(`Added US ${size} to your bag`);
  };

  const onPage = (e: NativeSyntheticEvent<NativeScrollEvent>) => {
    setPage(Math.round(e.nativeEvent.contentOffset.x / width));
  };

  return (
    <View style={{ flex: 1, backgroundColor: c.canvas }}>
      <StatusBar style="auto" />
      <Stack.Screen
        options={{
          title: '',
          headerTransparent: true,
          headerShadowVisible: false,
          headerTintColor: c.ink,
          contentStyle: { backgroundColor: c.canvas },
          headerRight: () => (
            <View style={styles.navGlyphs}>
              <QIconButton icon={saved ? 'heart' : 'heart-outline'} label={saved ? 'Remove from saved' : 'Save to favourites'} onPress={toggleSaved} />
              <QIconButton icon="share-outline" label="Share sneaker" onPress={share} />
            </View>
          ),
        }}
      />

      <QScreen contentInsetAdjustmentBehavior="never" contentContainerStyle={styles.scrollContent}>
        {/* Media: full-bleed, paged */}
        <View style={{ backgroundColor: c.surface2 }}>
          <ScrollView horizontal pagingEnabled showsHorizontalScrollIndicator={false} onMomentumScrollEnd={onPage}>
            {VIEWS.map((v, i) => (
              <View
                key={v}
                accessible
                accessibilityRole="image"
                accessibilityLabel={`${PRODUCT.name} in ${colorway.name}, ${v}`}
                style={[styles.mediaPage, { width, height: width }]}
              >
                <Sneaker colorway={colorway} size={width - space.xxl * 2} variant={i === 0 ? 'side' : i === 1 ? 'inside' : 'toe'} />
              </View>
            ))}
          </ScrollView>
          <View style={styles.dots} accessibilityElementsHidden importantForAccessibility="no-hide-descendants">
            {VIEWS.map((v, i) => (
              <View key={v} style={[styles.dot, { backgroundColor: c.ink, opacity: i === page ? 1 : 0.24 }, i === page && styles.dotActive]} />
            ))}
          </View>
        </View>

        <View style={styles.body}>
          {/* Title block: what, how much, one proof point */}
          <View style={{ gap: space.xs }}>
            <QText variant="overline" color="ink2">
              {PRODUCT.brand}
            </QText>
            <QText variant="title" role="header">
              {PRODUCT.name}
            </QText>
            <View style={styles.priceLine}>
              <QText variant="title" style={tabular}>
                {PRODUCT.price}
              </QText>
              <View style={styles.proof} accessible accessibilityLabel={`Rated ${PRODUCT.rating} out of 5, ${PRODUCT.reviews}`}>
                <Ionicons name="star" size={14} color={c.accent} />
                <QText variant="subhead" color="ink2" style={tabular}>
                  {PRODUCT.rating} · {PRODUCT.reviews}
                </QText>
              </View>
            </View>
          </View>

          {/* Options */}
          <View style={{ gap: space.sm }}>
            <QGroupedSection>
              <QListRow
                title="Colour"
                subtitle={colorway.name}
                trailing={
                  <View style={styles.swatches} accessibilityRole="radiogroup">
                    {COLORWAYS.map((cw) => (
                      <QSwatch key={cw.id} name={cw.name} color={cw.upper} selected={cw.id === colorId} onPress={() => chooseColor(cw.id)} size={24} />
                    ))}
                  </View>
                }
              />
              <QListRow title="Size" value={size ? `US ${size}` : 'Select'} onPress={() => setSizeOpen((o) => !o)} />
            </QGroupedSection>

            {sizeOpen && (
              <View style={{ gap: space.sm }}>
                <View style={styles.chips}>
                  {available.map((s) => (
                    <QChip key={s} title={`US ${s}`} selected={s === size} onPress={() => chooseSize(s)} />
                  ))}
                </View>
                <QText variant="subhead" color="ink2">
                  Sold out in {soldOut.map((s) => `US ${s}`).join(' and ')}. Runs true to size.
                </QText>
              </View>
            )}

            {lowLeft !== undefined && (
              <View style={styles.statusLine}>
                <Ionicons name="time-outline" size={16} color={c.warning} />
                <QText variant="subhead" color="warning">
                  Only {lowLeft} left in US {size}
                </QText>
              </View>
            )}

            <View style={styles.statusLine}>
              <Ionicons name="cube-outline" size={16} color={c.ink2} />
              <QText variant="subhead" color="ink2" style={{ flexShrink: 1 }}>
                Free delivery by Mon, Oct 19 · Free 30-day returns
              </QText>
            </View>
          </View>

          {/* Description + disclosure */}
          <View style={{ gap: space.sm }}>
            <QText color="ink2" numberOfLines={descOpen ? undefined : 3}>
              {PRODUCT.description}
            </QText>
            {!descOpen && (
              <View style={styles.alignStart}>
                <QTertiaryButton title="Read more" color="ink" onPress={() => setDescOpen(true)} />
              </View>
            )}
            <View>
              {DISCLOSURES.map((d) => {
                const open = openSection === d.title;
                return (
                  <View key={d.title} style={[styles.disclosure, { borderTopColor: c.hairline }]}>
                    <Pressable
                      onPress={() => setOpenSection(open ? null : d.title)}
                      accessibilityRole="button"
                      accessibilityLabel={d.title}
                      accessibilityState={{ expanded: open }}
                      style={({ pressed }) => [styles.disclosureHead, pressed && { opacity: 0.6 }]}
                    >
                      <QText style={{ flex: 1 }}>{d.title}</QText>
                      <Ionicons name={open ? 'remove' : 'add'} size={20} color={c.ink2} />
                    </Pressable>
                    {open && (
                      <QText variant="subhead" color="ink2" style={{ paddingBottom: space.md }}>
                        {d.body}
                      </QText>
                    )}
                  </View>
                );
              })}
            </View>
          </View>

          {/* Related: one peeking carousel */}
          <View style={{ gap: space.sm }}>
            <QSectionHeader title="Pairs well with your rotation" />
            <ScrollView
              horizontal
              showsHorizontalScrollIndicator={false}
              style={styles.bleed}
              contentContainerStyle={styles.carousel}
            >
              {RELATED.map((r) => (
                <View key={r.id} accessible accessibilityLabel={`${r.name}, ${r.price}`} style={styles.tile}>
                  <View style={[styles.tileMedia, { backgroundColor: c.surface2 }]}>
                    <Sneaker colorway={r.colorway} size={128} />
                  </View>
                  <QText variant="subhead" numberOfLines={large ? undefined : 2}>
                    {r.name}
                  </QText>
                  <QText variant="subhead" color="ink2" style={tabular}>
                    {r.price}
                  </QText>
                </View>
              ))}
            </ScrollView>
          </View>
        </View>
      </QScreen>

      <QBottomActionBar>
        <QPrimaryButton
          title={size ? `Add to bag · ${PRODUCT.price}` : 'Select a size'}
          onPress={addToBag}
          accessibilityHint={size ? undefined : 'Opens the size options'}
        />
      </QBottomActionBar>

      {toast && <QToast message={toast} />}
    </View>
  );
}

const styles = StyleSheet.create({
  scrollContent: { paddingHorizontal: 0, paddingTop: 0, gap: 0 },
  navGlyphs: { flexDirection: 'row', alignItems: 'center', gap: space.xxs },
  mediaPage: { alignItems: 'center', justifyContent: 'center', paddingTop: space.xxl },
  dots: { position: 'absolute', bottom: space.md, left: 0, right: 0, flexDirection: 'row', justifyContent: 'center', gap: space.xs },
  dot: { width: 8, height: 8, borderRadius: radius.capsule },
  dotActive: { width: 20 },
  body: { paddingHorizontal: space.margin, paddingTop: space.xl, gap: space.xxl },
  priceLine: { flexDirection: 'row', flexWrap: 'wrap', alignItems: 'baseline', columnGap: space.sm, rowGap: space.xxs },
  proof: { flexDirection: 'row', alignItems: 'center', gap: space.xxs },
  swatches: { flexDirection: 'row', gap: space.xxs },
  chips: { flexDirection: 'row', flexWrap: 'wrap', gap: space.xs },
  statusLine: { flexDirection: 'row', alignItems: 'center', gap: space.xs },
  alignStart: { alignSelf: 'flex-start' },
  disclosure: { borderTopWidth: StyleSheet.hairlineWidth },
  disclosureHead: { flexDirection: 'row', alignItems: 'center', minHeight: metrics.rowMinHeight, gap: space.sm },
  bleed: { marginHorizontal: -space.margin },
  carousel: { paddingHorizontal: space.margin, gap: space.sm },
  tile: { width: 148, gap: space.xxs },
  tileMedia: { height: 112, borderRadius: radius.m, alignItems: 'center', justifyContent: 'center', marginBottom: space.xxs },
});
