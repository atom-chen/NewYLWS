Shader "DoubleSided/Standard/Transprent DS Alpha (Roughness setup)"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		_AlphaTex("AlbedoAlpha", 2D) = "white" {}

		_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

		_FluLightTex("FluLightTex" , 2D) = "white"{}
		_FluColor("FluColor" , color) = (1,1,1,1)
		_FluInterval("FluInterval", float) = 1.5
		_FluTime("FluTime", Range(1, 10)) = 2
		_FrontierRange("_FrontierRange" ,float) = 0.9
		_EffectMask("EffectMask", 2D) = "white"{}

		_Scale("RIM_SCALE", range(1, 50)) = 2
		_RimColor("RimColor", Color) = (1,1,1,1)
		
		_Glossiness("Roughness Range", Range(0.0, 1.0)) = 0.5
		_SpecGlossMap("Roughness Map", 2D) = "white" {}

		_Metallic("Metallic Range", Range(0.0, 1.0)) = 0.0
		_MetallicGlossMap("Metallic Map", 2D) = "white" {}

		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0

		_BumpScale("Normal Scale", Float) = 1.0
		_BumpMap("Normal Map", 2D) = "bump" {}

		_Parallax("Height Scale", Range(0.005, 0.08)) = 0.02
		_ParallaxMap("Height Map", 2D) = "black" {}

		_OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
		_OcclusionMap("Occlusion", 2D) = "white" {}

		_EmissionColor("Emission Color", Color) = (0,0,0)
		_EmissionMap("Emission Tex", 2D) = "white" {}

		_DetailMask("Detail Mask", 2D) = "white" {}

		_ShadowPlane2("Shadow Plane 2", Vector) = (0, 1, 0, 0)
		_ShadowHeight("ShadowHeight", Float) = 0

		// unused property
		[HideInInspector] [ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0
		[HideInInspector] _DetailAlbedoMap("Detail Albedo x2", 2D) = "grey" {}
		[HideInInspector] _DetailNormalMapScale("Detail Scale", Float) = 1.0
		[HideInInspector] _DetailNormalMap("Detail Normal Map", 2D) = "bump" {}
		[HideInInspector] [Enum(UV0,0,UV1,1)] _UVSec("UV Set for secondary textures", Float) = 0

		// Blending state
		[HideInInspector] _Mode("__mode", Float) = 0.0
		[HideInInspector] _SrcBlend("__src", Float) = 1.0
		[HideInInspector] _DstBlend("__dst", Float) = 0.0
		[HideInInspector] _ZWrite("__zw", Float) = 1.0
	}

	CGINCLUDE
		#define UNITY_SETUP_BRDF_INPUT RoughnessSetup
	ENDCG

	SubShader
	{
		Tags{ "Queue"="Geometry+100" "RenderType" = "Opaque" "PerformanceChecks" = "False" }
		LOD 300

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

				// float3 ld = float3(0.63,-0.76,0.13);

				float3 shadowpos = (worldPos - (((dot(planeDir, worldPos) - _ShadowHeight) / dot(planeDir, _LightDir)) * _LightDir));
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

		//  Base forward pass (directional light, emission, lightmaps, ...)
		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }
			// Blend[_SrcBlend][_DstBlend]
			// ZWrite On
            Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

			CGPROGRAM
		
			float _Scale;
			fixed4 _RimColor;
			sampler2D _FluLightTex;
			half4 _FluColor;
			float _FrontierRange;
			sampler2D _EffectMask;
			float _FluInterval;
			float _FluTime;
			sampler2D _AlphaTex;
			float4 _AlphaTex_ST;

			#pragma target 3.0

			// #define _ALPHATEST_ON 1
			#define _ALPHABLEND_ON 1
			#define _EMISSION 1
			#define _METALLICGLOSSMAP 1
			#define _NORMALMAP 1
			#define _SPECGLOSSMAP 1 

			#pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
			#pragma multi_compile_fwdbase

			#pragma vertex vertBase
			#pragma fragment fragBaseDS

			#include "PbrInclude/StandardDSCoreTransparentForwardAlpha.cginc"

			ENDCG
		}

		Pass{
			Tags{ "RenderType" = "Opaque" }
			Blend SrcAlpha One

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _FluLightTex;
			half4 _FluColor;
			float _FrontierRange;
			sampler2D _EffectMask;
			float _FluInterval;
			float _FluTime;
			float4 _FluLightTex_ST;
			float4 _EffectMask_ST;

			struct a2v {
				float4 vertex:POSITION;
				float2 texcoord:TEXCOORD;
				float3 normal:NORMAL;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD;
				float3 worldNormal:TEXCOORD1;
				float3 viewDir:TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _FluLightTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _EffectMask);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 viewDirForLight = UnityWorldSpaceViewDir(worldPos);
				o.viewDir = viewDirForLight;

				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldNormal = worldNormal;

				return o;
			}

			fixed4 frag(v2f i) :SV_TARGET0
			{
				fixed3 worldViewDir = normalize(i.viewDir);
				float NdotV = dot(i.worldNormal, worldViewDir);

				if (NdotV<_FrontierRange)
				{
					float2 fluUV = i.uv.xy;
					float total_interval = _FluTime + _FluInterval;
					int iTime =  _Time.y / total_interval;
					float curTime = _Time.y - total_interval * iTime;
					if (curTime < _FluTime)
					{
						fluUV += curTime / _FluTime;

						fixed3 c = _FluColor.rgb*lerp(0,1,(_FrontierRange - NdotV) / (1 - _FrontierRange));
						fixed4 flt= tex2D(_FluLightTex, fluUV);
						c *= flt.rgb;
						c *= tex2D(_EffectMask, i.uv.zw).rgb;
						return fixed4(c, flt.a);
					}
				}

				return fixed4(0, 0, 0, 1);
			}
			ENDCG
		}
	}

	FallBack "VertexLit"
	CustomEditor "CustomRoughnessShaderGUI"
}

