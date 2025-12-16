# Image Optimization Guide

## Background Image Optimization

The `charredoak.png` file is currently **1.8MB** which significantly impacts page load time.

### Quick Optimization Steps:

1. **Install ImageMagick** (if not already installed):
   ```bash
   brew install imagemagick
   ```

2. **Optimize the PNG**:
   ```bash
   cd app/assets/images
   # Create optimized version (compress and reduce quality slightly)
   magick charredoak.png -strip -quality 85 -resize 2000x2000\> charredoak-optimized.png
   # Replace original
   mv charredoak-optimized.png charredoak.png
   ```

3. **Convert to WebP** (modern format, better compression):
   ```bash
   magick charredoak.png -quality 80 charredoak.webp
   ```

4. **Expected Results**:
   - Optimized PNG: ~400-600KB (70% reduction)
   - WebP format: ~200-300KB (85% reduction)

### Alternative: Use Online Tools

If you prefer not to install ImageMagick:
- **TinyPNG**: https://tinypng.com/ (drag & drop, excellent compression)
- **Squoosh**: https://squoosh.app/ (Google's image optimizer)

### After Optimization:

Update `app/views/layouts/application.html.erb` to use the WebP version with PNG fallback.

Target size: **< 500KB** for optimal load times.
