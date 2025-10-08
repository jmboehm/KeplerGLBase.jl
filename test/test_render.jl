"""
Test script for KeplerGLBase.jl with Kepler.gl 3.2.0 compatibility

This script implements the frontend functionality (Blink rendering)
to test the new Kepler.gl 3.2.0 features in KeplerGLBase.jl.

Usage:
    include("test/test_render.jl")

    # Test 1: Create a basic map without token (MapLibre)
    m = create_test_map_no_token()
    w = render(m)

    # Test 2: Create a map with Mapbox token
    m = create_test_map_with_token("your_mapbox_token")
    w = render(m)

    # Test 3: Test with point data
    m, w = test_point_map()

    # Test 4: Export image
    export_test_image(w, "test_output.png")
"""

using KeplerGLBase
using Blink
using Base64
using DataFrames
using Random

##############################################################################
## Render function (from KeplerGL.jl/src/render.jl)
##############################################################################

"""
    render(map::KeplerGLMap; show::Bool = true)

Renders a `KeplerGLMap` in a new `Blink.jl` window and returns this window.

# Arguments
- `map::KeplerGLMap`: the map that should be rendered
- `show::Bool = true`: whether the window should be shown
"""
function render(map::KeplerGLMap; show::Bool = true)

    dispatch_code = KeplerGLBase.make_dispatch_code(map)
    map_html = KeplerGLBase.make_html(map, dispatch_code)

    blink_options = Dict(
        "width" => map.window[:width],
        "height" => map.window[:height],
        "title" => "KeplerGL.jl 3.2.0 Test",
        "useContentSize" => true,
        "show" => show
    )

    w = Window(blink_options, async=false)
    assetpath = dirname(dirname(@__FILE__))

    @info "Loading JavaScript libraries from: $(joinpath(assetpath, "assets", "js"))"

    load!(w, joinpath(assetpath, "assets", "js", "react.production.min.js"))
    load!(w, joinpath(assetpath, "assets", "js", "react-dom.production.min.js"))
    load!(w, joinpath(assetpath, "assets", "js", "redux.js"))
    load!(w, joinpath(assetpath, "assets", "js", "react-redux.min.js"))
    load!(w, joinpath(assetpath, "assets", "js", "styled-components.min.js"))
    load!(w, joinpath(assetpath, "assets", "js", "keplergl.min.js"))

    body!(w, map_html, async=false)

    @info "Map rendered successfully!"

    return w
end

##############################################################################
## Export function (from KeplerGL.jl/src/export.jl)
##############################################################################

"""
    export_image(window, filename; width = 1000, height = 800,
                 imageDataUri = "data:image/png;base64,2i3u")

Exports an image from `window` to `filename`.

# Arguments
- `window`: the Blink window returned by `render()`
- `filename`: path to save the image
- `width`: image width in pixels
- `height`: image height in pixels
- `imageDataUri`: format ("data:image/png;base64,2i3u" or "data:image/jpg;base64,")
"""
function export_image(window, filename;
    width = 1000, height = 800,
    imageDataUri = "data:image/png;base64,2i3u")

    runjs = """
        (function screenshot(keplerGl, store) {

            keplerGl.setExportImageSetting({exporting: true, processing: true});

            store.dispatch(keplerGl.setExportImageSetting({
                exporting: true,
                processing: true,
                mapW: $width,
                mapH: $height,
                imageSize: {
                    imageH: $height,
                    imageW: $width,
                    scale: 1
                },
                legend: false
            }));

            store.dispatch(keplerGl.setExportImageDataUri('$imageDataUri'));

            store.dispatch(keplerGl.startExportingImage());

        }(KeplerGl, store))
    """

    js(window, Blink.JSString(runjs))

    # Retrieve image data (async operation, may take time)
    img_base64 = ""
    for i=1:50
        img_base64 = js(window, Blink.JSString(
            "window.store.getState().keplerGl.app.uiState.exportImage.imageDataUri"
        ))

        if isempty(img_base64) && i == 10
            error("Error exporting image.")
        elseif isempty(img_base64)
            sleep(0.1)
        else
            @info "Export successful."
            break
        end
    end

    # Write image to file
    img = Base64.base64decode(img_base64[23:end])
    write(filename, img)

    @info "Image saved to: $filename"
end

##############################################################################
## Test Functions
##############################################################################

"""
    create_test_map_no_token()

Creates a basic test map WITHOUT a Mapbox token (uses MapLibre).
This tests the new Kepler.gl 3.0+ feature where token is optional.
"""
function create_test_map_no_token()
    @info "Creating map without token (MapLibre)..."
    m = KeplerGLMap()  # No token needed!
    @info "Map created successfully with MapLibre basemap"
    return m
