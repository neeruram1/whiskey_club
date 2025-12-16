# Typography Standardization Guide

## ❌ Current Problems

Your app has **major typography inconsistencies**:

### Font Size Issues:
- 6 different tiny sizes: `text-[0.6rem]`, `text-[0.65rem]`, `text-[0.7rem]`, `text-xs`, `text-sm`, `text-base`
- No clear pattern for when to use which

### Letter Spacing Issues:
- 8 different tracking values: `tracking-[0.22em]`, `tracking-[0.28em]`, `tracking-[0.3em]`, `tracking-[0.32em]`, `tracking-wide`, `tracking-wider`, `tracking-widest`
- Same element types use different tracking randomly

### Color Issues:
- Mix of `text-[#E8D6A7]` and `text-lagavulin-gold`
- Inconsistent opacity patterns

---

## ✅ New Typography System

Created utility classes in `app/assets/stylesheets/typography.css`:

### **Labels** (Small uppercase identifiers)
```html
<!-- For "Style", "Age", "Final Score", etc. -->
<p class="label-xs text-lagavulin-gold/70">Style</p>
<p class="label-sm text-lagavulin-gold">Section Label</p>
```

### **Body Text** (Regular content)
```html
<p class="body-xs text-lagavulin-gold/75">Small description</p>
<p class="body-sm text-lagavulin-gold/90">Regular text</p>
<p class="body-base text-lagavulin-gold">Main content</p>
```

### **Headings** (Titles and section headers)
```html
<h3 class="heading-sm text-lagavulin-gold">Your Top Three</h3>
<h2 class="heading-xl text-lagavulin-gold/90">Tasting History</h2>
<h1 class="heading-3xl text-lagavulin-gold">December 16, 2025</h1>
```

### **Stats/Data** (Numbers and metrics)
```html
<p class="stat-label text-lagavulin-gold/80">Ratings</p>
<p class="stat-value text-lagavulin-gold">42</p>
```

### **Metadata** (Dates, counts, secondary info)
```html
<p class="meta-xs text-lagavulin-gold/70">#1 · WhistlePig</p>
<p class="meta-sm text-lagavulin-gold/60">2 days ago</p>
```

---

## 🎯 Standardization Rules

### **Before → After**

#### Labels:
- ❌ `text-[0.7rem] tracking-[0.32em] uppercase` 
- ✅ `label-xs`

#### Section Headers:
- ❌ `text-sm font-bold tracking-widest uppercase`
- ✅ `heading-sm`

#### Bottle Names:
- ❌ `text-2xl sm:text-3xl small-caps tracking-[0.22em]`
- ✅ `heading-2xl`

#### Stats:
- ❌ `text-xs tracking-[0.28em] uppercase`
- ✅ `stat-label`

#### Stat Values:
- ❌ `text-3xl font-bold tracking-wide`
- ✅ `stat-value`

---

## 📝 Implementation Status

### ✅ Created:
- `app/assets/stylesheets/typography.css` - Complete typography system
- This guide

### ⏳ To Update:
All view files need to be updated to use the new classes:
- `app/views/public/index.html.erb` - Dashboard (highest priority)
- `app/views/bottles/show.html.erb` - Bottle detail page
- `app/views/bottles/_archive.html.erb` - Bottle archive
- `app/views/meetings/show.html.erb` - Meeting detail
- `app/views/layouts/application.html.erb` - Global header/footer
- All other partials and views

---

## 🚀 Quick Wins

Update these high-traffic pages first:

### 1. Dashboard Labels
**Before:**
```html
<p class="text-xs tracking-[0.3em] uppercase text-lagavulin-gold">
  Next Tasting
</p>
```

**After:**
```html
<p class="label-xs text-lagavulin-gold">
  Next Tasting
</p>
```

### 2. Stat Tiles
**Before:**
```html
<p class="text-xs tracking-[0.28em] uppercase text-lagavulin-gold/80">Ratings</p>
<p class="mt-3 text-3xl font-bold text-lagavulin-gold tracking-wide">42</p>
```

**After:**
```html
<p class="stat-label text-lagavulin-gold/80">Ratings</p>
<p class="mt-3 stat-value text-lagavulin-gold">42</p>
```

### 3. Section Headers
**Before:**
```html
<h3 class="text-lagavulin-gold uppercase text-sm font-bold tracking-widest">
  Your Top Three
</h3>
```

**After:**
```html
<h3 class="heading-sm text-lagavulin-gold">
  Your Top Three
</h3>
```

---

## ✨ Benefits

1. **Consistency** - Same elements look the same everywhere
2. **Maintainability** - Change typography globally by editing one file
3. **Faster Development** - No more guessing which classes to use
4. **Cleaner Code** - `label-xs` vs `text-xs tracking-[0.3em] uppercase`
5. **Better UX** - Visual hierarchy is now clear and predictable

---

## 📊 Impact

**Before Standardization:**
- 6 different tiny font sizes
- 8 different tracking values
- Inconsistent patterns across 50+ files

**After Standardization:**
- 3 size categories (label, body, heading, stat, meta)
- Consistent tracking per category
- Single source of truth

---

## 🎨 Color Standardization

Also standardize colors while you're at it:

### Primary Text:
- **Gold (default):** `text-lagavulin-gold`
- **Gold (subtle):** `text-lagavulin-gold/80`
- **Gold (muted):** `text-lagavulin-gold/60`

### Replace all:
- ❌ `text-[#E8D6A7]` → ✅ `text-lagavulin-gold`
- ❌ `text-[#E8D6A7]/70` → ✅ `text-lagavulin-gold/70`

---

## 🔄 Migration Path

1. ✅ Create typography system (done)
2. Update dashboard first (highest visibility)
3. Update bottle pages (most used)
4. Update meeting pages
5. Update auth pages
6. Run final audit

Would you like me to update all the views to use this new system?
