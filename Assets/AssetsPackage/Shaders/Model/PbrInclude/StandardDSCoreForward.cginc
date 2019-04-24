
#ifndef UNITY_STANDARD_CORE_FORWARD_INCLUDED
#define UNITY_STANDARD_CORE_FORWARD_INCLUDED

#if defined(UNITY_NO_FULL_STANDARD_SHADER)
#   define UNITY_STANDARD_SIMPLE 1
#endif

#include "UnityStandardConfig.cginc"


#if UNITY_STANDARD_SIMPLE
	#include "DS_pbr_simple.cginc"
#else

	// #include "UnityStandardCore.cginc" 
	#include "DS_pbr.cginc"
	
	half4 fragOpaqueDS(VertexOutputDS i, in float face : VFACE)
	{
		UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

		// FRAGMENT_SETUP(s)

		FragmentCommonData s = DS_FragmentSetup(i.tex, i.eyeVec, IN_VIEWDIR4PARALLAX(i), i.tangentToWorldAndPackedData, IN_WORLDPOS(i));

		float _sign = sign(face);
		/// flip direction of normal based on sign of face
		float3 normal = s.normalWorld * _sign;
		s.normalWorld = normal;

		UNITY_SETUP_INSTANCE_ID(i);
		UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

		UnityLight mainLight = MainLight();
		UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld);

		half occlusion = DS_Occlusion(i.tex.xy);
		UnityGI gi = DS_FragmentGI(s, occlusion, i.ambientOrLightmapUV, atten, mainLight, false);

		float3 worldViewDir = -s.eyeVec;

		half4 c = BRDF2_Unity_PBS(s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, worldViewDir, gi.light, gi.indirect);
		
		float3 emission = Emission(i.tex.xy);	//tex2D(_EmissionMap, i.tex.xy).rgb * _EmissionColor.rgb;//
		c.rgb += emission;

		float4 final = OutputForward(c, s.alpha);
		
		float NdotV = dot(normal, worldViewDir);

		float bright = 1 - saturate(max(0, NdotV));
		float4 rim = pow(bright, _Scale) * _RimColor * 0.25; 
		final += rim;

		return final;
	}


	VertexOutputForwardAdd vertAdd(VertexInput v) { return vertForwardAdd(v); }
	half4 fragBaseDS(VertexOutputDS i, in float face : VFACE) : SV_Target{ return fragOpaqueDS(i, face); }
	half4 fragAddDS(VertexOutputForwardAdd i, in float face : VFACE) : SV_Target{ return fragForwardAddInternal(i); }

#endif //UNITY_STANDARD_SIMPLE

#endif // UNITY_STANDARD_CORE_FORWARD_INCLUDED