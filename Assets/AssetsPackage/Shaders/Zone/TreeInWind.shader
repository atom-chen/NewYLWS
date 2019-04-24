// Shader "Custom/TreeInWind" {
// 	Properties {
// 		_Color ("Main Color", Color) = (1,1,1,1)
// 		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
// 		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5

// 		_NormalSpeed ("Normal Speed", Float) = 100.0
// 		_NormalScope ("Normal Scope", Float) = 0.01
// 		_TangentSpeed ("Tangent Speed", Float) = 100.0
// 		_TangentScope ("Tangent Scope", Float) = 0.03
		
// 		_Smoothness ("Smoothness", Range(0,1)) = 0.2
// 		_Metallic ("Metallic", Range(0,1)) = 0.2
// 	}

// 	SubShader {
// 		Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
// 		LOD 200
	
// 		CGPROGRAM
// 		#pragma surface surf Standard alphatest:_Cutoff vertex:vert

// 		sampler2D _MainTex;
// 		fixed4 _Color;

// 		fixed _NormalSpeed;
// 		fixed _NormalScope;
// 		fixed _TangentSpeed;
// 		fixed _TangentScope;
// 	    half _Smoothness;
// 	    half _Metallic;

// 		struct Input {
// 			float2 uv_MainTex;
// 		};
		
// 		void vert (inout appdata_full v) {
// 			v.vertex.xyz += v.normal * sin(_Time.x * _NormalSpeed * v.normal.x ) * _NormalScope;// 乘以v.normal.x是为了让每个顶点的运动不统一
// 			v.vertex.xyz += v.tangent * sin(_Time.x * _TangentSpeed * v.normal.x) * _TangentScope;// 乘以v.normal.x是为了让每个顶点的运动不统一
// 		}
		
// 		void surf (Input IN, inout SurfaceOutputStandard o) {
// 			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
// 			o.Albedo = c.rgb;
// 			o.Alpha = c.a;
// 			o.Smoothness = _Smoothness;
// 			o.Metallic = _Metallic;
// 		}

// 		ENDCG
// 	}

// 	Fallback "Transparent/Cutout/VertexLit"
// }


