// Product detail — sneaker store.
// Archetype: Detail. Job: pick a size and add this pair to the bag.
// Focal: full-bleed product media + name/price block. Primary: "Add to bag · $148" (pinned).
// Cut: "Buy now" button, inline size wall (moved into a native page sheet), full description (3-line preview + disclosure).

import React, { useEffect, useRef, useState } from 'react';
import {
  Modal,
  NativeScrollEvent,
  NativeSyntheticEvent,
  Pressable,
  ScrollView,
  Share,
  StyleSheet,
  View,
  useWindowDimensions,
} from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import * as Haptics from 'expo-haptics';
import { Ionicons } from '@expo/vector-icons';
import Svg, { Ellipse, G, Line, Path } from 'react-native-svg';
import { innerRadius, metrics, radius, space, tabular, useTheme } from '../../pack/theme';
import {
  BottomActionBar,
  Chip,
  GroupedSection,
  IconButton,
  ListRow,
  ObjectCard,
  PrimaryButton,
  TertiaryButton,
  Toast,
  Txt,
  useLargeText,
} from '../../pack/components';

// ── Sample data ──────────────────────────────────────────────────────

type SizeOption = { label: string; stock: number };

const product = {
  brand: 'Halden Running',
  name: 'Corsa Trail 3',
  price: 148,
  rating: 4.7,
  reviews: 1284,
  colorways: ['Clay / Bone', 'Moss / Black', 'Fog Grey'],
  description:
    'A road-to-trail runner with a rockered foam midsole and a 4 mm lugged outsole that grips wet gravel without feeling clunky on pavement. The recycled ripstop upper sheds mud, dries fast and keeps its shape after 500 km. A padded, gusseted tongue keeps grit out on the descents.',
  sizes: [
    { label: '7', stock: 4 },
    { label: '7.5', stock: 0 },
    { label: '8', stock: 9 },
    { label: '8.5', stock: 12 },
    { label: '9', stock: 7 },
    { label: '9.5', stock: 2 },
    { label: '10', stock: 3 },
    { label: '10.5', stock: 11 },
    { label: '11', stock: 6 },
    { label: '11.5', stock: 0 },
    { label: '12', stock: 5 },
    { label: '13', stock: 1 },
  ] as SizeOption[],
  details: [
    {
      title: 'Size & fit',
      body: 'Fits true to size with a roomy toe box. Between sizes or running ultras? Go half a size up. Heel-to-toe drop is 6 mm.',
    },
    {
      title: 'Materials & care',
      body: 'Upper: 62% recycled polyester ripstop. Midsole: sugarcane-based EVA blend. Outsole: Vibram Megagrip rubber. Hand wash cold and air dry away from heat.',
    },
    {
      title: 'Delivery & returns',
      body: 'Free standard delivery on orders over $75, arriving in 2–4 business days. Return unworn pairs within 30 days, or run in them for 14 days under our test-run guarantee.',
    },
  ],
};

const related = [
  { id: 'r1', name: 'Corsa Road 2', price: '$132.00', view: 0 as const },
  { id: 'r2', name: 'Ridgeline GTX', price: '$176.00', view: 1 as const },
  { id: 'r3', name: 'Tempo Lite', price: '$118.50', view: 0 as const },
  { id: 'r4', name: 'Fellside Mid', price: '$189.00', view: 1 as const },
];

const MEDIA_VIEWS = ['Outer side', 'Inner side', 'Outsole'] as const;

// ── Product illustration (no remote images: drawn with theme roles) ──

