Shader "Custom/ScreenShotFX" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_ScreenShotTex ("ScreenShotTex (RGB)", 2D) = "white" {}
		_Alpha ("Alpha", Range(0.0,1.0)) = 1.0
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

			sampler2D _ScreenShotTex;
            float4 _ScreenShotTex_ST;
			float _Alpha;

            v2f vert(appdata v) {
                v2f o;
                o.pos = mul(UNITY_MATRIX_VP, v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _ScreenShotTex);
                return o;
            }
            fixed4 frag(v2f i) : COLOR {
				fixed4 col = tex2D(_ScreenShotTex, i.texcoord);
				col.a = _Alpha;// col.a * _Alpha;
                return col;
            }
            ENDCG
		}
	}
	FallBack "Diffuse"
}
