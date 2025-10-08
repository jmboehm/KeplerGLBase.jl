"""
Fresh test to verify the token fix

Run this in a NEW Julia session:
    julia> cd("test")
    julia> include("test_fresh.jl")
"""

# Force reload of the package
using Pkg
Pkg.activate("test")
Pkg.instantiate()

println("Loading KeplerGLBase...")
using KeplerGLBase
using Blink
using DataFrames

println("\nCreating test map...")
df = DataFrame(
    latitude = [37.7749, 34.0522, 40.7128],
    longitude = [-122.4194, -118.2437, -74.0060],
    city = ["San Francisco", "Los Angeles", "New York"]
)

m = KeplerGLMap()  # No token

println("Adding point layer...")
KeplerGLBase.add_point_layer!(m, df, :latitude, :longitude)

println("\nChecking generated HTML for token handling...")
html = KeplerGLBase.get_html(m)

# Check if token is set to undefined
if occursin("MAPBOX_TOKEN = undefined", html)
    println("✓ Token correctly set to undefined")
else
    println("✗ ERROR: Token not set to undefined")
    println("  Looking for: MAPBOX_TOKEN = undefined")
    # Find what it actually is
    m_idx = findfirst("MAPBOX_TOKEN = ", html)
    if !isnothing(m_idx)
        excerpt = html[m_idx[1]:min(m_idx[end]+50, length(html))]
        println("  Found: $excerpt")
    end
end

println("\nRendering map...")
include("test_render.jl")
w = render(m, show=true)

println("\n" * "="^60)
println("Map rendered!")
println("="^60)
println("\nCheck the browser console for:")
println("  - NO 'Mapbox Token not valid' error")
println("  - [KeplerGL.jl] debug messages")
println("\nIf you see points on the map, it works!")
println("="^60)

(m, w)