# function create_config()

# end

# # two presets: 

# # interactive window
# function interactive()

# end

# this returns a minimal config for a static map compatible with Kepler.gl 3.2.0
function make_static_config()
    t = """
        {
            "version": "v1",
            "config": {
                "visState": {
                    "filters": [
                    ],
                    "layers": [
                    ],
                    "effects": [],
                    "interactionConfig": {
                        "tooltip": {
                            "fieldsToShow": {
                            },
                            "compareMode": false,
                            "compareType": "absolute",
                            "enabled": false
                        },
                        "brush": {
                            "size": 0.5,
                            "enabled": false
                        },
                        "geocoder": {
                            "enabled": false
                        },
                        "coordinate": {
                            "enabled": false
                        }
                    },
                    "layerBlending": "normal",
                    "overlayBlending": "normal",
                    "splitMaps": [],
                    "animationConfig": {
                        "currentTime": null,
                        "speed": 1
                    },
                    "editor": {
                        "features": [],
                        "visible": true
                    }
                },
                "mapState": {
                    "bearing": 0,
                    "dragRotate": false,
                    "latitude": 37.05881309947238,
                    "longitude": -122.80009283836715,
                    "pitch": 0,
                    "zoom": 8.0,
                    "isSplit": false,
                    "isViewportSynced": true,
                    "isZoomLocked": false,
                    "splitMapViewports": []
                },
                "mapStyle": {
                    "styleType": "voyager",
                    "topLayerGroups": {},
                    "visibleLayerGroups": {
                        "label": true,
                        "road": true,
                        "border": false,
                        "building": true,
                        "water": true,
                        "land": true,
                        "3d building": false
                    },
                    "threeDBuildingColor": [
                        233.71862868880427,
                        230.92517894351974,
                        226.26942936804556
                    ],
                    "backgroundColor": [0, 0, 0],
                    "mapStyles": {}
                },
                "uiState": {
                    "mapControls": {
                        "mapLegend": {
                            "active": false
                        }
                    }
                }
            }
        }
        """
    a = JSON3.read(t)
    return copy(a)
end



