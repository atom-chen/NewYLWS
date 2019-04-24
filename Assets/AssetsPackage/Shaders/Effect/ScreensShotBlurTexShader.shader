// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ScreensShotBlurTexShader" {
Properties {
     _MainTex  ("Dont use this, Used by code", 2D) = "white" {}
	 _BlurTex1  ("xxx ", 2D) = "white" {}
	 _BlurTex2  ("xxx ", 2D) = "white" {}
	 _BlurTex3  ("xxx ", 2D) = "white" {}
	 }
SubShader {
	pass { // pass 0
		    name "SimpleBlur"
			ZTest Always Cull Off ZWrite Off
			Fog { Mode off }
			Blend Off
		
			CGPROGRAM
			
				#pragma vertex vertMax
				#pragma fragment fragMax
				#pragma fragmentoption ARB_precision_hint_fastest 
				//#pragma debug
				//#pragma only_renderers gles
				
				#include "UnityCG.cginc"
				
				uniform sampler2D _MainTex;
				uniform half4 _MainTex_TexelSize;
				
				struct v2f_withMaxCoords {
					half4 pos : SV_POSITION;
					half2 uv : TEXCOORD0;
					half2 uv2[4] : TEXCOORD1;
				};	
				
				v2f_withMaxCoords vertMax (appdata_img v)
				{
					v2f_withMaxCoords o;
					o.pos = UnityObjectToClipPos (v.vertex);
		        	o.uv = v.texcoord;
		        	
		        	o.uv2[0] = v.texcoord + _MainTex_TexelSize.xy * half2(1.5,1.5)  ;					
					o.uv2[1] = v.texcoord + _MainTex_TexelSize.xy * half2(-1.5,-1.5) ;
					o.uv2[2] = v.texcoord + _MainTex_TexelSize.xy * half2(1.5,-1.5) ;
					o.uv2[3] = v.texcoord + _MainTex_TexelSize.xy * half2(-1.5,1.5) ;
					return o;
				}	
	
				fixed4 fragMax ( v2f_withMaxCoords i ) : COLOR
				{				
					fixed4 color = 0;
					color += tex2D (_MainTex, i.uv ) * 0.4;	
					color += tex2D (_MainTex, i.uv2[0]) * 0.15;	
					color += tex2D (_MainTex, i.uv2[1]) * 0.15;	
					color += tex2D (_MainTex, i.uv2[2]) * 0.15;		
					color += tex2D (_MainTex, i.uv2[3]) * 0.15;	
					return color;
				}		
			ENDCG
		}

		pass { // pass 1
			name "FinalBlend"
			ZTest Always Cull Off ZWrite Off
			Fog { Mode off }
			Blend Off
		
			CGPROGRAM
			
				#pragma vertex vert_img
				#pragma fragment SimpleBlit
				#pragma fragmentoption ARB_precision_hint_fastest 
				
				//#pragma debug
				//#pragma only_renderers gles
				
				#include "UnityCG.cginc"
				
				uniform sampler2D _MainTex;
				uniform sampler2D _BlurTex1;
				uniform sampler2D _BlurTex2;
				uniform sampler2D _BlurTex3;
				
				fixed4 SimpleBlit (v2f_img i) : COLOR
				{				
					fixed4 colorA = tex2D(_MainTex, i.uv);
					fixed4 colorB = tex2D(_BlurTex1, i.uv);
					fixed4 colorC = tex2D(_BlurTex2, i.uv);
					fixed4 colorD = tex2D(_BlurTex3, i.uv);
					fixed4 col = colorA * 0.05 + colorB * 0.15 + colorC * 0.3 + colorD * 0.5;
					col *= 0.4;
					col.a = 1;
					return col;
				}			
			ENDCG
		}
	}	

	FallBack Off
}