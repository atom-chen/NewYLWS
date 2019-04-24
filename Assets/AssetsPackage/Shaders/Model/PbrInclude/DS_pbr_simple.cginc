#ifndef DS_PBR_UTILS
#define DS_PBR_UTILS


#include "UnityStandardConfig.cginc"

#include "UnityStandardCoreForwardSimple.cginc"

half4 fragForwardBaseSimpleInternalDS(VertexOutputBaseSimple i, in float face : VFACE)
{
    UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

    FragmentCommonData s = FragmentSetupSimple(i);

    float _sign = sign(face);
    /// flip direction of normal based on sign of face
    float3 normal = s.normalWorld * _sign;
    s.normalWorld = normal;

    UnityLight mainLight = MainLightSimple(i, s);

#if !defined(LIGHTMAP_ON) && defined(_NORMALMAP)
    half ndotl = saturate(dot(s.tangentSpaceNormal, i.tangentSpaceLightDir));
#else
    half ndotl = saturate(dot(s.normalWorld, mainLight.dir));
#endif

    //we can't have worldpos here (not enough interpolator on SM 2.0) so no shadow fade in that case.
    half shadowMaskAttenuation = UnitySampleBakedOcclusion(i.ambientOrLightmapUV, 0);
    half realtimeShadowAttenuation = SHADOW_ATTENUATION(i);
    half atten = UnityMixRealtimeAndBakedShadows(realtimeShadowAttenuation, shadowMaskAttenuation, 0);

    half occlusion = Occlusion(i.tex.xy);
    half rl = dot(REFLECTVEC_FOR_SPECULAR(i, s), LightDirForSpecular(i, mainLight));

    UnityGI gi = FragmentGI(s, occlusion, i.ambientOrLightmapUV, atten, mainLight);
    half3 attenuatedLightColor = gi.light.color * ndotl;

    half3 c = BRDF3_Indirect(s.diffColor, s.specColor, gi.indirect, PerVertexGrazingTerm(i, s), PerVertexFresnelTerm(i));
    c += BRDF3DirectSimple(s.diffColor, s.specColor, s.smoothness, rl) * attenuatedLightColor;
    c += Emission(i.tex.xy);

    UNITY_APPLY_FOG(i.fogCoord, c);

    return OutputForward(half4(c, 1), s.alpha);
}

half4 fragForwardAddSimpleInternalDS(VertexOutputForwardAddSimple i, in float face : VFACE)
{
    UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

    FragmentCommonData s = FragmentSetupSimpleAdd(i);

    half3 c = BRDF3DirectSimple(s.diffColor, s.specColor, s.smoothness, dot(REFLECTVEC_FOR_SPECULAR(i, s), i.lightDir));

#if SPECULAR_HIGHLIGHTS // else diffColor has premultiplied light color
    c *= _LightColor0.rgb;
#endif

    UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld)
        c *= atten * saturate(dot(LightSpaceNormal(i, s), i.lightDir));

    // UNITY_APPLY_FOG_COLOR(i.fogCoord, c.rgb, half4(0, 0, 0, 0)); // fog towards black in additive pass
    return OutputForward(half4(c, 1), s.alpha);
}


	VertexOutputBaseSimple vertBase(VertexInput v) { return vertForwardBaseSimple(v); }
	VertexOutputForwardAddSimple vertAdd(VertexInput v) { return vertForwardAddSimple(v); }
	half4 fragBaseDS(VertexOutputBaseSimple i,in float face : VFACE) : SV_Target{ return fragForwardBaseSimpleInternalDS(i, face); }
	half4 fragAddDS(VertexOutputForwardAddSimple i, in float face : VFACE) : SV_Target{ return fragForwardAddSimpleInternalDS(i, face); }


#endif