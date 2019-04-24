// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge v1.05 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.05;sub:START;pass:START;ps:flbk:,lico:1,lgpr:1,nrmq:1,limd:1,uamb:True,mssp:True,lmpd:False,lprd:False,rprd:False,enco:False,frtr:True,vitr:True,dbil:False,rmgx:True,rpth:0,hqsc:True,hqlp:False,tesm:0,blpr:1,bsrc:3,bdst:7,culm:2,dpts:2,wrdp:False,dith:0,ufog:True,aust:False,igpj:True,qofs:10,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,ofsf:0,ofsu:0,f2p0:False;n:type:ShaderForge.SFN_Final,id:1719,x:34252,y:32720,varname:node_1719,prsc:2|emission-6153-OUT,alpha-9807-OUT;n:type:ShaderForge.SFN_Tex2d,id:3919,x:32933,y:32585,ptovrint:False,ptlb:node_3919,ptin:_node_3919,varname:node_3919,prsc:2,tex:b84dcc065326c424899add9ff495b95a,ntxv:0,isnm:False|UVIN-2626-OUT;n:type:ShaderForge.SFN_Multiply,id:645,x:33271,y:32746,varname:node_645,prsc:2|A-3919-RGB,B-8896-OUT;n:type:ShaderForge.SFN_Slider,id:8896,x:32930,y:32908,ptovrint:False,ptlb:lingdu,ptin:_lingdu,varname:node_8896,prsc:2,min:0,cur:0,max:20;n:type:ShaderForge.SFN_TexCoord,id:1961,x:32279,y:33170,varname:node_1961,prsc:2,uv:0;n:type:ShaderForge.SFN_Panner,id:6902,x:32540,y:33183,varname:node_6902,prsc:2,spu:0,spv:-0.2|UVIN-1961-UVOUT;n:type:ShaderForge.SFN_Add,id:2626,x:32723,y:32585,varname:node_2626,prsc:2|A-4875-UVOUT,B-452-OUT;n:type:ShaderForge.SFN_TexCoord,id:6569,x:32190,y:32486,varname:node_6569,prsc:2,uv:0;n:type:ShaderForge.SFN_Tex2d,id:7420,x:32351,y:32707,ptovrint:False,ptlb:node_7420,ptin:_node_7420,varname:node_7420,prsc:2,tex:b84dcc065326c424899add9ff495b95a,ntxv:0,isnm:False|UVIN-4096-OUT;n:type:ShaderForge.SFN_Panner,id:4875,x:32420,y:32486,varname:node_4875,prsc:2,spu:0,spv:-0.3|UVIN-6569-UVOUT;n:type:ShaderForge.SFN_Multiply,id:452,x:32672,y:32806,varname:node_452,prsc:2|A-7420-R,B-2624-OUT;n:type:ShaderForge.SFN_Color,id:893,x:33271,y:32951,ptovrint:False,ptlb:node_893,ptin:_node_893,varname:node_893,prsc:2,glob:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:4201,x:33604,y:32827,varname:node_4201,prsc:2|A-645-OUT,B-893-RGB;n:type:ShaderForge.SFN_Slider,id:2624,x:32060,y:32975,ptovrint:False,ptlb:node_2624,ptin:_node_2624,varname:node_2624,prsc:2,min:0,cur:0,max:3;n:type:ShaderForge.SFN_TexCoord,id:4758,x:31727,y:32622,varname:node_4758,prsc:2,uv:0;n:type:ShaderForge.SFN_Panner,id:9387,x:31935,y:32622,varname:node_9387,prsc:2,spu:0.1,spv:-0.2|UVIN-4758-UVOUT;n:type:ShaderForge.SFN_Tex2d,id:3522,x:32819,y:33150,ptovrint:False,ptlb:node_3522,ptin:_node_3522,varname:node_3522,prsc:2,ntxv:0,isnm:False|UVIN-6902-UVOUT;n:type:ShaderForge.SFN_Multiply,id:5734,x:33242,y:33204,varname:node_5734,prsc:2|A-3522-R,B-9322-OUT;n:type:ShaderForge.SFN_TexCoord,id:3965,x:31749,y:32797,varname:node_3965,prsc:2,uv:0;n:type:ShaderForge.SFN_Panner,id:6543,x:31935,y:32825,varname:node_6543,prsc:2,spu:0.1,spv:-0.2|UVIN-3965-UVOUT;n:type:ShaderForge.SFN_Slider,id:9322,x:32679,y:33405,ptovrint:False,ptlb:rongjie,ptin:_rongjie,varname:_lingdu_copy,prsc:2,min:0,cur:0,max:20;n:type:ShaderForge.SFN_Add,id:4096,x:32151,y:32752,varname:node_4096,prsc:2|A-9387-UVOUT,B-6543-UVOUT;n:type:ShaderForge.SFN_Subtract,id:2,x:33520,y:33239,varname:node_2,prsc:2|A-5734-OUT,B-8317-OUT;n:type:ShaderForge.SFN_Slider,id:8317,x:33046,y:33442,ptovrint:False,ptlb:node_8317,ptin:_node_8317,varname:node_8317,prsc:2,min:0,cur:0,max:1;n:type:ShaderForge.SFN_VertexColor,id:150,x:33578,y:33033,varname:node_150,prsc:2;n:type:ShaderForge.SFN_Multiply,id:6153,x:33952,y:32759,varname:node_6153,prsc:2|A-150-RGB,B-4201-OUT,C-150-A;n:type:ShaderForge.SFN_Multiply,id:9807,x:33921,y:33093,varname:node_9807,prsc:2|A-150-A,B-2-OUT;proporder:3919-8896-7420-893-2624-3522-9322-8317;pass:END;sub:END;*/

Shader "Shader Forge/longjuanfeng_add2" {
    Properties {
        _node_3919 ("node_3919", 2D) = "white" {}
        _lingdu ("lingdu", Range(0, 20)) = 0
        _node_7420 ("node_7420", 2D) = "white" {}
        _node_893 ("node_893", Color) = (0.5,0.5,0.5,1)
        _node_2624 ("node_2624", Range(0, 3)) = 0
        _node_3522 ("node_3522", 2D) = "white" {}
        _rongjie ("rongjie", Range(0, 20)) = 0
        _node_8317 ("node_8317", Range(0, 1)) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent+10"
            "RenderType"="Transparent"
        }
        Pass {
            Name "ForwardBase"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            
            #pragma multi_compile_fwdbase
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
            uniform float _node_8317;
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
////// Lighting:
////// Emissive:
                float4 node_2117 = _Time + _TimeEditor;
                float2 node_4096 = ((i.uv0+node_2117.g*float2(0.1,-0.2))+(i.uv0+node_2117.g*float2(0.1,-0.2)));
                float4 _node_7420_var = tex2D(_node_7420,TRANSFORM_TEX(node_4096, _node_7420));
                float2 node_2626 = ((i.uv0+node_2117.g*float2(0,-0.3))+(_node_7420_var.r*_node_2624));
                float4 _node_3919_var = tex2D(_node_3919,TRANSFORM_TEX(node_2626, _node_3919));
                float3 emissive = (i.vertexColor.rgb*((_node_3919_var.rgb*_lingdu)*_node_893.rgb)*i.vertexColor.a);
                float3 finalColor = emissive;
                float2 node_6902 = (i.uv0+node_2117.g*float2(0,-0.2));
                float4 _node_3522_var = tex2D(_node_3522,TRANSFORM_TEX(node_6902, _node_3522));
                return fixed4(finalColor,(i.vertexColor.a*((_node_3522_var.r*_rongjie)-_node_8317)));
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
