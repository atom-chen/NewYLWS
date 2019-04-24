// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "UI/FlowLightShader"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        _Angle ("Flash Angle", Range(0, 180)) = 45
        _Width ("Flash Width", Range(0, 1)) = 0.2
        _LoopTime ("Loop Time", Float) = 0.5
        _Interval ("Time Interval", Float) = 1.5

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile __ UNITY_UI_CLIP_RECT
            #pragma multi_compile __ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float4 flashcolor    : COLOR1;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
				fixed gray : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            float _Angle;
            float _Width;
            float _LoopTime;
            float _Interval;


            float inFlash(half2 uv)
            {   
                float brightness = 0;
                float angleInRad = 0.0174444 * _Angle;
                float tanInverseInRad = 1.0 / tan(angleInRad);
                float currentTime = _Time.y;
                float totalTime = _Interval + _LoopTime;
                float currentTurnStartTime = (int)((currentTime / totalTime)) * totalTime;
                float currentTurnTimePassed = currentTime - currentTurnStartTime - _Interval;
                bool onLeft = (tanInverseInRad > 0);
                float xBottomFarLeft = onLeft? 0.0 : tanInverseInRad;
                float xBottomFarRight = onLeft? (1.0 + tanInverseInRad) : 1.0;
                float percent = currentTurnTimePassed / _LoopTime;
                float xBottomRightBound = xBottomFarLeft + percent * (xBottomFarRight - xBottomFarLeft);
                float xBottomLeftBound = xBottomRightBound - _Width;
                float xProj = uv.x + uv.y * tanInverseInRad;
                
                if(xProj > xBottomLeftBound && xProj < xBottomRightBound)
                {
                    brightness = 1.0 - abs(2.0 * xProj - (xBottomLeftBound + xBottomRightBound)) / _Width;
                }

                return brightness;
            }

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

                // OUT.color = v.color * _Color;
                OUT.flashcolor = v.color;
				// OUT.gray = dot(v.color, fixed4(1,1,1,0));
                return OUT;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
			    half4 tmp_color = tex2D(_MainTex, IN.texcoord);
                half4 color = (tmp_color + _TextureSampleAdd) ; //* IN.color;

                float brightness = inFlash(IN.texcoord);
                color.rgb += IN.flashcolor.rgb * brightness;

                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif
				
				// if(IN.gray == 0)
				// {
				// 	float gray = dot(tmp_color.rgb, float3(0.299, 0.587, 0.114));
				// 	color.rgb = float3(gray, gray, gray);
				// } 

                return color;
            }
        ENDCG
        }
    }
}
