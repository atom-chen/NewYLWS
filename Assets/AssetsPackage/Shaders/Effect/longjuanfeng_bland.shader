// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge v1.05 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.05;sub:START;pass:START;ps:flbk:,lico:1,lgpr:1,nrmq:1,limd:1,uamb:True,mssp:True,lmpd:False,lprd:False,rprd:False,enco:False,frtr:True,vitr:True,dbil:False,rmgx:True,rpth:0,hqsc:True,hqlp:False,tesm:0,blpr:1,bsrc:3,bdst:7,culm:2,dpts:2,wrdp:True,dith:0,ufog:True,aust:True,igpj:False,qofs:0,qpre:2,rntp:3,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,ofsf:0,ofsu:0,f2p0:False;n:type:ShaderForge.SFN_Final,id:1719,x:34258,y:32775,varname:node_1719,prsc:2|emission-5248-OUT,clip-9813-OUT;n:type:ShaderForge.SFN_Tex2d,id:3919,x:32933,y:32585,ptovrint:False,ptlb:node_3919,ptin:_node_3919,varname:node_3919,prsc:2,tex:b84dcc065326c424899add9ff495b95a,ntxv:0,isnm:False|UVIN-2626-OUT;n:type:ShaderForge.SFN_Multiply,id:645,x:33271,y:32743,varname:node_645,prsc:2|A-3919-RGB,B-8896-OUT;n:type:ShaderForge.SFN_Slider,id:8896,x:32930,y:32908,ptovrint:False,ptlb:lingdu,ptin:_lingdu,varname:node_8896,prsc:2,min:0,cur:0,max:5;n:type:ShaderForge.SFN_TexCoord,id:1961,x:32221,y:33137,varname:node_1961,prsc:2,uv:0;n:type:ShaderForge.SFN_Panner,id:6902,x:32443,y:33137,varname:node_6902,prsc:2,spu:0,spv:-0.4|UVIN-1961-UVOUT;n:type:ShaderForge.SFN_Add,id:2626,x:32723,y:32585,varname:node_2626,prsc:2|A-4875-UVOUT,B-452-OUT;n:type:ShaderForge.SFN_TexCoord,id:6569,x:32190,y:32486,varname:node_6569,prsc:2,uv:0;n:type:ShaderForge.SFN_Tex2d,id:7420,x:32351,y:32707,ptovrint:False,ptlb:node_7420,ptin:_node_7420,varname:node_7420,prsc:2,tex:b84dcc065326c424899add9ff495b95a,ntxv:0,isnm:False|UVIN-4096-OUT;n:type:ShaderForge.SFN_Panner,id:4875,x:32420,y:32486,varname:node_4875,prsc:2,spu:0,spv:0.3|UVIN-6569-UVOUT;n:type:ShaderForge.SFN_Multiply,id:452,x:32672,y:32806,varname:node_452,prsc:2|A-7420-R,B-2624-OUT;n:type:ShaderForge.SFN_Color,id:893,x:33271,y:32951,ptovrint:False,ptlb:node_893,ptin:_node_893,varname:node_893,prsc:2,glob:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:4201,x:33604,y:32827,varname:node_4201,prsc:2|A-645-OUT,B-893-RGB;n:type:ShaderForge.SFN_Slider,id:2624,x:32101,y:33030,ptovrint:False,ptlb:node_2624,ptin:_node_2624,varname:node_2624,prsc:2,min:0,cur:0,max:10;n:type:ShaderForge.SFN_TexCoord,id:4758,x:31727,y:32622,varname:node_4758,prsc:2,uv:0;n:type:ShaderForge.SFN_Panner,id:9387,x:31935,y:32622,varname:node_9387,prsc:2,spu:0.1,spv:-0.3|UVIN-4758-UVOUT;n:type:ShaderForge.SFN_Tex2d,id:3522,x:32819,y:33150,ptovrint:False,ptlb:node_3522,ptin:_node_3522,varname:node_3522,prsc:2,ntxv:0,isnm:False|UVIN-3169-OUT;n:type:ShaderForge.SFN_Multiply,id:5734,x:33242,y:33204,varname:node_5734,prsc:2|A-3522-R,B-9322-OUT;n:type:ShaderForge.SFN_TexCoord,id:3965,x:31714,y:32825,varname:node_3965,prsc:2,uv:0;n:type:ShaderForge.SFN_Panner,id:6543,x:31935,y:32825,varname:node_6543,prsc:2,spu:0.1,spv:-0.5|UVIN-3965-UVOUT;n:type:ShaderForge.SFN_Slider,id:9322,x:32765,y:33468,ptovrint:False,ptlb:rongjie,ptin:_rongjie,varname:_lingdu_copy,prsc:2,min:0,cur:0,max:5;n:type:ShaderForge.SFN_Add,id:4096,x:32151,y:32752,varname:node_4096,prsc:2|A-9387-UVOUT,B-6543-UVOUT;n:type:ShaderForge.SFN_Multiply,id:3169,x:32642,y:33215,varname:node_3169,prsc:2|A-6902-UVOUT,B-3140-OUT;n:type:ShaderForge.SFN_Slider,id:3140,x:32249,y:33380,ptovrint:False,ptlb:UV,ptin:_UV,varname:node_3140,prsc:2,min:-6,cur:0,max:3;n:type:ShaderForge.SFN_Multiply,id:3363,x:33532,y:33150,varname:node_3363,prsc:2|A-893-A,B-5734-OUT;n:type:ShaderForge.SFN_Subtract,id:3568,x:33819,y:33218,varname:node_3568,prsc:2|A-3363-OUT,B-8020-OUT;n:type:ShaderForge.SFN_Slider,id:8020,x:33301,y:33458,ptovrint:False,ptlb:---,ptin:_,varname:node_8020,prsc:2,min:0,cur:0,max:1;n:type:ShaderForge.SFN_VertexColor,id:6300,x:33604,y:32970,varname:node_6300,prsc:2;n:type:ShaderForge.SFN_Multiply,id:5248,x:33957,y:32870,varname:node_5248,prsc:2|A-4201-OUT,B-6300-RGB;n:type:ShaderForge.SFN_Multiply,id:5124,x:34002,y:33153,varname:node_5124,prsc:2|A-6300-A,B-3568-OUT;n:type:ShaderForge.SFN_Multiply,id:9813,x:34091,y:33003,varname:node_9813,prsc:2|A-8896-OUT,B-5124-OUT;proporder:3919-8896-7420-893-2624-3522-9322-3140-8020;pass:END;sub:END;*/

