// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

// Simplified Alpha Blended Particle shader. Differences from regular Alpha Blended Particle one:
// - no Tint color
// - no Smooth particle support
// - no AlphaTest
// - no ColorMask

Shader "Custom/MobileParticlesMultiply" {
        
    Properties {
        _MainTex ("Particle Texture", 2D) = "white" {}
    }

    Category {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
        Blend Zero SrcColor
        Cull Off Lighting Off ZWrite Off Fog { Mode Off }

        BindChannels {
            Bind "Color", color
            Bind "Vertex", vertex
            Bind "TexCoord", texcoord
        }

        SubShader {
            Pass {
                SetTexture [_MainTex] {
                    combine texture * primary
                }
                SetTexture [_MainTex] {
                    constantColor (1,1,1,1)
                    combine previous lerp (previous) constant
                }
            }
        }
    }
}