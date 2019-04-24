// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:False,igpj:True,qofs:500,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:9361,x:33209,y:32712,varname:node_9361,prsc:2|custl-6057-OUT,clip-4257-OUT,voffset-3720-OUT;n:type:ShaderForge.SFN_TexCoord,id:7370,x:31610,y:32651,varname:node_7370,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_TexCoord,id:6593,x:31681,y:32922,varname:node_6593,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Panner,id:4334,x:31858,y:32674,varname:node_4334,prsc:2,spu:0.05,spv:0.05|UVIN-7370-UVOUT;n:type:ShaderForge.SFN_Panner,id:7762,x:31913,y:32881,varname:node_7762,prsc:2,spu:0.05,spv:0.05|UVIN-6593-UVOUT;n:type:ShaderForge.SFN_Panner,id:6983,x:32332,y:32403,varname:node_6983,prsc:2,spu:-0.01,spv:-0.01|UVIN-1499-UVOUT;n:type:ShaderForge.SFN_TexCoord,id:1499,x:32088,y:32403,varname:node_1499,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Add,id:6790,x:32134,y:32725,varname:node_6790,prsc:2|A-4334-UVOUT,B-7762-UVOUT;n:type:ShaderForge.SFN_Multiply,id:1909,x:32329,y:32799,varname:node_1909,prsc:2|A-6790-OUT,B-2336-OUT;n:type:ShaderForge.SFN_Slider,id:2336,x:32019,y:33126,ptovrint:False,ptlb:Noies,ptin:_Noies,varname:node_2336,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.3,max:1;n:type:ShaderForge.SFN_Tex2d,id:6706,x:32499,y:32799,ptovrint:False,ptlb:Main_Tex,ptin:_Main_Tex,varname:node_6706,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:445950576add916499f998d8d8288a57,ntxv:2,isnm:False|UVIN-1909-OUT;n:type:ShaderForge.SFN_Add,id:1280,x:32680,y:32659,varname:node_1280,prsc:2|A-6983-UVOUT,B-6706-R;n:type:ShaderForge.SFN_Tex2d,id:3901,x:32872,y:32642,ptovrint:False,ptlb:Diffuse,ptin:_Diffuse,varname:node_3901,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:445950576add916499f998d8d8288a57,ntxv:0,isnm:False|UVIN-1280-OUT;n:type:ShaderForge.SFN_Multiply,id:3720,x:32877,y:33291,varname:node_3720,prsc:2|A-9742-OUT,B-3884-OUT,C-6706-G;n:type:ShaderForge.SFN_Slider,id:9742,x:32432,y:33224,ptovrint:False,ptlb:Vertex,ptin:_Vertex,varname:_Noies_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.3944421,max:1;n:type:ShaderForge.SFN_NormalVector,id:3884,x:32652,y:33346,prsc:2,pt:False;n:type:ShaderForge.SFN_Color,id:2053,x:32732,y:32829,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_2053,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:0.9,c3:0.9,c4:1;n:type:ShaderForge.SFN_Multiply,id:6057,x:33000,y:32792,varname:node_6057,prsc:2|A-3901-RGB,B-2053-RGB;n:type:ShaderForge.SFN_If,id:4147,x:31962,y:33241,varname:node_4147,prsc:2|A-7539-OUT,B-5679-RGB,GT-2414-OUT,EQ-2414-OUT,LT-4210-OUT;n:type:ShaderForge.SFN_Vector1,id:2414,x:31437,y:33427,varname:node_2414,prsc:2,v1:1;n:type:ShaderForge.SFN_Vector1,id:4210,x:31476,y:33545,varname:node_4210,prsc:2,v1:0;n:type:ShaderForge.SFN_If,id:562,x:31973,y:33545,varname:node_562,prsc:2|A-5679-R,B-5679-RGB,GT-2414-OUT,EQ-2414-OUT,LT-4210-OUT;n:type:ShaderForge.SFN_Subtract,id:5389,x:32159,y:33408,varname:node_5389,prsc:2|A-4147-OUT,B-562-OUT;n:type:ShaderForge.SFN_Multiply,id:4920,x:32254,y:33733,varname:node_4920,prsc:2|A-5389-OUT,B-2261-OUT;n:type:ShaderForge.SFN_VertexColor,id:5679,x:31364,y:33610,varname:node_5679,prsc:2;n:type:ShaderForge.SFN_Add,id:7539,x:31620,y:33841,varname:node_7539,prsc:2|A-4656-OUT,B-5679-R;n:type:ShaderForge.SFN_Add,id:1125,x:32507,y:33667,varname:node_1125,prsc:2|A-4147-OUT,B-4920-OUT;n:type:ShaderForge.SFN_Multiply,id:7371,x:32804,y:33648,varname:node_7371,prsc:2|A-6706-A,B-1125-OUT;n:type:ShaderForge.SFN_Multiply,id:4257,x:33061,y:33674,varname:node_4257,prsc:2|A-5679-A,B-7371-OUT;n:type:ShaderForge.SFN_Vector1,id:4656,x:31374,y:33864,varname:node_4656,prsc:2,v1:0;n:type:ShaderForge.SFN_Vector1,id:2261,x:31999,y:33767,varname:node_2261,prsc:2,v1:0;proporder:2336-6706-9742-3901-2053;pass:END;sub:END;*/

Shader "Shader Forge/water_add" {
    Properties {
        _Noies ("Noies", Range(0, 1)) = 0.3
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
            Blend One One
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
			#include "AutoLight.cginc" 

            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform float _Noies;
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
                float4 node_1131 = _Time;
                float2 node_1909 = (((o.uv0+node_1131.g*float2(0.005,0.005))+(o.uv0+node_1131.g*float2(0.005,0.005)))*_Noies);
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
                float4 node_1131 = _Time;
                float2 node_1909 = (((i.uv0+node_1131.g*float2(0.005,0.005))+(i.uv0+node_1131.g*float2(0.005,0.005)))*_Noies);
                float4 _Main_Tex_var = tex2D(_Main_Tex,TRANSFORM_TEX(node_1909, _Main_Tex));
                float node_4147_if_leA = step((0.0+i.vertexColor.r),i.vertexColor.rgb);
                float node_4147_if_leB = step(i.vertexColor.rgb,(0.0+i.vertexColor.r));
                float node_4210 = 0.0;
                float node_2414 = 1.0;
                float3 node_4147 = lerp((node_4147_if_leA*node_4210)+(node_4147_if_leB*node_2414),node_2414,node_4147_if_leA*node_4147_if_leB);
                float node_562_if_leA = step(i.vertexColor.r,i.vertexColor.rgb);
                float node_562_if_leB = step(i.vertexColor.rgb,i.vertexColor.r);
                clip((i.vertexColor.a*(_Main_Tex_var.a*(node_4147+((node_4147-lerp((node_562_if_leA*node_4210)+(node_562_if_leB*node_2414),node_2414,node_562_if_leA*node_562_if_leB))*0.0)))) - 0.5);
////// Lighting:
                float2 node_1280 = ((i.uv0+node_1131.g*float2(-0.2,0.2))+_Main_Tex_var.r);
                float4 _Diffuse_var = tex2D(_Diffuse,TRANSFORM_TEX(node_1280, _Diffuse));
                
                float3 finalColor = (_Diffuse_var.rgb*_Color.rgb) ;

                return fixed4(finalColor, 1);
            }
            ENDCG
        }
        
    }
    FallBack "Diffuse"
    // CustomEditor "ShaderForgeMaterialInspector"
}
