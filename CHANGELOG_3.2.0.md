# Changelog: Kepler.gl 3.2.0 Upgrade

## Summary

KeplerGLBase.jl has been updated to support Kepler.gl 3.2.0, including all compatibility changes from versions 3.0.0 through 3.2.0.

## Breaking Changes

### 1. Token Parameter (API Change)

**Before (v2.5.5):**
```julia
m = KeplerGLMap("pk.my_mapbox_token")  # Positional argument
```

**After (v3.2.0):**
```julia
# Keyword argument (BREAKING CHANGE)
m = KeplerGLMap(token="pk.my_mapbox_token")

# OR use MapLibre (no token required - NEW in 3.0+)
m = KeplerGLMap()  # Token is now optional!
```

### 2. `load_map_from_json` Signature

**Before:**
```julia
m = load_map_from_json("token", "map.json")
```

**After:**
```julia
m = load_map_from_json("map.json", token="pk.token")  # Keyword argument
m = load_map_from_json("map.json")  # Token optional
```

## New Features

### MapLibre Support (v3.0+)

Kepler.gl now uses MapLibre as the default basemap, which doesn't require an API token:

```julia
# No token needed!
m = KeplerGLMap()
w = render(m)
```

You can still use Mapbox if you prefer:
```julia
m = KeplerGLMap(token="pk.your_mapbox_token")
```

### Updated Config Schema (v3.2.0)

The default config now includes new fields for v3.2.0 features:

- **Effects**: `visState.effects` - Post-processing effects array
- **Overlay Blending**: `visState.overlayBlending` - Blending mode for overlays
- **Editor**: `visState.editor` - Built-in GeoJSON editor configuration
- **Viewport Sync**: `mapState.isViewportSynced` - Synchronize split viewports
- **Zoom Lock**: `mapState.isZoomLocked` - Lock zoom level
- **Split Viewports**: `mapState.splitMapViewports` - Split map viewport configs
- **Background Color**: `mapStyle.backgroundColor` - Map background color
- **UI State**: `uiState` - UI control states

## Technical Updates

### JavaScript Libraries

All dependencies updated to versions compatible with Kepler.gl 3.2.0:

| Library | Old Version | New Version |
|---------|-------------|-------------|
| React | ~16.x/17.x | 18.2.0 |
| React-DOM | ~16.x/17.x | 18.2.0 |
| Styled-components | Unknown | 6.1.8 |
| Redux | Unknown | 4.2.1 |
| React-Redux | Unknown | 8.1.3 |
| Kepler.gl | 2.5.5 | 3.2.0 |

### React 18 API

The rendering now uses React 18's `createRoot` API:

**Before (React 16/17):**
```javascript
ReactDOM.render(app, document.getElementById('app'));
```

**After (React 18):**
```javascript
const root = ReactDOM.createRoot(document.getElementById('app'));
root.render(app);
```

### Default Map Style

Changed from "light" to "voyager" (MapLibre-compatible style):

```julia
# Old config
"styleType": "light"

# New config
"styleType": "voyager"
```

## Files Modified

### Core Changes

1. **`assets/js/`** - All JavaScript libraries updated
2. **`src/map.jl`** - Token made optional, React 18 API, token validation removed
3. **`src/config.jl`** - Updated default config schema for v3.2.0

### New Test Files

1. **`test/test_render.jl`** - Comprehensive test suite with rendering
2. **`test/interactive_test.jl`** - Quick interactive testing
3. **`test/README_TESTING.md`** - Testing documentation

## Migration Guide

### Step 1: Update Function Calls

Replace all positional token arguments with keyword arguments:

```julia
# Old
m = KeplerGLMap("token")
m = load_map_from_json("token", "file.json")

# New
m = KeplerGLMap(token="token")
m = load_map_from_json("file.json", token="token")
```

### Step 2: Consider Removing Tokens

If you don't need Mapbox-specific features, you can remove the token entirely:

```julia
# MapLibre works great without a token!
m = KeplerGLMap()
```

### Step 3: Test Your Maps

Use the new test scripts to verify compatibility:

```julia
cd("test")
include("interactive_test.jl")
m, w = quick_test()
```

## Compatibility

- **Julia**: ≥ 1.6
- **Kepler.gl**: 3.2.0
- **Blink.jl**: 0.12
- **React**: 18.2.0

## Future Features (Not Yet Implemented)

The following v3.0+ features are supported by the config schema but don't yet have Julia interfaces:

- Vector Tile Layer (v3.1)
- Raster Tile Layer (v3.2)
- WMS Layer (v3.2)
- DuckDB/SQL support (v3.1)
- Post-processing effects (v3.0)
- GeoJSON editor integration (v3.0+)

These can be configured manually through the config JSON until Julia interfaces are added.

## Testing

Run the test suite:

```julia
# Quick test
cd("test")
include("interactive_test.jl")
m, w = quick_test()

# Full test suite
include("test_render.jl")
w = run_all_tests()
```

## References

- [Kepler.gl 3.0 Release Notes](https://openjsf.org/blog/whats-new-in-the-keplergl-30-application)
- [Kepler.gl Documentation](https://docs.kepler.gl)
- [React 18 Migration Guide](https://react.dev/blog/2022/03/08/react-18-upgrade-guide)
- [MapLibre GL JS](https://maplibre.org/maplibre-gl-js-docs/api/)

---

**Version**: KeplerGLBase.jl 0.0.2+ (Kepler.gl 3.2.0 compatible)
**Date**: 2025-10-05