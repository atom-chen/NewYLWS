// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/CloseUpFXMask" {
		Properties {
		_Color ("color", Color) = (0.0,0.0,0.0,0.95)
	}
	SubShader {
	Tags { "Queue" = "Background-999"}
		LOD 200

		Pass
		{
		ZWrite Off
		ZTest Off
		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
			#include "UnityCG.cginc"  
			#pragma vertex vert  
			#pragma fragment frag 

			half4 _Color;

		    struct appdata_t
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : POSITION;
			};

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				return o;
			}

			half4 frag(v2f i) :COLOR
			{ 
				return  _Color; 
			}
			ENDCG
			}
			}

	FallBack "Diffuse"
}