function SneakerArt({ view, width }: { view: 0 | 1 | 2; width: number }) {
  const { c } = useTheme();
  const height = width * 0.62;
  if (view === 2) {
    return (
      <Svg width={width} height={height} viewBox="0 0 320 200" accessibilityElementsHidden importantForAccessibility="no-hide-descendants">
        <G transform="rotate(-12 160 100)">
          <Path
            d="M40 100 C40 70 70 58 110 60 L230 66 C270 68 292 82 292 102 C292 124 270 138 232 138 L120 142 C70 144 40 130 40 100 Z"
            fill={c.ink}
          />
          {[80, 108, 136, 164, 192, 220, 248].map((x) => (
            <Line key={x} x1={x} y1={74} x2={x + 6} y2={128} stroke={c.ink2} strokeWidth={3} strokeLinecap="round" />
          ))}
          <Ellipse cx={252} cy={102} rx={18} ry={14} fill="none" stroke={c.ink2} strokeWidth={3} />
        </G>
      </Svg>
    );
  }
  const mirrored = view === 1;
  return (
    <Svg width={width} height={height} viewBox="0 0 320 200" accessibilityElementsHidden importantForAccessibility="no-hide-descendants">
      <G transform={mirrored ? 'translate(320 0) scale(-1 1)' : undefined}>
        {/* outsole */}
        <Path d="M18 150 L302 150 Q306 168 288 172 L36 172 Q16 170 18 150 Z" fill={c.ink} />
        {/* midsole */}
        <Path d="M20 132 L300 128 Q306 140 302 150 L18 150 Q16 140 20 132 Z" fill={c.canvas} stroke={c.ink} strokeWidth={2.5} />
        {/* upper */}
        <Path
          d="M22 132 C24 104 44 92 78 88 L120 56 Q132 46 150 50 L196 64 C232 74 268 94 292 116 Q302 124 300 128 Z"
          fill={c.surface}
          stroke={c.ink}
          strokeWidth={2.5}
          strokeLinejoin="round"
        />
        {/* heel counter */}
        <Path d="M22 132 C24 110 34 98 52 92 L60 128 Z" fill={c.surface2} stroke={c.ink} strokeWidth={2} />
        {/* side stripe */}
        <Path d="M88 120 C120 96 168 82 226 96" fill="none" stroke={c.ink2} strokeWidth={5} strokeLinecap="round" />
        {/* laces */}
        {[0, 1, 2, 3].map((i) => (
          <Line
            key={i}
            x1={132 + i * 18}
            y1={60 + i * 6}
            x2={146 + i * 18}
            y2={72 + i * 6}
            stroke={c.ink}
            strokeWidth={3}
            strokeLinecap="round"
          />
        ))}
        {/* toe bumper */}
        <Path d="M262 108 Q292 116 300 128" fill="none" stroke={c.ink} strokeWidth={2} />
        {/* lugs */}
        {[48, 84, 120, 156, 192, 228, 264].map((x) => (
          <Path key={x} d={`M${x} 172 L${x + 6} 178 L${x + 18} 178 L${x + 24} 172 Z`} fill={c.ink} />
        ))}
      </G>
    </Svg>
  );
}

// ── Media pager ──────────────────────────────────────────────────────

function MediaPager({ topInset }: { topInset: number }) {
  const { c } = useTheme();
  const { width } = useWindowDimensions();
  const [page, setPage] = useState(0);
  const height = Math.round(width * 0.92);

  const onEnd = (e: NativeSyntheticEvent<NativeScrollEvent>) => {
    setPage(Math.round(e.nativeEvent.contentOffset.x / width));
  };

  return (
    <View style={{ backgroundColor: c.surface2 }}>
      <ScrollView horizontal pagingEnabled showsHorizontalScrollIndicator={false} onMomentumScrollEnd={onEnd}>
        {MEDIA_VIEWS.map((label, i) => (
          <View
            key={label}
            accessible
            accessibilityRole="image"
            accessibilityLabel={`${product.name} in ${product.colorways[0]}, ${label.toLowerCase()} view, ${i + 1} of ${MEDIA_VIEWS.length}`}
            style={{ width, height, paddingTop: topInset, alignItems: 'center', justifyContent: 'center' }}
          >
            <SneakerArt view={i as 0 | 1 | 2} width={width - space.xxl * 2} />
          </View>
        ))}
      </ScrollView>
      <View style={styles.dots} importantForAccessibility="no-hide-descendants" accessibilityElementsHidden>
        {MEDIA_VIEWS.map((label, i) => (
          <View key={label} style={[styles.dot, { backgroundColor: i === page ? c.ink : c.ink3 }]} />
        ))}
      </View>
    </View>
  );
}

