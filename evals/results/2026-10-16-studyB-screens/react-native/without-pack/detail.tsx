import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, Pressable, useWindowDimensions } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import Svg, { Path, Ellipse, Defs, LinearGradient, Stop, G, Circle } from 'react-native-svg';

const sizes = ['6', '6.5', '7', '7.5', '8', '8.5', '9', '9.5', '10', '10.5', '11', '12'];
const colors = [{ name: 'Chalk / Forest', value: '#677661' }, { name: 'Chalk / Clay', value: '#ae795f' }, { name: 'Chalk / Ink', value: '#42484b' }];

function Sneaker({ accent, width }: { accent: string; width: number }) {
  return (
    <Svg width={width} height={width * 0.66} viewBox="0 0 440 290">
      <Defs>
        <LinearGradient id="upper" x1="0" y1="0" x2="0.6" y2="1"><Stop offset="0" stopColor="#fffdf6" /><Stop offset="1" stopColor="#d7d4c7" /></LinearGradient>
        <LinearGradient id="sole" x1="0" y1="0" x2="0" y2="1"><Stop offset="0" stopColor="#f6f2e4" /><Stop offset="1" stopColor="#c4bfae" /></LinearGradient>
        <LinearGradient id="panel" x1="0" y1="0" x2="1" y2="1"><Stop offset="0" stopColor="#eeece2" /><Stop offset="1" stopColor="#c8c8bb" /></LinearGradient>
      </Defs>
      <Ellipse cx="222" cy="247" rx="172" ry="14" fill="#323b2a" opacity="0.09" />
      <Ellipse cx="222" cy="246" rx="137" ry="7" fill="#323b2a" opacity="0.07" />
      <G rotation="-13" origin="220,155">
        <Path d="M46 178 Q43 165 63 148 L91 123 Q102 106 111 74 Q120 59 138 72 L179 107 Q198 117 224 115 L302 131 Q319 138 331 155 L366 172 Q392 181 397 199 L388 218 Q306 237 218 227 L68 211 Q42 205 46 178Z" fill="url(#upper)" stroke="#bdbdad" strokeWidth="1.3" />
        <Path d="M48 187 Q91 202 159 201 L285 213 Q351 213 394 198 L395 214 Q386 230 351 233 L251 238 L81 220 Q50 217 46 206Z" fill="url(#sole)" stroke="#bcb6a4" strokeWidth="1" />
        <Path d="M51 207 Q119 220 203 225 L301 230 Q359 231 391 218 L387 227 Q355 240 304 240 L198 234 L76 222 Q54 219 51 214Z" fill="#9d987f" />
        <Path d="M60 162 L96 128 L112 84 Q116 78 126 84 L155 112 L140 147 L112 170 L68 187 L51 180Z" fill={accent} />
        <Path d="M99 124 L111 85 Q116 77 124 83 L155 111 L146 121 L123 102 L114 137Z" fill="#424c3e" opacity="0.4" />
        <Path d="M110 77 Q119 65 135 76 L176 107 L163 120 L132 100Z" fill="#343b30" />
        <Path d="M128 94 L149 75 Q158 72 165 85 L200 122 L177 146 L146 124Z" fill="url(#panel)" stroke="#b4b6a7" />
        <Path d="M139 92 L151 83 L172 109 L160 118Z" fill={accent} />
        <Path d="M169 119 Q209 113 248 123 L291 135 L283 164 L213 175 L157 157Z" fill="url(#panel)" stroke="#b9baac" />
        <Path d="M156 154 Q183 162 217 150 L284 135 L271 154 L205 180 Q177 189 157 177 L142 165Z" fill={accent} />
        <Path d="M114 174 Q141 151 165 130 L188 117 L204 121 L171 151 Q154 175 154 201 L125 198Z" fill="#e9e6da" stroke="#bfc0b0" />
        <Path d="M159 130 L186 141 M168 122 L198 133 M180 116 L209 126 M194 116 L220 126 M211 119 L234 129" stroke="#a9aa9a" strokeWidth="6" strokeLinecap="round" />
        <Path d="M159 128 L186 139 M168 120 L198 131 M180 114 L209 124 M194 114 L220 124 M211 117 L234 127" stroke="#f9f7eb" strokeWidth="4.5" strokeLinecap="round" />
        <Path d="M291 136 Q313 143 324 160 L358 175 L339 191 L282 188 Q267 172 278 156Z" fill="#eeece3" stroke="#c7c6b7" />
        <Path d="M286 180 Q328 172 362 177 Q386 184 391 198 Q348 214 285 209 L255 206 Q262 189 286 180Z" fill="url(#panel)" stroke="#bdbdae" />
        <Path d="M285 186 Q335 180 369 186" fill="none" stroke="#f8f6ec" strokeWidth="2" strokeDasharray="3 3" />
        <Path d="M70 192 L119 174 L137 158 M161 184 Q184 194 211 184 L268 162" fill="none" stroke="#f4f1e7" strokeWidth="1.5" strokeDasharray="3 3" />
        <Path d="M65 209 L65 215 M78 211 L78 217 M91 213 L91 219 M105 215 L105 220 M315 221 L315 231 M328 220 L328 230 M341 219 L341 229 M354 217 L354 227 M367 214 L367 224" stroke="#b2ad9b" strokeWidth="1" />
        <Circle cx="245" cy="141" r="1.4" fill="#a2a592" /><Circle cx="252" cy="139" r="1.4" fill="#a2a592" /><Circle cx="258" cy="137" r="1.4" fill="#a2a592" />
      </G>
    </Svg>
  );
}