Shader "Shader Forge/longjuanfeng_bland" {
    Properties {
        _node_3919 ("node_3919", 2D) = "white" {}
        _lingdu ("lingdu", Range(0, 5)) = 0
        _node_7420 ("node_7420", 2D) = "white" {}
        _node_893 ("node_893", Color) = (0.5,0.5,0.5,1)
        _node_2624 ("node_2624", Range(0, 10)) = 0
        _node_3522 ("node_3522", 2D) = "white" {}
        _rongjie ("rongjie", Range(0, 5)) = 0
        _UV ("UV", Range(-6, 3)) = 0
        _ ("---", Range(0, 1)) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "Queue"="AlphaTest"
            "RenderType"="TransparentCutout"
        }
        Pass {
            Name "ForwardBase"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            
            #pragma multi_compile_fwdbase_fullshadows
            #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
            #pragma target 3.0
            uniform float4 _TimeEditor;
            uniform sampler2D _node_3919; uniform float4 _node_3919_ST;
            uniform float _lingdu;
            uniform sampler2D _node_7420; uniform float4 _node_7420_ST;
            uniform float4 _node_893;
            uniform float _node_2624;
            uniform sampler2D _node_3522; uniform float4 _node_3522_ST;
            uniform float _rongjie;
            uniform float _UV;
            uniform float _;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
/////// Vectors:
                float4 node_8560 = _Time + _TimeEditor;
                float2 node_3169 = ((i.uv0+node_8560.g*float2(0,-0.4))*_UV);
                float4 _node_3522_var = tex2D(_node_3522,TRANSFORM_TEX(node_3169, _node_3522));
                clip((_lingdu*(i.vertexColor.a*((_node_893.a*(_node_3522_var.r*_rongjie))-_))) - 0.5);
////// Lighting:
////// Emissive:
                float2 node_4096 = ((i.uv0+node_8560.g*float2(0.1,-0.3))+(i.uv0+node_8560.g*float2(0.1,-0.5)));
                float4 _node_7420_var = tex2D(_node_7420,TRANSFORM_TEX(node_4096, _node_7420));
                float2 node_2626 = ((i.uv0+node_8560.g*float2(0,0.3))+(_node_7420_var.r*_node_2624));
                float4 _node_3919_var = tex2D(_node_3919,TRANSFORM_TEX(node_2626, _node_3919));
                float3 emissive = (((_node_3919_var.rgb*_lingdu)*_node_893.rgb)*i.vertexColor.rgb);
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
        Pass {
            Name "ShadowCollector"
            Tags {
                "LightMode"="ShadowCollector"
            }
            Cull Off
            
            Fog {Mode Off}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCOLLECTOR
            #define SHADOW_COLLECTOR_PASS
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcollector
            #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
            #pragma target 3.0
            uniform float4 _TimeEditor;
            uniform float _lingdu;
            uniform float4 _node_893;
            uniform sampler2D _node_3522; uniform float4 _node_3522_ST;
            uniform float _rongjie;
            uniform float _UV;
            uniform float _;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                V2F_SHADOW_COLLECTOR;
                float2 uv0 : TEXCOORD5;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos(v.vertex);
                TRANSFER_SHADOW_COLLECTOR(o)
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
/////// Vectors:
                float4 node_9472 = _Time + _TimeEditor;
                float2 node_3169 = ((i.uv0+node_9472.g*float2(0,-0.4))*_UV);
                float4 _node_3522_var = tex2D(_node_3522,TRANSFORM_TEX(node_3169, _node_3522));
                clip((_lingdu*(i.vertexColor.a*((_node_893.a*(_node_3522_var.r*_rongjie))-_))) - 0.5);
                SHADOW_COLLECTOR_FRAGMENT(i)
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Cull Off
            Offset 1, 1
            
            Fog {Mode Off}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
            #pragma target 3.0
            uniform float4 _TimeEditor;
            uniform float _lingdu;
            uniform float4 _node_893;
            uniform sampler2D _node_3522; uniform float4 _node_3522_ST;
            uniform float _rongjie;
            uniform float _UV;
            uniform float _;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float2 uv0 : TEXCOORD1;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos(v.vertex);
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
/////// Vectors:
                float4 node_1250 = _Time + _TimeEditor;
                float2 node_3169 = ((i.uv0+node_1250.g*float2(0,-0.4))*_UV);
                float4 _node_3522_var = tex2D(_node_3522,TRANSFORM_TEX(node_3169, _node_3522));
                clip((_lingdu*(i.vertexColor.a*((_node_893.a*(_node_3522_var.r*_rongjie))-_))) - 0.5);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
