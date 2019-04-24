// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:False,igpj:True,qofs:500,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:9361,x:33209,y:32712,varname:node_9361,prsc:2|custl-4682-OUT,alpha-472-A,voffset-3720-OUT;n:type:ShaderForge.SFN_TexCoord,id:7370,x:31610,y:32651,varname:node_7370,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_TexCoord,id:6593,x:31681,y:32922,varname:node_6593,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Panner,id:4334,x:31858,y:32674,varname:node_4334,prsc:2,spu:0.2,spv:0.2|UVIN-7370-UVOUT;n:type:ShaderForge.SFN_Panner,id:7762,x:31913,y:32881,varname:node_7762,prsc:2,spu:0.2,spv:0.2|UVIN-6593-UVOUT;n:type:ShaderForge.SFN_Panner,id:6983,x:32332,y:32403,varname:node_6983,prsc:2,spu:-0.1,spv:-0.1|UVIN-1499-UVOUT;n:type:ShaderForge.SFN_TexCoord,id:1499,x:32088,y:32403,varname:node_1499,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Add,id:6790,x:32134,y:32725,varname:node_6790,prsc:2|A-4334-UVOUT,B-7762-UVOUT;n:type:ShaderForge.SFN_Multiply,id:1909,x:32332,y:32799,varname:node_1909,prsc:2|A-6790-OUT,B-2336-OUT;n:type:ShaderForge.SFN_Slider,id:2336,x:32019,y:33126,ptovrint:False,ptlb:Repeat,ptin:_Repeat,varname:node_2336,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.3,max:1;n:type:ShaderForge.SFN_Tex2d,id:6706,x:32499,y:32799,ptovrint:False,ptlb:Main_Tex,ptin:_Main_Tex,varname:node_6706,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:445950576add916499f998d8d8288a57,ntxv:2,isnm:False|UVIN-1909-OUT;n:type:ShaderForge.SFN_Add,id:1280,x:32680,y:32659,varname:node_1280,prsc:2|A-6983-UVOUT,B-6706-R;n:type:ShaderForge.SFN_Tex2d,id:3901,x:32872,y:32642,ptovrint:False,ptlb:Diffuse,ptin:_Diffuse,varname:node_3901,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:445950576add916499f998d8d8288a57,ntxv:0,isnm:False|UVIN-1280-OUT;n:type:ShaderForge.SFN_Multiply,id:3720,x:32877,y:33291,varname:node_3720,prsc:2|A-9742-OUT,B-3884-OUT,C-6706-G;n:type:ShaderForge.SFN_Slider,id:9742,x:32432,y:33224,ptovrint:False,ptlb:Vertex,ptin:_Vertex,varname:_Noies_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.3944421,max:1;n:type:ShaderForge.SFN_NormalVector,id:3884,x:32538,y:33359,prsc:2,pt:False;n:type:ShaderForge.SFN_Multiply,id:4682,x:33021,y:32825,varname:node_4682,prsc:2|A-3901-RGB,B-2053-RGB;n:type:ShaderForge.SFN_Color,id:2053,x:32777,y:32873,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_2053,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:0.9,c3:0.9,c4:1;n:type:ShaderForge.SFN_VertexColor,id:472,x:32877,y:33114,varname:node_472,prsc:2;proporder:2336-6706-9742-3901-2053;pass:END;sub:END;*/

Shader "Shader Forge/water_fast" {
    Properties {
        _Repeat ("Repeat", Range(0, 1)) = 0.3
        _Main_Tex ("Main_Tex", 2D) = "black" {}
        _Vertex ("Vertex", Range(0, 1)) = 0.3944421
        _Diffuse ("Diffuse", 2D) = "white" {}
        _Color ("Color", Color) = (1,0.9,0.9,1)
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent+500"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
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
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform float _Repeat;
            uniform sampler2D _Main_Tex; uniform float4 _Main_Tex_ST;
            uniform sampler2D _Diffuse; uniform float4 _Diffuse_ST;
            uniform float _Vertex;
            uniform float4 _Color;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                float4 node_7881 = _Time;
                float2 node_1909 = (((o.uv0+node_7881.g*float2(0.2,0.2))+(o.uv0+node_7881.g*float2(0.2,0.2)))*_Repeat);
                float4 _Main_Tex_var = tex2Dlod(_Main_Tex,float4(TRANSFORM_TEX(node_1909, _Main_Tex),0.0,0));
                v.vertex.xyz += (_Vertex*v.normal*_Main_Tex_var.g);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
////// Lighting:
                float4 node_7881 = _Time;
                float2 node_1909 = (((i.uv0+node_7881.g*float2(0.2,0.2))+(i.uv0+node_7881.g*float2(0.2,0.2)))*_Repeat);
                float4 _Main_Tex_var = tex2D(_Main_Tex,TRANSFORM_TEX(node_1909, _Main_Tex));
                float2 node_1280 = ((i.uv0+node_7881.g*float2(-0.1,-0.1))+_Main_Tex_var.r);
                float4 _Diffuse_var = tex2D(_Diffuse,TRANSFORM_TEX(node_1280, _Diffuse));
                float3 finalColor = (_Diffuse_var.rgb*_Color.rgb);
                return fixed4(finalColor,i.vertexColor.a);
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform float _Repeat;
            uniform sampler2D _Main_Tex; uniform float4 _Main_Tex_ST;
            uniform float _Vertex;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float2 uv0 : TEXCOORD1;
                float4 posWorld : TEXCOORD2;
                float3 normalDir : TEXCOORD3;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                float4 node_4408 = _Time;
                float2 node_1909 = (((o.uv0+node_4408.g*float2(0.2,0.2))+(o.uv0+node_4408.g*float2(0.2,0.2)))*_Repeat);
                float4 _Main_Tex_var = tex2Dlod(_Main_Tex,float4(TRANSFORM_TEX(node_1909, _Main_Tex),0.0,0));
                v.vertex.xyz += (_Vertex*v.normal*_Main_Tex_var.g);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