end

"""
    create_test_map_with_token(token::String)

Creates a test map WITH a Mapbox token.
Tests backward compatibility with Mapbox basemaps.
"""
function create_test_map_with_token(token::String)
    @info "Creating map with Mapbox token..."
    m = KeplerGLMap(token=token)
    @info "Map created successfully with Mapbox basemap"
    return m
end

"""
    test_point_map(; token=nothing)

Creates a map with random point data and renders it.
Returns both the map and window for further testing.
"""
function test_point_map(; token=nothing)
    @info "Creating point map with sample data..."

    # Create sample data
    n = 100
    df = DataFrame(
        lat = randn(n) .* 2 .+ 37.0,
        lon = randn(n) .* 2 .- 122.0,
        value = rand(n) .* 100,
        name = ["Point_$i" for i in 1:n]
    )

    # Create map
    m = KeplerGLMap(token=token)

    # Add point layer with DataFrame directly
    KeplerGLBase.add_point_layer!(m, df, :lat, :lon,
        color_field = :value,
        radius_field = :value,
        radius_fixed = false,
        filled = true,
        opacity = 0.8)

    @info "Sample data added. Rendering..."
    w = render(m)

    return m, w
end

"""
    test_config_v32()

Tests that the new v3.2.0 config schema is properly generated.
"""
function test_config_v32()
    @info "Testing Kepler.gl 3.2.0 config schema..."

    config = KeplerGLBase.make_static_config()

    # Check for new v3.2.0 fields
    @assert haskey(config[:config][:visState], :effects) "Missing 'effects' field"
    @assert haskey(config[:config][:visState], :overlayBlending) "Missing 'overlayBlending' field"
    @assert haskey(config[:config][:visState], :editor) "Missing 'editor' field"
    @assert haskey(config[:config][:mapState], :isViewportSynced) "Missing 'isViewportSynced' field"
    @assert haskey(config[:config][:mapState], :isZoomLocked) "Missing 'isZoomLocked' field"
    @assert haskey(config[:config][:mapState], :splitMapViewports) "Missing 'splitMapViewports' field"
    @assert haskey(config[:config][:mapStyle], :backgroundColor) "Missing 'backgroundColor' field"
    @assert haskey(config[:config], :uiState) "Missing 'uiState' field"

    # Check styleType is 'voyager' (MapLibre compatible)
    @assert config[:config][:mapStyle][:styleType] == "voyager" "styleType should be 'voyager'"

    @info "✓ All v3.2.0 config fields present!"
    return true
end

"""
    export_test_image(window, filename="test_export.png")

Tests image export functionality.
"""
function export_test_image(window, filename="test_export.png")
    @info "Testing image export..."
    export_image(window, filename, width=800, height=600)
    @info "✓ Image export test complete!"
end

##############################################################################
## Example Usage
##############################################################################

"""
    run_all_tests()

Runs all test functions. Use this for a comprehensive test.
"""
function run_all_tests()
    println("="^60)
    println("KeplerGLBase.jl - Kepler.gl 3.2.0 Compatibility Tests")
    println("="^60)

    # Test 1: Config schema
    println("\n[Test 1] Testing config schema...")
    test_config_v32()

    # Test 2: Map without token (MapLibre)
    println("\n[Test 2] Creating map without token (MapLibre)...")
    m1 = create_test_map_no_token()
    println("✓ Map created")

    # Test 3: Render point map
    println("\n[Test 3] Creating and rendering point map...")
    m2, w = test_point_map()
    println("✓ Point map rendered")

    # Test 4: Export image
    println("\n[Test 4] Exporting image...")
    export_test_image(w, "kepler_test_output.png")

    println("\n" * "="^60)
    println("All tests completed successfully!")
    println("="^60)

    return w  # Return window for interactive testing
end

# Print usage info when script is loaded
println("""
KeplerGLBase.jl Test Script Loaded!

Available functions:
  - run_all_tests()                          # Run all tests
  - create_test_map_no_token()              # Create map with MapLibre
  - create_test_map_with_token(token)       # Create map with Mapbox
  - test_point_map(; token=nothing)         # Create & render point map
  - test_config_v32()                       # Test config schema
  - export_test_image(window, filename)     # Export to PNG

Example usage:
  julia> w = run_all_tests()
  julia> m, w = test_point_map()
  julia> export_test_image(w, "my_map.png")
""")