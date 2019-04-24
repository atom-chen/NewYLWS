Shader "Custom/UIClip/ParticleAdditive" {
	Properties {
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_Direction ("Texture move direction", Vector) = (0,0,-0,-0)
		_ClipRegions("_ClipRegions", Vector) = (-10, -10, 10, 10)
	}

	Category {
		Tags { "Queue"="Transparent+40" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend SrcAlpha One
		Cull Off 
		Lighting Off 
		ZWrite Off 
		Fog { Mode Off }
	
		SubShader {
			Pass {
		
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest

				#include "UnityCG.cginc"

				sampler2D _MainTex;
				fixed4 _TintColor;
				half4 _Direction;
				float4 _ClipRegions;

				struct appdata_t {
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
				};

				struct v2f {
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					float3 vpos : TEXCOORD1;
				};
			
				float4 _MainTex_ST;

				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.vpos = mul(unity_ObjectToWorld, v.vertex).xyz;
					o.color = v.color;
					o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
					return o;
				}
				fixed4 frag (v2f i) : COLOR
				{
					fixed4 tex = tex2D(_MainTex, i.texcoord + _Time.x * _Direction.xy);
					fixed4 tex2 = tex2D(_MainTex, i.texcoord + _Time.x * _Direction.zw);
					fixed4 c = 2.0f * i.color * _TintColor * tex * tex2;
					c.a *= (i.vpos.x >= _ClipRegions.x);
					c.a *= (i.vpos.x <= _ClipRegions.z);
					c.a *= (i.vpos.y >= _ClipRegions.y);
					c.a *= (i.vpos.y <= _ClipRegions.w);
					clip(c.a);

					return c;
				}
				ENDCG 
			}
		}	
	}
}