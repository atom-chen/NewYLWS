Shader "Custom/ColorInvert"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white"{}
		_BlurAmount ("Blur Amount", Float) = 1.0
		_InvertAmount ("Invert Amount", Float) = 1.0
	}

	SubShader
	{
		Tags{"Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True"}
		ZWrite Off
        ZTest Always
        Cull Off

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			fixed _BlurAmount;
			fixed _InvertAmount;

			struct a2v
			{
				float4 vertex:POSITION;
				float2 texcoord:TEXCOORD;
			};

			struct v2f 
			{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}

			fixed4 frag(v2f i):SV_TARGET0
			{
				fixed4 c = tex2D(_MainTex, i.uv);
				fixed3 invertColor = fixed3(1-c.r, 1-c.g, 1-c.b);
				fixed3 finalInvertColor = lerp(c.rgb,invertColor, _InvertAmount);
				return fixed4(finalInvertColor, _BlurAmount);
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}