# KeplerGLBase.jl Testing Guide

Testing scripts for Kepler.gl 3.2.0 compatibility in KeplerGLBase.jl.

## Overview

Since KeplerGLBase.jl contains only the core config/data handling and KeplerGL.jl provides the Blink rendering, these test scripts implement the rendering functionality locally to test the base package.

## Files

- **`test_render.jl`**: Comprehensive test suite with render and export functions
- **`interactive_test.jl`**: Quick interactive testing script
- **`runtests.jl`**: Standard Julia test runner (for CI/automated tests)

## Quick Start

### Option 1: Interactive Testing (Recommended)

```julia
# From KeplerGLBase.jl directory
julia> cd("test")
julia> include("interactive_test.jl")

# Run quick test with MapLibre (no token)
julia> m, w = quick_test()

# Or with Mapbox token
julia> m, w = quick_test(token="pk.your_mapbox_token")
```

### Option 2: Comprehensive Tests

```julia
# From KeplerGLBase.jl/test directory
julia> include("test_render.jl")
julia> w = run_all_tests()
```

## Available Test Functions

### Basic Tests

```julia
# Minimal empty map
minimal_test()

# Map without token (uses MapLibre - new in 3.0+)
m = create_test_map_no_token()
w = render(m)

# Map with Mapbox token
m = create_test_map_with_token("pk.your_token")
w = render(m)
```

### Data Visualization Tests

```julia
# Create and render map with random point data
m, w = test_point_map()

# With Mapbox token
m, w = test_point_map(token="pk.your_token")
```

### Config Tests

```julia
# Test v3.2.0 config schema
test_config_v32()  # Returns true if all fields present
```

### Image Export

```julia
# Export current map view to PNG
export_test_image(w, "my_map.png")

# Custom size
export_image(w, "large_map.png", width=1920, height=1080)
```

### Load Example Map

```julia
# Load the earthquake example map
m, w = load_example_map()

# With Mapbox token
m, w = load_example_map(token="pk.your_token")
```

## What's Being Tested

### Kepler.gl 3.2.0 Features

1. **MapLibre Support** (v3.0+)
   - Optional Mapbox token
   - Default "voyager" style

2. **Config Schema** (v3.2.0)
   - Effects array
   - Overlay blending
   - Editor configuration
   - Viewport sync/zoom lock
   - Updated mapStyle structure

3. **React 18 API**
   - `createRoot()` instead of `render()`

4. **JavaScript Libraries**
   - React 18.2.0
   - React-DOM 18.2.0
   - Styled-components 6.1.8
   - Redux 4.2.1
   - React-Redux 8.1.3
   - Kepler.gl 3.2.0

## Expected Behavior

### Success Indicators

✅ Map opens in Blink window
✅ No JavaScript errors in console
✅ MapLibre basemap loads without token
✅ Layers render correctly
✅ Tooltips work on data points
✅ Image export works

### Troubleshooting

**Map doesn't render:**
- Check that JavaScript libraries were downloaded correctly
- Verify path: `KeplerGLBase.jl/assets/js/`
- All 6 JS files should be present (React, React-DOM, Redux, React-Redux, styled-components, keplergl)

**"Token required" error:**
- This shouldn't happen with v3.2.0
- Verify you're using the updated `map.jl` and `config.jl`

**React errors in console:**
- Check that React 18 API is being used (`createRoot`)
- Verify all JS libraries are compatible versions

## Example Session

```julia
julia> cd("test")

julia> include("interactive_test.jl")
KeplerGLBase.jl 3.2.0 - Interactive Test Ready
...

julia> m, w = quick_test()
╔═══════════════════════════════════════════════════════════╗
║       KeplerGL.jl 3.2.0 - Quick Test                      ║
╚═══════════════════════════════════════════════════════════╝

✓ Using MapLibre basemap (no token required)

[1/3] Generating sample data...
  Generated 50 points

[2/3] Creating map...
  Map configured with point layer

[3/3] Rendering map...
  Map rendered successfully!

Success! Map is now visible in browser window.

julia> export_test_image(w, "test.png")
Export successful.
Image saved to: test.png
✓ Image export test complete!

julia> close(w)
```

## Notes

- These tests run independently of KeplerGL.jl
- Blink.jl is required for rendering
- Tests use the new optional token parameter
- All tests work with both MapLibre (default) and Mapbox basemaps

## Compatibility

- Julia ≥ 1.6
- KeplerGLBase.jl (current version)
- Blink.jl 0.12
- Kepler.gl 3.2.0