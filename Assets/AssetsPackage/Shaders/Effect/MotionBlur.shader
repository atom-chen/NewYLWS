Shader "Custom/MotionBlur"
{
	Properties
    {
       _MainTex ("Main Texture", 2D) = "white" {}
       _BlurAmount ("Blur Amount", Range(0,1)) = 0.5
    }
	
	
	SubShader
    {
         ZWrite Off
         ZTest Always
         Cull Off
 
         Pass
         {
             Blend SrcAlpha OneMinusSrcAlpha
 
             CGPROGRAM
             #pragma vertex vert
             #pragma fragment frag
			 
            sampler2D _MainTex;
             fixed _BlurAmount;

             struct appdata
             {
                 float4 vertex : POSITION;
                 float2 uv : TEXCOORD0;
             };
 
             struct v2f
             {
                 float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
             };
 
             v2f vert(appdata v)
             {
                 v2f o;
                 o.pos = UnityObjectToClipPos(v.vertex);
                 o.uv = v.uv;
                 return o;
             }
 
             fixed4 frag(v2f i) : SV_TARGET
             {
                fixed4 tex = tex2D(_MainTex, i.uv);
                return fixed4(tex.rgb, _BlurAmount);
             }
 
             ENDCG
         }
     }
 
     Fallback Off
	
}