export default function SneakerDetail() {
  const { width } = useWindowDimensions();
  const [selectedSize, setSelectedSize] = useState('9');
  const [colorIndex, setColorIndex] = useState(0);
  const [favorite, setFavorite] = useState(false);
  const [bagCount, setBagCount] = useState(0);
  const [showSizeGuide, setShowSizeGuide] = useState(false);
  const [detailsOpen, setDetailsOpen] = useState(false);
  const [added, setAdded] = useState(false);
  const selectedColor = colors[colorIndex];

  return (
    <SafeAreaView style={styles.safe} edges={['top', 'bottom']}>
      <Stack.Screen options={{ headerShown: false }} />
      <StatusBar style="dark" />
      <View style={styles.header}>
        <View style={styles.wordmark}><Text style={styles.brand}>stride</Text><View style={styles.brandDot} /></View>
        <Text style={styles.headerLabel}>THE EVERYDAY, ELEVATED.</Text>
        <Pressable accessibilityRole="button" accessibilityLabel={`Shopping bag, ${bagCount} items`} onPress={() => setAdded(!added)} style={styles.bagIcon}>
          <Ionicons name="bag-outline" size={23} color="#263124" />
          {bagCount > 0 && <View style={styles.badge}><Text style={styles.badgeText}>{bagCount}</Text></View>}
        </Pressable>
      </View>
      <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={styles.content}>
        <View style={styles.hero}>
          <View style={styles.heroTop}><View style={styles.edition}><View style={styles.smallDot} /><Text style={styles.editionText}>THE COURT COLLECTION</Text></View><Text style={styles.productNumber}>01 / 03</Text></View>
          <Text style={styles.heroWord}>COURT</Text>
          <View style={styles.shoe}><Sneaker width={Math.min(width - 20, 480)} accent={selectedColor.value} /></View>
          <View style={styles.heroBottom}><Text style={styles.heroCaption}>A classic. In your own stride.</Text><View style={styles.pagination}>{colors.map((color, index) => <Pressable accessibilityLabel={`View ${color.name}`} key={color.name} onPress={() => setColorIndex(index)} hitSlop={8} style={[styles.pageDot, colorIndex === index && styles.pageDotActive]} />)}</View></View>
        </View>
        <View style={styles.information}>
          <View style={styles.categoryRow}><Text style={styles.eyebrow}>UNISEX LIFESTYLE</Text><View style={styles.rating}><Ionicons name="star" size={12} color="#657452" /><Text style={styles.ratingText}>4.9 <Text style={styles.reviewCount}>(128)</Text></Text></View></View>
          <View style={styles.titleRow}><Text style={styles.title}>Court 01</Text><Text style={styles.price}>$145<Text style={styles.currency}> USD</Text></Text></View>
          <Text style={styles.description}>Old-school soul. All-day comfort. Your new everyday{width > 390 ? '\n' : ' '}pair, made to go a little further.</Text>
          <View style={styles.colorRow}><Text style={styles.fieldLabel}>Color <Text style={styles.colorName}>— {selectedColor.name}</Text></Text><Text style={styles.colorCount}>0{colorIndex + 1} / 03</Text></View>
          <View style={styles.swatches}>{colors.map((color, index) => <Pressable key={color.name} accessibilityRole="button" accessibilityLabel={color.name} accessibilityState={{ selected: colorIndex === index }} onPress={() => { setColorIndex(index); setAdded(false); }} style={[styles.swatchOuter, colorIndex === index && styles.swatchSelected]}><View style={[styles.swatch, { backgroundColor: color.value }]}><View style={styles.swatchCream} /></View></Pressable>)}</View>
          <View style={styles.sizeHeading}><Text style={styles.fieldLabel}>Select size <Text style={styles.colorName}> (US Men's)</Text></Text><Pressable accessibilityRole="button" onPress={() => setShowSizeGuide(!showSizeGuide)}><Text style={styles.sizeGuide}>Size guide <Ionicons name="arrow-up-right-box" size={12} /></Text></Pressable></View>
          {showSizeGuide && <View style={styles.guide}><Text style={styles.guideTitle}>Find your fit</Text><Text style={styles.guideText}>True to size. For a roomier fit, go half a size up.{ '\n' }US 8 · 26 cm   /   US 9 · 27 cm   /   US 10 · 28 cm</Text></View>}
          <View style={styles.sizeGrid}>{sizes.map(size => <Pressable key={size} accessibilityRole="button" accessibilityLabel={`Size ${size}`} accessibilityState={{ selected: selectedSize === size, disabled: size === '12' }} disabled={size === '12'} onPress={() => { setSelectedSize(size); setAdded(false); }} style={[styles.size, selectedSize === size && styles.sizeSelected, size === '12' && styles.sizeUnavailable]}><Text style={[styles.sizeText, selectedSize === size && styles.sizeTextSelected, size === '12' && styles.unavailableText]}>{size}</Text></Pressable>)}</View>
          <View style={styles.fitNote}><Ionicons name="checkmark-circle-outline" size={15} color="#6e785d" /><Text style={styles.fitText}>Fits true to size. Take your usual size.</Text></View>
          <View style={styles.serviceRow}><View style={styles.service}><Ionicons name="cube-outline" size={18} color="#58634e" /><Text style={styles.serviceText}>Free shipping over $100</Text></View><View style={styles.service}><Ionicons name="refresh-outline" size={18} color="#58634e" /><Text style={styles.serviceText}>30-day easy returns</Text></View></View>
          <Pressable onPress={() => setDetailsOpen(!detailsOpen)} style={styles.detailToggle}><Text style={styles.fieldLabel}>The details</Text><Ionicons name={detailsOpen ? 'remove' : 'add'} size={19} color="#333d2e" /></Pressable>
          {detailsOpen && <Text style={styles.detailText}>Premium leather and breathable suede meet a cushioned recycled footbed. A durable rubber outsole keeps every step grounded. Designed for daily wear, wherever the day takes you.</Text>}
        </View>
      </ScrollView>
      <View style={styles.footer}>
        {added && <View style={styles.confirmation}><Ionicons name="checkmark-circle" size={17} color="#526246" /><Text style={styles.confirmationText}>{bagCount > 0 ? `Court 01 · US ${selectedSize} added to your bag` : 'Your bag is ready for a fresh pair.'}</Text></View>}
        <View style={styles.actionRow}><Pressable accessibilityRole="button" accessibilityLabel={favorite ? 'Remove from wishlist' : 'Save to wishlist'} accessibilityState={{ selected: favorite }} onPress={() => setFavorite(!favorite)} style={[styles.favorite, favorite && styles.favoriteSelected]}><Ionicons name={favorite ? 'heart' : 'heart-outline'} size={23} color="#35432e" /></Pressable><Pressable accessibilityRole="button" onPress={() => { setBagCount(bagCount + 1); setAdded(true); }} style={({ pressed }) => [styles.addButton, pressed && { opacity: 0.85 }]}><Text style={styles.addText}>Add to bag</Text><View style={styles.buttonRight}><Text style={styles.buttonPrice}>$145</Text><Ionicons name="arrow-forward" color="#f9f8f0" size={19} /></View></Pressable></View>
        <View style={styles.stock}><View style={styles.stockDot} /><Text style={styles.stockText}>In stock, ready to find your stride.</Text></View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: '#faf9f5' },
  header: { height: 64, paddingHorizontal: 24, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', borderBottomWidth: 1, borderBottomColor: '#e9e8e0' },
  wordmark: { flexDirection: 'row', alignItems: 'baseline' },
  brand: { fontSize: 31, fontWeight: '800', letterSpacing: -2, color: '#303d29' },
  brandDot: { width: 5, height: 5, backgroundColor: '#7b8964', borderRadius: 3, marginLeft: 3 },
  headerLabel: { fontSize: 8, fontWeight: '600', letterSpacing: 1.3, color: '#7b7e70', marginLeft: 5 },
  bagIcon: { padding: 5 },
  badge: { position: 'absolute', right: -3, top: -2, width: 16, height: 16, borderRadius: 8, backgroundColor: '#657452', justifyContent: 'center', alignItems: 'center' },
  badgeText: { fontSize: 9, color: '#fff', fontWeight: '700' },
  content: { paddingBottom: 8 },
  hero: { backgroundColor: '#eeeee5', height: 304, overflow: 'hidden', margin: 12, marginBottom: 0, borderRadius: 4 },
  heroTop: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', padding: 18, zIndex: 2 },
  edition: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  smallDot: { width: 5, height: 5, borderRadius: 3, backgroundColor: '#748061' },
  editionText: { fontSize: 8, letterSpacing: 1.6, color: '#59634c', fontWeight: '600' },
  productNumber: { fontSize: 9, color: '#7b816e', letterSpacing: 1 },
  heroWord: { position: 'absolute', top: 54, alignSelf: 'center', fontSize: 90, fontWeight: '900', letterSpacing: -5, color: '#e0e3d6' },
  shoe: { position: 'absolute', left: -2, right: -2, top: 31, alignItems: 'center' },
  heroBottom: { position: 'absolute', bottom: 18, left: 18, right: 18, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  heroCaption: { fontSize: 10, color: '#747b68', fontStyle: 'italic' },
  pagination: { flexDirection: 'row', gap: 5, alignItems: 'center' },
  pageDot: { width: 5, height: 5, borderRadius: 3, backgroundColor: '#c8cdbb' },
  pageDotActive: { width: 18, backgroundColor: '#697657' },
  information: { paddingHorizontal: 24, paddingTop: 23 },
  categoryRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  eyebrow: { fontSize: 9, fontWeight: '600', color: '#7c806f', letterSpacing: 1.8 },
  rating: { flexDirection: 'row', gap: 4, alignItems: 'center' },
  ratingText: { fontSize: 10, color: '#3c4633', fontWeight: '600' },
  reviewCount: { color: '#909184', fontWeight: '400' },
  titleRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginTop: 7 },
  title: { fontSize: 34, letterSpacing: -1.3, fontWeight: '600', color: '#293524' },
  price: { fontSize: 22, fontWeight: '500', letterSpacing: -0.6, color: '#35412d' },
  currency: { fontSize: 9, color: '#8c8e7e', letterSpacing: 0.7, fontWeight: '400' },
  description: { fontSize: 12, lineHeight: 19, color: '#858578', marginTop: 8 },
  colorRow: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 23, alignItems: 'center' },
  fieldLabel: { color: '#3d4534', fontSize: 12, fontWeight: '600' },
  colorName: { color: '#919082', fontWeight: '400', fontSize: 11 },
  colorCount: { color: '#a2a192', fontSize: 9, letterSpacing: 0.8 },
  swatches: { flexDirection: 'row', gap: 10, marginTop: 12 },
  swatchOuter: { width: 37, height: 37, borderRadius: 20, borderWidth: 1, borderColor: 'transparent', alignItems: 'center', justifyContent: 'center' },
  swatchSelected: { borderColor: '#6b765b' },
  swatch: { width: 27, height: 27, borderRadius: 15, overflow: 'hidden', transform: [{ rotate: '-40deg' }] },
  swatchCream: { height: 14, backgroundColor: '#e0ddce' },
  sizeHeading: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginTop: 23, marginBottom: 13 },
  sizeGuide: { fontSize: 10, color: '#70755f', textDecorationLine: 'underline' },
  sizeGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 7 },
  size: { width: '14.8%', flexGrow: 1, height: 41, borderWidth: 1, borderColor: '#e1e1d6', borderRadius: 4, alignItems: 'center', justifyContent: 'center', backgroundColor: '#fcfbf7' },
  sizeSelected: { backgroundColor: '#647253', borderColor: '#647253' },
  sizeText: { fontSize: 12, color: '#565e4b', fontWeight: '500' },
  sizeTextSelected: { color: '#fffef6' },
  sizeUnavailable: { backgroundColor: '#f2f1eb', borderColor: '#eeede5' },
  unavailableText: { color: '#c5c5b9', textDecorationLine: 'line-through' },
  fitNote: { flexDirection: 'row', alignItems: 'center', gap: 6, marginTop: 12 },
  fitText: { color: '#979586', fontSize: 10 },
  serviceRow: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 20, marginTop: 6, borderBottomWidth: 1, borderBottomColor: '#e6e5dc' },
  service: { flexDirection: 'row', gap: 7, alignItems: 'center' },
  serviceText: { fontSize: 9, color: '#7f8270' },
  detailToggle: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 18 },
  detailText: { color: '#838573', fontSize: 12, lineHeight: 20, paddingBottom: 15 },
  guide: { padding: 13, backgroundColor: '#eeeee5', marginBottom: 12, borderRadius: 5 },
  guideTitle: { fontSize: 12, fontWeight: '600', color: '#45513b', marginBottom: 5 },
  guideText: { fontSize: 10, lineHeight: 18, color: '#747c66' },
  footer: { paddingHorizontal: 20, paddingTop: 13, borderTopWidth: 1, borderTopColor: '#e7e6dd', backgroundColor: '#faf9f5', paddingBottom: 7 },
  actionRow: { flexDirection: 'row', gap: 10 },
  favorite: { width: 52, height: 51, borderRadius: 5, borderWidth: 1, borderColor: '#d9ddce', alignItems: 'center', justifyContent: 'center' },
  favoriteSelected: { backgroundColor: '#e7ebdf' },
  addButton: { height: 51, flex: 1, borderRadius: 5, paddingHorizontal: 20, backgroundColor: '#3c4d32', flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  addText: { fontSize: 13, fontWeight: '600', color: '#f7f7eb' },
  buttonRight: { flexDirection: 'row', alignItems: 'center', gap: 16 },
  buttonPrice: { fontSize: 12, color: '#d1d8c7' },
  stock: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 5, marginTop: 10 },
  stockDot: { width: 4, height: 4, backgroundColor: '#8a9b6f', borderRadius: 3 },
  stockText: { fontSize: 9, color: '#969987', letterSpacing: 0.2 },
  confirmation: { flexDirection: 'row', gap: 6, alignItems: 'center', justifyContent: 'center', paddingBottom: 11 },
  confirmationText: { fontSize: 11, color: '#526246' },
});
