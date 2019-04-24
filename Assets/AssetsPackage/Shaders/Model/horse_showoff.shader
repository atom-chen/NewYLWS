// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/horse_showoff" {
    Properties {
        _Texture ("Texture", 2D) = "white" {}
		//_Texture_Alpha ("Texture", 2D) = "white" {}
        _power ("power", Range(1, 2)) = 1
		_AlphaPower("AlphaPower", Range(0.0,1.0)) = 1.0
		_EffectColor("EffectColor", Color) = (0,0,0,0)
		_MatCap("MatCapTex", 2D) = "white" {}
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5

		_ShadowPlane2("Shadow Plane 2", Vector) = (0, 1, 0, 0)
		_ShadowHeight("ShadowHeight", Float) = 0
		_ClipRegions("_ClipRegions", Vector) = (-10000, 0, 0, 0)
    }
    SubShader {
        Tags {
            "Queue"="Geometry+500"
            "RenderType"="TransparentCutout"
        }

        Pass {
            Name "ForwardBase"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
			Offset 0, 0
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
            #pragma target 3.0
            uniform sampler2D _Texture; uniform float4 _Texture_ST;
			//uniform sampler2D _Texture_Alpha; uniform float4 _Texture_Alpha_ST;
            uniform fixed _power;
			
			uniform fixed _AlphaPower;
			uniform fixed4 _EffectColor;

			uniform sampler2D _MatCap;
			uniform float4 _MatCap_ST;

			uniform sampler2D _SceneMatcap;
			uniform float4 _SceneMatcap_ST;

			uniform float4 _LightDir;			// xyz for light dir, w for scene power

			float4 _ClipRegions;

            struct VertexInput {
                half4 vertex : POSITION;
				half3 normal : NORMAL;
                half2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                half4 pos : SV_POSITION;
                half2 uv0 : TEXCOORD0;
				half2 cap : TEXCOORD1;
				float3 vpos : TEXCOORD2;
            };

            VertexOutput vert (VertexInput v) {
                VertexOutput o;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos(v.vertex);
				o.vpos = mul(unity_ObjectToWorld, v.vertex).xyz;

				half2 capCoord;
				capCoord.x = dot(UNITY_MATRIX_IT_MV[0].xyz, v.normal);
				capCoord.y = dot(UNITY_MATRIX_IT_MV[1].xyz, v.normal);
				o.cap = capCoord * 0.5 + 0.5;
				
                return o;
            }

            fixed4 frag(VertexOutput i) : COLOR {
                fixed4 node = tex2D(_Texture,TRANSFORM_TEX(i.uv0, _Texture));
				//fixed4 node_a = tex2D(_Texture_Alpha,TRANSFORM_TEX(i.uv0, _Texture_Alpha));
				//node.a *= node_a.a;
                clip(node.a - 0.3);
////// Lighting:
				float scenePower = _LightDir.w * 10;
				scenePower = lerp(scenePower, 1, step(scenePower, 0));	// if (scenePower <= 0) { 	scenePower = 1; }

                fixed3 finalColor = (node.rgb * _power * scenePower);

				fixed4 mc = tex2D(_SceneMatcap, i.cap);
				mc = lerp(mc, 1, step(mc, 0));
				finalColor = finalColor * (mc * 1.2);
/// Final Color:
				finalColor = finalColor * (1 - _EffectColor.a) + _EffectColor.rgb * _EffectColor.a;
				fixed4 c = fixed4(finalColor, node.a * _AlphaPower);

				if (_ClipRegions.x > -5000)
				{
					c.a *= (i.vpos.x >= _ClipRegions.x);
					c.a *= (i.vpos.x <= _ClipRegions.z);
					c.a *= (i.vpos.y >= _ClipRegions.y);
					c.a *= (i.vpos.y <= _ClipRegions.w);
					clip(c.a);
				}

				return c;
            }
            ENDCG
        }

		Pass
		{
			Name "PLANESHADOW"

			Cull Back
			Lighting Off
			ZWrite Off
			//ZTest On
			Fog{ Mode Off }

				Stencil
			{
				Comp Equal
				Pass IncrWrap
			}

			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 pos : POSITION;
			};

			float4 _ShadowPlane2;
			uniform float4 _LightDir;			// xyz for light dir, w for scene power
			float _ShadowHeight;
			uniform float4 _ShadowColor;

			v2f vert(a2v v)
			{
				v2f o;
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 planeDir = normalize(_ShadowPlane2.xyz); 
				float3 shadowpos = (worldPos - (((dot(planeDir, worldPos) - _ShadowHeight) / dot(planeDir, _LightDir.xyz)) * _LightDir.xyz));
				//float4 pos = (worldPos.y >= _ShadowPlane2.w) ? float4(shadowpos, 1.0) : float4(worldPos, 1.0);
				float4 pos = float4(shadowpos, 1.0);

				o.pos = mul(UNITY_MATRIX_VP, pos);
				return o;
			}

			float4 frag(v2f IN) : COLOR
			{
				return _ShadowColor;
			//_ShadowColor;
			}

			ENDCG
		}


		// Pass to render object as a shadow caster
		Pass {
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }
            Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile_instancing // allow instanced shadow pass for most of the shaders
			#include "UnityCG.cginc"

			struct v2f {
				V2F_SHADOW_CASTER;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			v2f vert( appdata_base v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}

			float4 frag( v2f i ) : SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG

		}

    }
    FallBack "Diffuse"
}
