// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/LightningMask" {
	Properties
	{
		_R ("_R", float) = 0
        _G ("_G", float) = 0
        _B ("_B", float) = 0
        _Alpha ("_Alpha", float) = 0
	}
	
	SubShader
	{		
		Pass
		{
			ZTest Always Cull Off ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha 
            Color([_R],[_G],[_B],[_Alpha])
		}
	}
}