// ── Disclosure row ───────────────────────────────────────────────────

function DisclosureRow({ title, body }: { title: string; body: string }) {
  const { c } = useTheme();
  const [open, setOpen] = useState(false);
  return (
    <Pressable
      onPress={() => setOpen((v) => !v)}
      accessibilityRole="button"
      accessibilityLabel={title}
      accessibilityState={{ expanded: open }}
    >
      {({ pressed }) => (
        <View style={[styles.disclosure, pressed && { backgroundColor: c.surface2 }]}>
          <View style={styles.disclosureHead}>
            <Txt style={{ flex: 1 }}>{title}</Txt>
            <Ionicons name={open ? 'remove' : 'add'} size={20} color={c.ink2} />
          </View>
          {open && (
            <Txt variant="subhead" color="ink2">
              {body}
            </Txt>
          )}
        </View>
      )}
    </Pressable>
  );
}

// ── Size sheet (native page sheet on iOS) ────────────────────────────

function SizeSheet({
  visible,
  selected,
  onSelect,
  onClose,
}: {
  visible: boolean;
  selected: string | null;
  onSelect: (size: string) => void;
  onClose: () => void;
}) {
  const { c } = useTheme();
  const insets = useSafeAreaInsets();
  return (
    <Modal visible={visible} animationType="slide" presentationStyle="pageSheet" onRequestClose={onClose}>
      <View style={{ flex: 1, backgroundColor: c.canvas }}>
        <View style={styles.sheetHeader}>
          <Txt variant="title" role="header" style={{ flex: 1 }}>
            Select a size
          </Txt>
          <IconButton icon="close" label="Close size picker" onPress={onClose} filled />
        </View>
        <ScrollView contentContainerStyle={{ paddingHorizontal: space.margin, paddingBottom: insets.bottom + space.xl, gap: space.md }}>
          <Txt variant="subhead" color="ink2">
            US men’s sizing. Fits true to size — between sizes, go half up.
          </Txt>
          <View style={styles.sizeGrid}>
            {product.sizes.map((s) => {
              const soldOut = s.stock === 0;
              const isSelected = s.label === selected;
              return (
                <Pressable
                  key={s.label}
                  disabled={soldOut}
                  onPress={() => onSelect(s.label)}
                  accessibilityRole="button"
                  accessibilityLabel={`US ${s.label}${soldOut ? ', sold out' : s.stock <= 3 ? `, only ${s.stock} left` : ''}`}
                  accessibilityState={{ selected: isSelected, disabled: soldOut }}
                  style={({ pressed }) => [
                    styles.sizeCell,
                    { backgroundColor: isSelected ? c.primaryFill : c.surface, borderColor: c.hairline },
                    pressed && { opacity: 0.7 },
                  ]}
                >
                  <Txt
                    color={isSelected ? 'onPrimary' : soldOut ? 'ink3' : 'ink'}
                    style={[tabular, soldOut && styles.strike]}
                  >
                    {s.label}
                  </Txt>
                </Pressable>
              );
            })}
          </View>
          <Txt variant="footnote" color="ink2">
            Struck-through sizes are sold out. Restocks usually land within two weeks.
          </Txt>
        </ScrollView>
      </View>
    </Modal>
  );
}

// ── Screen ───────────────────────────────────────────────────────────

