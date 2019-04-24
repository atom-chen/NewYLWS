Shader "Custom/UIClip/ParticlesAdditiveCulled" {
	Properties{
		_TintColor("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex("Particle Texture", 2D) = "white" { }
		_ClipRegions("_ClipRegions", Vector) = (-10,-10,10,10)
	}
	SubShader{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Pass{
			Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
			ZWrite Off
			Blend SrcAlpha One
			ColorMask RGB
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			fixed4 _TintColor;
			float4 _MainTex_ST;
			float4 _ClipRegions;

			struct appdata {
				float3 pos : POSITION;
				half4 color : COLOR;
				float3 uv0 : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f {
				fixed4 color : COLOR0;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float4 pos : SV_POSITION;
				UNITY_VERTEX_OUTPUT_STEREO
				float3 vpos : TEXCOORD2;
			};

			v2f vert(appdata IN) {
				v2f o;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				half4 color = IN.color;
				half3 viewDir = 0.0;
				o.color = saturate(color);
				o.uv0 = IN.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv1 = IN.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.pos = UnityObjectToClipPos(IN.pos);
				o.vpos = mul(unity_ObjectToWorld, float4(IN.pos, 1)).xyz;
				return o;
			}

			fixed4 frag(v2f IN) : SV_Target{
				fixed4 col;
				fixed4 tex = tex2D(_MainTex, IN.uv0.xy);
				col = _TintColor * IN.color;
				tex = tex2D(_MainTex, IN.uv1.xy);
				col = tex * col;
				col *= 2;
				col.a *= (IN.vpos.x >= _ClipRegions.x);
				col.a *= (IN.vpos.x <= _ClipRegions.z);
				col.a *= (IN.vpos.y >= _ClipRegions.y);
				col.a *= (IN.vpos.y <= _ClipRegions.w);
				if (col.a <= 0.01) clip(-1);
				return col;
			}

			ENDCG
		}
	}
	SubShader{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Pass{
				Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
				ZWrite Off
				Blend SrcAlpha One
				ColorMask RGB
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0
				#include "UnityCG.cginc"

				sampler2D _MainTex;
				float4 _MainTex_ST;
				float4 _ClipRegions;

				struct appdata {
					float3 pos : POSITION;
					half4 color : COLOR;
					float3 uv0 : TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct v2f {
					fixed4 color : COLOR0;
					float2 uv0 : TEXCOORD0;
					float4 pos : SV_POSITION;
					UNITY_VERTEX_OUTPUT_STEREO
					float3 vpos : TEXCOORD2;
				};

				v2f vert(appdata IN) {
					v2f o;
					UNITY_SETUP_INSTANCE_ID(IN);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					half4 color = IN.color;
					half3 viewDir = 0.0;
					o.color = saturate(color);
					o.uv0 = IN.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
					o.pos = UnityObjectToClipPos(IN.pos);
					o.vpos = mul(unity_ObjectToWorld, float4(IN.pos, 1)).xyz;
					return o;
				}

				fixed4 frag(v2f IN) : SV_Target{
					fixed4 tex = tex2D(_MainTex, IN.uv0.xy);
					fixed4 c = tex * IN.color;
					c.a *= (IN.vpos.x >= _ClipRegions.x);
					c.a *= (IN.vpos.x <= _ClipRegions.z);
					c.a *= (IN.vpos.y >= _ClipRegions.y);
					c.a *= (IN.vpos.y <= _ClipRegions.w);
					if (c.a <= 0.01) clip(-1);
					return c;
				}
			ENDCG
		}
	}
}