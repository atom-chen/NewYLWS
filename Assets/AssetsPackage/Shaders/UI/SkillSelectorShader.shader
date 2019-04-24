// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SkillSelectorShader" {
	Properties
	{
		//_MainTex ("Main Texture", 2D) = "white" {}
		_MainTex_Alpha ("Alpha Main Texture", 2D) = "black" {}
		_Color ("Color", Color) = (1,1,1,1)
		_GlossTexture ("Gloss Texture", 2D) = "white" {}
		_GlossColor ("Gloss Color", Color) = (1,1,1,1)
		_MovementX("MovementX",Range(0,2)) = 1
		_MovementY("MovementY",Range(0,2)) = 1
		_Power ("Power", Range(1, 3)) = 1
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent-100" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
		}
		
		Cull Off
		Lighting Off
		ZWrite Off
		ZTest Always
		Fog { Mode Off }

		
			Stencil
			{
				Ref 2
				Comp Greater
				// Pass IncrWrap
			}

		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _MainTex_Alpha;
			fixed4 _Color;
			sampler2D _GlossTexture;
			fixed4 _GlossColor;
			float _MovementX;
			float _MovementY;

			uniform float _Power;
			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				float2 texcoord  : TEXCOORD0;
				float2 texcoordGloss : TEXCOORD1;
			};

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.texcoordGloss = OUT.vertex.xy / OUT.vertex.w;
				return OUT;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				half4 color = _Color;// tex2D(_MainTex, IN.texcoord) * _Color;
				half4 colorA = tex2D(_MainTex_Alpha, IN.texcoord);
				color.a = colorA.a;
				half2 offset = IN.texcoordGloss+half2(_Time.x*_MovementX, _Time.x*_MovementY);
				half4 tex = tex2D (_GlossTexture,  offset)* _GlossColor;
				
				half4 finalColor = tex * tex.a + color * (1- tex.a);
				finalColor.rgb *= _Power;
				finalColor.a = color.a;
				//clip (finalColor.a - 0.01);
				return finalColor;
			}
		ENDCG
		}
	}
}
