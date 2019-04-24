Shader "Custom/FluColorFrontier" {
	Properties{
		//_MainTex("Base (RGB)", 2D) = "white" {}
		_FluLightTex("FluLightTex" , 2D) = "white"{}
		_FluColor("FluColor" , color) = (1,1,1,1)
		_FluInterval("FluInterval", float) = 1.5
		_FluTime("FluTime", Range(1, 10)) = 2
		_FrontierRange("_FrontierRange" ,float) = 0.9
		_EffectMask("EffectMask", 2D) = "white"{}
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		Blend SrcAlpha One

		CGPROGRAM
		#pragma surface surf Lambert   

		//sampler2D _MainTex;
		sampler2D _FluLightTex;
		half4 _FluColor;
		float _FrontierRange;
		sampler2D _EffectMask;
		float _FluInterval;
		float _FluTime;

		struct Input {
			//float2 uv_MainTex;
			float2 uv_FluLightTex;
			float3 viewDir;
			float2 uv_EffectMask;
		};

		void surf(Input IN, inout SurfaceOutput o) {
			//half4 c = tex2D(_MainTex, IN.uv_MainTex);
			//o.Albedo = c.rgb;
			//o.Alpha = c.a;
			IN.viewDir = normalize(IN.viewDir);
			//  o.Normal = normalize(o.Normal);  
			float NdotV = dot(o.Normal , IN.viewDir);
			if (NdotV<_FrontierRange)
			{
				float2 fluUV = IN.uv_FluLightTex;
				float total_interval = _FluTime + _FluInterval;
				int iTime =  _Time.y / total_interval;
				float curTime = _Time.y - total_interval * iTime;
				if (curTime < _FluTime)
				{
					fluUV += curTime / _FluTime;
				}

				o.Emission = _FluColor.rgb*lerp(0,1,(_FrontierRange - NdotV) / (1 - _FrontierRange));
				o.Emission *= tex2D(_FluLightTex, fluUV);
				o.Emission *= tex2D(_EffectMask, IN.uv_EffectMask);
			}
		}
		ENDCG
		}
		FallBack "Diffuse"
}