export default function ProductDetailScreen() {
  const { c } = useTheme();
  const insets = useSafeAreaInsets();
  const large = useLargeText();
  const [colorway, setColorway] = useState(product.colorways[0]);
  const [size, setSize] = useState<string | null>(null);
  const [sheetOpen, setSheetOpen] = useState(false);
  const [saved, setSaved] = useState(false);
  const [expanded, setExpanded] = useState(false);
  const [adding, setAdding] = useState(false);
  const [toast, setToast] = useState<string | null>(null);
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => () => {
    if (timer.current) clearTimeout(timer.current);
  }, []);

  const selectedSize = product.sizes.find((s) => s.label === size);
  const price = `$${product.price.toFixed(2)}`;

  const toggleSaved = () => {
    Haptics.selectionAsync();
    setSaved((v) => !v);
  };

  const share = () => {
    Share.share({ message: `${product.brand} ${product.name} — ${price}` });
  };

  const chooseSize = (label: string) => {
    Haptics.selectionAsync();
    setSize(label);
    setSheetOpen(false);
  };

  const addToBag = () => {
    if (!size) {
      setSheetOpen(true);
      return;
    }
    setAdding(true);
    timer.current = setTimeout(() => {
      setAdding(false);
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      setToast(`Added US ${size} · ${colorway} to your bag`);
      timer.current = setTimeout(() => setToast(null), 2400);
    }, 700);
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
            <View style={styles.headerActions}>
              <IconButton icon={saved ? 'heart' : 'heart-outline'} label={saved ? 'Remove from saved' : 'Save to favourites'} onPress={toggleSaved} filled />
              <IconButton icon="share-outline" label="Share product" onPress={share} filled />
            </View>
          ),
        }}
      />

      <ScrollView
        style={{ flex: 1 }}
        contentInsetAdjustmentBehavior="never"
        contentContainerStyle={{ paddingBottom: space.xxl, gap: space.xl }}
      >
        <MediaPager topInset={insets.top} />

        <View style={styles.margin}>
          {/* Title block: what it is, how much, one proof point */}
          <View style={{ gap: space.xxs }}>
            <Txt variant="overline" color="ink2">
              {product.brand}
            </Txt>
            <Txt variant="title" role="header">
              {product.name}
            </Txt>
            <View style={styles.priceLine}>
              <Txt variant="title" style={tabular}>
                {price}
              </Txt>
              <View
                style={styles.rating}
                accessible
                accessibilityLabel={`Rated ${product.rating} out of 5 from ${product.reviews.toLocaleString('en-US')} reviews`}
              >
                <Ionicons name="star" size={14} color={c.accent} />
                <Txt variant="subhead" color="ink2" style={tabular}>
                  {product.rating} ({product.reviews.toLocaleString('en-US')})
                </Txt>
              </View>
            </View>
          </View>
        </View>

        {/* Options */}
        <View style={[styles.margin, { gap: space.sm }]}>
          <Txt variant="subhead" color="ink2">
            Colour · <Txt variant="subhead">{colorway}</Txt>
          </Txt>
          <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={{ gap: space.xs }}>
            {product.colorways.map((cw) => (
              <Chip
                key={cw}
                title={cw}
                selected={cw === colorway}
                onPress={() => {
                  Haptics.selectionAsync();
                  setColorway(cw);
                }}
              />
            ))}
          </ScrollView>
        </View>

        <View style={[styles.margin, { gap: space.xs }]}>
          <GroupedSection>
            <ListRow title="Size" value={size ? `US ${size}` : 'Select'} onPress={() => setSheetOpen(true)} />
          </GroupedSection>
          {selectedSize && selectedSize.stock <= 3 ? (
            <View style={styles.note}>
              <Ionicons name="alert-circle-outline" size={16} color={c.warning} />
              <Txt variant="subhead" color="warning" style={{ flex: 1 }}>
                Only {selectedSize.stock} left in US {selectedSize.label}
              </Txt>
            </View>
          ) : (
            <View style={styles.note}>
              <Ionicons name="cube-outline" size={16} color={c.ink2} />
              <Txt variant="subhead" color="ink2" style={{ flex: 1 }}>
                Free delivery by Fri, Oct 17 · Free 30-day returns
              </Txt>
            </View>
          )}
        </View>

        {/* Description preview + disclosure */}
        <View style={[styles.margin, { gap: space.xs }]}>
          <Txt numberOfLines={expanded ? undefined : 3}>{product.description}</Txt>
          <View style={{ alignSelf: 'flex-start' }}>
            <TertiaryButton title={expanded ? 'Less' : 'More'} onPress={() => setExpanded((v) => !v)} />
          </View>
        </View>

        <View style={styles.margin}>
          <GroupedSection>
            {product.details.map((d) => (
              <DisclosureRow key={d.title} title={d.title} body={d.body} />
            ))}
          </GroupedSection>
        </View>

        {/* Related carousel */}
        <View style={{ gap: space.sm }}>
          <Txt variant="overline" color="ink2" role="header" style={styles.margin}>
            More from Halden
          </Txt>
          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={{ paddingHorizontal: space.margin, gap: space.sm }}
          >
            {related.map((r) => (
              <ObjectCard
                key={r.id}
                onPress={() => {}}
                accessibilityLabel={`${r.name}, ${r.price}`}
                style={{ width: large ? 220 : 160, padding: space.sm, gap: space.xs }}
              >
                <View style={[styles.thumb, { backgroundColor: c.surface2 }]}>
                  <SneakerArt view={r.view} width={large ? 180 : 120} />
                </View>
                <Txt variant="subhead" numberOfLines={large ? undefined : 1}>
                  {r.name}
                </Txt>
                <Txt variant="subhead" color="ink2" style={tabular}>
                  {r.price}
                </Txt>
              </ObjectCard>
            ))}
          </ScrollView>
        </View>
      </ScrollView>

      <BottomActionBar>
        <PrimaryButton
          title={size ? `Add to bag · ${price}` : 'Select a size'}
          onPress={addToBag}
          loading={adding}
          accessibilityHint={size ? undefined : 'Opens the size picker'}
        />
      </BottomActionBar>

      <SizeSheet visible={sheetOpen} selected={size} onSelect={chooseSize} onClose={() => setSheetOpen(false)} />

      {toast && <Toast message={toast} />}
    </View>
  );
}

