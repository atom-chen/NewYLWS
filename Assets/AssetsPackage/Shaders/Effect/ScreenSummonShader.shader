Shader "Custom/ScreenSummonShader" {
	Properties {
		_Color ("color", Color) = (1,1,1,1)
		_AlphaTex ("ScreenShotTex (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		Pass { // Pass 0
			ZWrite Off
			ZTest OFf
			Cull Off
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#include "UnityCG.cginc"
            struct appdata {
                float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
            };
            struct v2f {
                float4 pos : SV_POSITION;
				half2 texcoord : TEXCOORD0;
            };

			sampler2D _AlphaTex;
            float4 _AlphaTex_ST;
			float4 _Color;

            v2f vert(appdata v) {
                v2f o;
                o.pos = mul(UNITY_MATRIX_VP, v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _AlphaTex);
                return o;
            }
            fixed4 frag(v2f i) : COLOR {
				fixed4 col = tex2D(_AlphaTex, i.texcoord);
				col.rgb = (1, 1, 1);
				col = col * _Color;
                return col;
            }
            ENDCG
		}
	}
	FallBack "Diffuse"
}
