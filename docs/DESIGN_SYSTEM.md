# Seva-Setu Design System

## Overview
This document outlines the design system for Seva-Setu, including design tokens, component patterns, and usage guidelines.

## 🎨 Design Tokens

### Colors

#### Primary Gradients
- **Primary**: `from-purple-600 to-pink-600`
- **Secondary**: `from-blue-500 to-purple-600`
- **Accent**: `from-pink-500 to-purple-600`
- **Success**: `from-green-500 to-emerald-600`
- **Warning**: `from-yellow-500 to-orange-600`
- **Danger**: `from-red-500 to-pink-600`

#### Glass Morphism
- **Light**: `bg-white/10 backdrop-blur-xl border-white/20`
- **Strong**: `bg-white/20 backdrop-blur-xl border-white/30`
- **Dark**: `bg-black/20 backdrop-blur-xl border-white/10`

### Spacing Scale
- **xs**: 4px (1 unit)
- **sm**: 8px (2 units)
- **md**: 16px (4 units)
- **lg**: 24px (6 units)
- **xl**: 32px (8 units)
- **2xl**: 48px (12 units)
- **3xl**: 64px (16 units)
- **4xl**: 96px (24 units)

### Border Radius
- **sm**: `rounded-lg`
- **md**: `rounded-xl`
- **lg**: `rounded-2xl`
- **full**: `rounded-full`
- **card**: `rounded-xl`
- **button**: `rounded-full`
- **input**: `rounded-xl`

### Shadows
- **sm**: `shadow-sm`
- **md**: `shadow-lg`
- **lg**: `shadow-2xl`
- **card**: `shadow-lg hover:shadow-2xl`
- **button**: `shadow-md hover:shadow-lg`

### Typography

#### Font Sizes
- **xs**: `text-xs` (12px)
- **sm**: `text-sm` (14px)
- **base**: `text-base` (16px)
- **lg**: `text-lg` (18px)
- **xl**: `text-xl` (20px)
- **2xl**: `text-2xl` (24px)
- **3xl**: `text-3xl` (30px)
- **4xl**: `text-4xl` (36px)

#### Font Weights
- **normal**: `font-normal` (400)
- **medium**: `font-medium` (500)
- **semibold**: `font-semibold` (600)
- **bold**: `font-bold` (700)

#### Heading Classes
- **h1**: `text-4xl font-bold`
- **h2**: `text-3xl font-bold`
- **h3**: `text-2xl font-semibold`
- **h4**: `text-xl font-semibold`
- **h5**: `text-lg font-semibold`
- **h6**: `text-base font-semibold`

## 🎬 Animation System

### Duration Guidelines
- **Micro (150ms)**: Button press, toggle, checkbox
- **Normal (300ms)**: Modal open/close, dropdown, tooltip
- **Slow (600ms)**: Page transitions, complex animations
- **Slower (1000ms)**: Dramatic effects, celebrations

### Animation Variants

#### Page Transitions
```javascript
import { pageTransition } from '@/lib/animations';
<motion.div {...pageTransition}>Content</motion.div>
```

#### Scroll Animations
```javascript
import { scrollFadeIn } from '@/lib/animations';
<motion.div {...scrollFadeIn(0.2)}>Content</motion.div>
```

#### Card Hover
```javascript
import { cardHover } from '@/lib/animations';
<motion.div variants={cardHover} initial="rest" whileHover="hover">
  Card Content
</motion.div>
```

## 📦 Component Patterns

### Button Variants

#### Primary Button
```jsx
<Button className="rounded-full bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700 shadow-md hover:shadow-lg transition-all">
  Primary Action
</Button>
```

#### Secondary Button
```jsx
<Button variant="outline" className="rounded-full border-white/20 hover:bg-white/5">
  Secondary Action
</Button>
```

#### Icon Button
```jsx
<Button size="icon" className="rounded-full hover:scale-105 transition-transform">
  <Icon className="h-4 w-4" />
</Button>
```

### Card Patterns

#### Standard Card
```jsx
<Card className="glass-card-strong rounded-xl border-white/20 shadow-lg hover:shadow-2xl transition-all duration-300">
  <CardContent>Content</CardContent>
</Card>
```

#### Animated Card
```jsx
import { AnimatedCard } from '@/components/animations/AnimatedComponents';
<AnimatedCard className="glass-card-strong rounded-xl">
  Content
</AnimatedCard>
```

### Input Patterns

#### Standard Input
```jsx
<Input className="glass-input rounded-xl border-white/20 focus:border-purple-500" />
```

#### Textarea
```jsx
<Textarea className="glass-input rounded-xl border-white/20 focus:border-purple-500" />
```

### Modal Pattern
```jsx
<Dialog>
  <DialogContent className="glass-card-strong rounded-2xl border-white/30">
    <DialogHeader>
      <DialogTitle>Modal Title</DialogTitle>
    </DialogHeader>
    Content
  </DialogContent>
</Dialog>
```

## 📱 Responsive Breakpoints

- **sm**: 640px (Mobile landscape)
- **md**: 768px (Tablet)
- **lg**: 1024px (Desktop)
- **xl**: 1280px (Large desktop)
- **2xl**: 1536px (Extra large)

### Mobile-First Approach
Always design for mobile first, then enhance for larger screens:

```jsx
<div className="px-4 md:px-6 lg:px-8">
  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6">
    {/* Content */}
  </div>
</div>
```

## 🎯 Best Practices

### Animation Principles
1. **Purpose**: Every animation should serve a purpose (feedback, guidance, delight)
2. **Performance**: Keep animations at 60fps
3. **Consistency**: Use the same duration/easing for similar actions
4. **Subtlety**: Less is more - don't over-animate

### Spacing Guidelines
1. **Consistent gaps**: Use the spacing scale (4, 8, 16, 24, etc.)
2. **Breathing room**: Don't overcrowd elements
3. **Visual hierarchy**: Use spacing to create hierarchy
4. **Responsive**: Reduce spacing on mobile, increase on desktop

### Color Usage
1. **Hierarchy**: Use gradients for primary actions
2. **Contrast**: Ensure text is always readable
3. **Consistency**: Stick to the color palette
4. **Accessibility**: Maintain WCAG AA contrast ratios

### Typography
1. **Hierarchy**: Use heading classes consistently
2. **Readability**: Maintain good line height and spacing
3. **Font loading**: Optimize font loading for performance
4. **Responsive**: Adjust font sizes for different screens

## 🔧 Utility Classes

### Glass Morphism
- `glass-card`: Basic glass effect
- `glass-card-strong`: Stronger glass effect
- `glass-input`: Glass effect for inputs

### Gradients
- `bg-gradient-to-r from-purple-600 to-pink-600`
- `bg-gradient-to-r from-blue-500 to-purple-600`
- `text-gradient`: For gradient text

### Transitions
- `transition-all duration-200`: Quick transition
- `transition-all duration-300`: Normal transition
- `transition-all duration-500`: Slow transition

## 📚 Component Library

### Available Components
1. **Animation Components**
   - PageTransition
   - ScrollAnimation
   - BackToTop
   - AnimatedCard
   - AnimatedButtons

2. **Skeleton Loaders**
   - SkeletonCard
   - SkeletonText
   - SkeletonAvatar
   - SkeletonButton

3. **Mobile Components**
   - MobileNav
   - PullToRefresh

4. **UI Components** (Radix UI based)
   - Button
   - Card
   - Input
   - Dialog
   - Avatar
   - And more...

## 🚀 Usage Examples

See individual component files for detailed usage examples and props.
