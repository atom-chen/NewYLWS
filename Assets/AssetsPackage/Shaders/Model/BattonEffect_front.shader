Shader "BattonEffectfront"
{
	Properties 
	{
		_Color("Bar Color", Color) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "black" {}
		_Effect("Distortion Texture", 2D) = "black" {}
		_Mask("Cutoff Mask", 2D) = "black" {}
		_Distortion("Distortion Power", Float) = 0
		_Offset("Distortion Offset", Float) = 0
		_Speed("Scroll Speed", Float) = 0
		_Cutoff("Bar Cutoff", Range(0,1.5) ) = 0.5
		_AlphaPower("AlphaPower", Range(0.0,1.0)) = 1.0

	}
	
	SubShader 
	{
		Tags
		{
			"Queue"="Transparent+100"
			"IgnoreProjector"="False"
			"RenderType"="Transparent+100"

		}

	
		Cull off
		ZWrite On
		ZTest LEqual
		ColorMask RGB
		Fog{
			Mode Off
		}


		CGPROGRAM
		#pragma surface surf BlinnPhongEditor  noambient nolightmap alpha decal:blend vertex:vert
		#pragma target 2.0


		float4 _Color;
		sampler2D _MainTex;
		sampler2D _Effect;
		sampler2D _Mask;
		fixed _Distortion;
		fixed _Offset;
		fixed _Speed;
		fixed _Cutoff;
		uniform fixed _AlphaPower;

		struct EditorSurfaceOutput {
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half3 Gloss;
			half Specular;
			half Alpha;
			half4 Custom;
		};
		
		inline half4 LightingBlinnPhongEditor_PrePass (EditorSurfaceOutput s, half4 light)
		{
			half3 spec = light.a * s.Gloss;
			half4 c;
			c.rgb = (s.Albedo * light.rgb + light.rgb * spec);
			c.a = s.Alpha;
			return c;

		}

		inline half4 LightingBlinnPhongEditor (EditorSurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			half3 h = normalize (lightDir + viewDir);
			
			half diff = max (0, dot ( lightDir, s.Normal ));
			
			float nh = max (0, dot (s.Normal, h));
			float spec = pow (nh, s.Specular*128.0);
			
			half4 res;
			res.rgb = _LightColor0.rgb * diff;
			res.w = spec * Luminance (_LightColor0.rgb);
			res *= atten * 2.0;

			return LightingBlinnPhongEditor_PrePass( s, res );
		}

		struct Input {
			half2 uv_Effect;
			half2 uv_MainTex;
			fixed4 color : COLOR;
			half2 uv_Mask;

		};

		void vert (inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input, o);
		}
				

		void surf (Input IN, inout EditorSurfaceOutput o) {
			o.Normal = float3(0.0,0.0,1.0);
			o.Alpha = 1.0;
			o.Albedo = 0.0;
			o.Emission = 0.0;
			o.Gloss = 0.0;
			o.Specular = 0.0;
			o.Custom = 0.0;
			
			half4 Split0=(IN.uv_Effect.xyxy);
			half4 Multiply5=_Speed.xxxx * _Time;
			half4 Add2=half4( Split0.x, Split0.x, Split0.x, Split0.x) + Multiply5;
			half4 Assemble0=half4(Add2.x, float4( Split0.y, Split0.y, Split0.y, Split0.y).y, float4( Split0.z, Split0.z, Split0.z, Split0.z).z, float4( Split0.w, Split0.w, Split0.w, Split0.w).w);
			half4 Floor0=floor(Assemble0);
			half4 Subtract2=Assemble0 - Floor0;
			fixed4 Tex2D3=tex2D(_Effect,Subtract2.xy);
			fixed4 Multiply4=Tex2D3 * _Distortion.xxxx;
			half4 Add1=(IN.uv_Effect.xyxy) + Multiply4;
			half4 Multiply1=_Offset.xxxx * _Time;
			half4 Subtract1=Add1 - Multiply1;
			fixed4 Tex2D2=tex2D(_Effect,Subtract1.xy);
			fixed4 Sampled2D0=tex2D(_MainTex,IN.uv_MainTex.xy);
			fixed4 Add0=Tex2D2 + Sampled2D0;
			fixed4 Multiply0=_Color * Add0;
			fixed4 Multiply6=Multiply0 * IN.color;
			fixed4 SplatAlpha0=IN.color.w;
			fixed4 Sampled2D2=tex2D(_Mask,IN.uv_Mask.xy);
			fixed4 Split1=Sampled2D2;
			fixed4 Invert1= fixed4(1.0, 1.0, 1.0, 1.0) - fixed4( Split1.x, Split1.x, Split1.x, Split1.x);
			fixed4 Subtract3=_Cutoff.xxxx - Invert1;
			half4 Multiply3=Subtract3 * float4( 9,9,9,9 );
			half4 Multiply2=Sampled2D0.aaaa * Multiply3;
			half4 Multiply7=SplatAlpha0 * Multiply2;
			
			o.Emission = Multiply6;
			o.Alpha = Multiply7 * _AlphaPower;

			o.Normal = normalize(o.Normal);
		}
		ENDCG
	}
	Fallback "Diffuse"
}