Shader "Custom/TreeInWind" {
Properties {
    _Color ("Main Color", Color) = (1,1,1,1)
    _SpecColor ("Spec Color", Color) = (1,1,1,0)
    _Emission ("Emissive Color", Color) = (0,0,0,0)
    _Shininess ("Shininess", Range (0.1, 1)) = 0.7
    _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
    _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5

	_NormalSpeed ("Normal Speed", Float) = 100.0
	_NormalScope ("Normal Scope", Float) = 0.01
	_TangentSpeed ("Tangent Speed", Float) = 100.0
	_TangentScope ("Tangent Scope", Float) = 0.03
	
}

SubShader {
    Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
    LOD 100

    // Non-lightmapped
    Pass {
        Tags { "LightMode" = "Vertex" }
        
        AlphaToMask On
        ColorMask RGB

        CGPROGRAM

        #pragma vertex vert
        #pragma fragment frag
        #pragma target 2.0
        #include "UnityCG.cginc"
        #pragma multi_compile_fog
        #define USING_FOG (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))

        float4 unity_Lightmap_ST;
        float4 _MainTex_ST;

		fixed _NormalSpeed;
		fixed _NormalScope;
		fixed _TangentSpeed;
		fixed _TangentScope;
	    half _Smoothness;
	    half _Metallic;

        struct appdata
        {
            float3 pos : POSITION;
            half4 color : COLOR;
            float3 uv1 : TEXCOORD1;
            float3 uv0 : TEXCOORD0;
    		float3 normal    : NORMAL;
			float3 tangent   : TANGENT;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct v2f
        {
            fixed4 color : COLOR0;
            float2 uv : TEXCOORD2;
#if USING_FOG
            fixed fog : TEXCOORD3;
#endif
            float4 pos : SV_POSITION;
            UNITY_VERTEX_OUTPUT_STEREO
        };

        v2f vert(appdata IN)
        {
            v2f o;
            UNITY_SETUP_INSTANCE_ID(IN);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
            half4 color = IN.color;
            float3 eyePos = UnityObjectToViewPos(IN.pos);
            half3 viewDir = 0.0;
            o.color = saturate(color);

            o.uv = IN.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;

#if USING_FOG
            float fogCoord = length(eyePos.xyz);
            UNITY_CALC_FOG_FACTOR_RAW(fogCoord);
            o.fog = saturate(unityFogFactor);
#endif
			
			float3 vPos = IN.pos;
			vPos.xyz += IN.normal * sin(_Time.x * _NormalSpeed * IN.normal.x ) * _NormalScope;			// 乘以v.normal.x是为了让每个顶点的运动不统一
			vPos.xyz += IN.tangent * sin(_Time.x * _TangentSpeed * IN.normal.x) * _TangentScope;		// 乘以v.normal.x是为了让每个顶点的运动不统一
		
            o.pos = UnityObjectToClipPos(vPos);
            return o;
        }

        sampler2D _MainTex;
        fixed4 _Color;
        fixed _Cutoff;

        fixed4 frag(v2f IN) : SV_Target
        {
            fixed4 col = _Color;

            fixed4 tex = tex2D(_MainTex, IN.uv.xy);

            col.rgb = tex.rgb * col.rgb;
            col.a = tex.a * IN.color.a;

            clip(col.a - _Cutoff);

#if USING_FOG
            col.rgb = lerp(unity_FogColor.rgb, col.rgb, IN.fog);
#endif
            return col;
        }

        ENDCG
    }

    // Lightmapped
    Pass
    {
        Tags{ "LIGHTMODE" = "VertexLM" "QUEUE" = "AlphaTest" "IGNOREPROJECTOR" = "true" "RenderType" = "TransparentCutout" }
        AlphaToMask On
        ColorMask RGB

        CGPROGRAM

        #pragma vertex vert
        #pragma fragment frag
        #pragma target 2.0
        #include "UnityCG.cginc"
        #pragma multi_compile_fog
        #define USING_FOG (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))

        float4 unity_Lightmap_ST;
        float4 _MainTex_ST;

		fixed _NormalSpeed;
		fixed _NormalScope;
		fixed _TangentSpeed;
		fixed _TangentScope;
	    half _Smoothness;
	    half _Metallic;

        struct appdata
        {
            float3 pos : POSITION;
            half4 color : COLOR;
            float3 uv1 : TEXCOORD1;
            float3 uv0 : TEXCOORD0;
    		float3 normal    : NORMAL;
			float3 tangent   : TANGENT;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct v2f
        {
            fixed4 color : COLOR0;
            float2 uv0 : TEXCOORD0;
            float2 uv1 : TEXCOORD1;
            float2 uv2 : TEXCOORD2;
#if USING_FOG
            fixed fog : TEXCOORD3;
#endif
            float4 pos : SV_POSITION;
            UNITY_VERTEX_OUTPUT_STEREO
        };

        v2f vert(appdata IN)
        {
            v2f o;
            UNITY_SETUP_INSTANCE_ID(IN);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
            half4 color = IN.color;
            float3 eyePos = UnityObjectToViewPos(IN.pos);
            half3 viewDir = 0.0;
            o.color = saturate(color);

            o.uv0 = IN.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
            o.uv1 = IN.uv1.xy * unity_Lightmap_ST.xy + unity_Lightmap_ST.zw;
            o.uv2 = IN.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;

#if USING_FOG
            float fogCoord = length(eyePos.xyz);
            UNITY_CALC_FOG_FACTOR_RAW(fogCoord);
            o.fog = saturate(unityFogFactor);
#endif
			
			float3 vPos = IN.pos;
			vPos.xyz += IN.normal * sin(_Time.x * _NormalSpeed * IN.normal.x ) * _NormalScope;			// 乘以v.normal.x是为了让每个顶点的运动不统一
			vPos.xyz += IN.tangent * sin(_Time.x * _TangentSpeed * IN.normal.x) * _TangentScope;		// 乘以v.normal.x是为了让每个顶点的运动不统一
		
            o.pos = UnityObjectToClipPos(vPos);
            return o;
        }

        sampler2D _MainTex;
        fixed4 _Color;
        fixed _Cutoff;

        fixed4 frag(v2f IN) : SV_Target
        {
            half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, IN.uv0.xy);
            half4 bakedColor = half4(DecodeLightmap(bakedColorTex), 1.0);

            fixed4 col = bakedColor * _Color;

            fixed4 tex = tex2D(_MainTex, IN.uv2.xy);

            col.rgb = tex.rgb * col.rgb;
            col.a = tex.a * IN.color.a;

            clip(col.a - _Cutoff);

#if USING_FOG
            col.rgb = lerp(unity_FogColor.rgb, col.rgb, IN.fog);
#endif
            return col;
        }

        ENDCG
    }

    // Pass to render object as a shadow caster
    Pass {
        Name "Caster"
        Tags { "LightMode" = "ShadowCaster" }

CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma target 2.0
#pragma multi_compile_shadowcaster
#pragma multi_compile_instancing // allow instanced shadow pass for most of the shaders
#include "UnityCG.cginc"

struct v2f {
    V2F_SHADOW_CASTER;
    float2  uv : TEXCOORD1;
    UNITY_VERTEX_OUTPUT_STEREO
};

uniform float4 _MainTex_ST;

v2f vert( appdata_base v )
{
    v2f o;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
    return o;
}

uniform sampler2D _MainTex;
uniform fixed _Cutoff;
uniform fixed4 _Color;

float4 frag( v2f i ) : SV_Target
{
    fixed4 texcol = tex2D( _MainTex, i.uv );
    clip( texcol.a*_Color.a - _Cutoff );

    SHADOW_CASTER_FRAGMENT(i)
}
ENDCG

    }

}

}
