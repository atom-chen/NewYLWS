// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/EyeVisionFX" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		//_EyeTex ("Eye (RGB)", 2D) = "white" {}
		_Alpha ("Alpha", Range(0.0,1.0)) = 1.0
		_Blur ("Blur", Range(0.0,1.0)) = 1.0
		_BlurTex ("BlurTex ", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		Pass { // Pass 0
			ZWrite Off
			Cull Off
			//ColorMask 0
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#include "UnityCG.cginc"
            struct appdata {
                float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
            };
            struct v2f {
                float4 pos : SV_POSITION;
				half2 texcoord : TEXCOORD0;
            };

			//sampler2D _EyeTex;
            //float4 _EyeTex_ST;
			float _Alpha;

            v2f vert(appdata v) {
                v2f o;
                o.pos = mul(UNITY_MATRIX_VP, v.vertex);
				o.texcoord = v.texcoord;
				//o.texcoord = TRANSFORM_TEX(v.texcoord, _EyeTex);
                return o;
            }
            fixed4 frag(v2f i) : COLOR {
				fixed4 col;// = tex2D(_EyeTex, i.texcoord);
				float x = i.texcoord.x - 0.5;
				float y = i.texcoord.y - 0.5;
				float r = x * x + y * y;
				if(r < 0.25)
				{
					col.a = 0;
				}
				else
				{
					col.a = 1;
				}
				//col.a = (1 - col.a) * _Alpha;
				col.rgb = 0;
                return col;
            }
            ENDCG
		}

		

		Pass { // Pass 1
			ZTest Always Cull Off
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			float _Alpha;

            struct appdata {
                float4 vertex : POSITION;
            };
            struct v2f {
                float4 pos : SV_POSITION;
            };
            v2f vert(appdata v) {
                v2f o;
                o.pos = mul(UNITY_MATRIX_VP, v.vertex);
                return o;
            }
            half4 frag(v2f i) : COLOR {
                return half4(0,0,0,_Alpha);
            }
            ENDCG
		}

		pass { // pass 2
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

					#if UNITY_UV_STARTS_AT_TOP
					if (_MainTex_TexelSize.y < 0)
						o.uv.y = 1-o.uv.y;
					#endif
		        	
		        	o.uv2[0] = o.uv + _MainTex_TexelSize.xy * half2(2, 2)  ;					
					o.uv2[1] = o.uv + _MainTex_TexelSize.xy * half2(-2, -2) ;
					o.uv2[2] = o.uv + _MainTex_TexelSize.xy * half2(2, -2) ;
					o.uv2[3] = o.uv + _MainTex_TexelSize.xy * half2(-2, 2) ;
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

		Pass { // Pass 3
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
				uniform sampler2D _BlurTex;
				float _Blur;
				
				fixed4 SimpleBlit (v2f_img i) : COLOR
				{				
					fixed4 colorA = tex2D(_MainTex, i.uv);
					fixed4 colorB = tex2D(_BlurTex, i.uv);
					fixed4 col = colorA *(1-_Blur) + colorB * _Blur;
					col.a = 1;
					return col;
				}			
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
