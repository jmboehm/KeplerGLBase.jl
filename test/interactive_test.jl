"""
Interactive Test Script for KeplerGL.jl 3.2.0

Quick and simple interactive testing.

Usage (from Julia REPL in KeplerGLBase.jl directory):

    # Start Julia in the package directory
    julia> cd("test")
    julia> include("interactive_test.jl")

    # Quick test with default MapLibre (no token)
    julia> quick_test()

    # Or with your Mapbox token
    julia> quick_test(token="pk.your_token_here")
"""

using Pkg
Pkg.activate("test")
Pkg.instantiate()

using KeplerGLBase
using Blink
using DataFrames
using CSV
using Random

# Include the render functions
include("test_render.jl")

"""
    quick_test(; token=nothing)

Quick test that creates and renders a simple point map.
"""
function quick_test(; token=nothing)
    println("\n" * "="^60)
    println("KeplerGL.jl 3.2.0 - Quick Test")
    println("="^60)

    if isnothing(token)
        println("\n✓ Using MapLibre basemap (no token required)")
    else
        println("\n✓ Using Mapbox basemap with token")
    end

    # Generate random data
    println("\n[1/3] Generating sample data...")
    n = 50
    df = DataFrame(
        latitude = randn(n) .* 2 .+ 37.0,
        longitude = randn(n) .* 3 .- 122.0,
        magnitude = rand(n) .* 5 .+ 1,
        depth_km = rand(n) .* 100
    )
    println("  Generated $n points")

    # Create map
    println("\n[2/3] Creating map...")
    m = KeplerGLMap(token=token, width=1200, height=800)

    # Add point layer with DataFrame directly
    KeplerGLBase.add_point_layer!(m, df, :latitude, :longitude,
        color_field = :magnitude,
        radius_field = :magnitude,
        radius_fixed = false,
        filled = true,
        opacity = 0.8)

    println("  Map configured with point layer")

    # Render
    println("\n[3/3] Rendering map...")
    w = render(m, show=true)

    println("\n" * "="^60)
    println("Success! Map is now visible in browser window.")
    println("="^60)
    println("\nCommands:")
    println("  - Close window: close(w)")
    println("  - Export image: export_test_image(w, \"output.png\")")
    println("\n")

    return m, w
end

"""
    minimal_test()

Absolutely minimal test - just opens an empty map.
"""
function minimal_test()
    println("Opening minimal empty map with MapLibre...")
    m = KeplerGLMap()
    w = render(m)
    println("✓ Done! Empty map should be visible.")
    return m, w
end

"""
    load_example_map(; token=nothing)

Loads the example earthquake map from the parent directory.
"""
function load_example_map(; token=nothing)
    println("Loading example earthquake map...")

    example_path = joinpath(dirname(@__DIR__), "..",
                           "kepler.gl_example_map_pointmap.json")

    if !isfile(example_path)
        @warn "Example file not found at: $example_path"
        return nothing
    end

    m = KeplerGLBase.load_map_from_json(example_path, token=token)

    println("✓ Example map loaded")
    println("  Rendering...")

    w = render(m)

    println("✓ Done!")
    return m, w
end

# Print instructions
println("""

╔═══════════════════════════════════════════════════════════╗
║       KeplerGL.jl 3.2.0 - Interactive Test Ready         ║
╚══════���════���═══════════════════════════════════════════════╝

Quick Start Commands:

  1. Minimal test (empty map):
     julia> m, w = minimal_test()

  2. Quick test with sample data (MapLibre):
     julia> m, w = quick_test()

  3. Quick test with Mapbox:
     julia> m, w = quick_test(token="pk.your_token")

  4. Load example earthquake map:
     julia> m, w = load_example_map()

  5. Full test suite:
     julia> w = run_all_tests()

Other useful commands:
  - export_test_image(w, "map.png")
  - close(w)

Press Enter to continue...
""")

readline()  # Wait for user