const styles = StyleSheet.create({
  margin: { paddingHorizontal: space.margin },
  headerActions: { flexDirection: 'row', gap: space.xs },
  dots: { flexDirection: 'row', gap: space.xs, alignSelf: 'center', position: 'absolute', bottom: space.md },
  dot: { width: space.xs, height: space.xs, borderRadius: radius.capsule },
  priceLine: { flexDirection: 'row', flexWrap: 'wrap', alignItems: 'baseline', columnGap: space.sm, rowGap: space.xxs },
  rating: { flexDirection: 'row', alignItems: 'center', gap: space.xxs },
  note: { flexDirection: 'row', alignItems: 'center', gap: space.xs, paddingHorizontal: space.md },
  disclosure: { minHeight: metrics.rowMinHeight, justifyContent: 'center', paddingHorizontal: space.md, paddingVertical: space.sm, gap: space.xs },
  disclosureHead: { flexDirection: 'row', alignItems: 'center', gap: space.sm },
  sheetHeader: { flexDirection: 'row', alignItems: 'center', paddingHorizontal: space.margin, paddingTop: space.xl, paddingBottom: space.md },
  sizeGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: space.xs },
  sizeCell: {
    width: '23%',
    flexGrow: 1,
    minHeight: metrics.buttonHeight,
    borderRadius: radius.m,
    borderWidth: StyleSheet.hairlineWidth,
    alignItems: 'center',
    justifyContent: 'center',
  },
  strike: { textDecorationLine: 'line-through' },
  thumb: { borderRadius: innerRadius(radius.l, space.sm), alignItems: 'center', justifyContent: 'center', paddingVertical: space.sm },
});
