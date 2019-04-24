Shader "Custom/SE_EyeBlink" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurAmount("BlurAmount", Range(0.0,100.0)) = 1.0
		_BlurTex ("BlurTex ", 2D) = "white" {}
		_BlinkX("_BlinkX", Range(0.5, 1)) = 0.5
		_BlinkY("_BlinkY", Range(0, 1)) = 0
	}
	SubShader{
		Tags { "RenderType" = "Opaque" }

		Pass {
			ZWrite Off
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			half4 _MainTex_TexelSize;
			float _BlinkX;
			float _BlinkY;
			float _BlurAmount;

			struct appdata {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};
			struct v2f {
				float4 pos : SV_POSITION;
				half2 uv[5] : TEXCOORD0;
			};

			v2f vert(appdata v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				half2 uv = v.texcoord;
				o.uv[0] = uv;
				o.uv[1] = uv + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurAmount;
				o.uv[2] = uv - float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurAmount;
				o.uv[3] = uv + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurAmount;
				o.uv[4] = uv - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurAmount;

				return o;
			}
			fixed4 frag(v2f i) : COLOR {
				fixed4 col;

				fixed3 sum = tex2D(_MainTex, i.uv[0]) * 0.4;
				sum += tex2D(_MainTex, i.uv[1]).rgb * 0.15;
				sum += tex2D(_MainTex, i.uv[2]).rgb * 0.15;
				sum += tex2D(_MainTex, i.uv[3]).rgb * 0.15;
				sum += tex2D(_MainTex, i.uv[4]).rgb * 0.15;
				col.rgb = sum;
				col.a = 1;

				if (_BlinkY == 0)
				{
					col.rgb = fixed3(0, 0, 0);
				}
				else
				{
					// 椭圆遮罩
					float x = i.uv[0].x - 0.5;
					float y = i.uv[0].y - 0.5;
					float r = (x*x) / _BlinkX + (y * y) / _BlinkY;
					if (r >= 0.25)
					{
						fixed t = 1 - smoothstep(0.0, 0.2, r - 0.25);
						fixed3 edgeColor = lerp(fixed3(0, 0, 0), col.rgb, t);
						col.rgb = edgeColor;
					}
				}
				return col;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
