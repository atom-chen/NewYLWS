// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

/*
@喵喵mya
2017-04-07 10:57:33

基于深度图以及法线贴图的海水Shader
根据深度在与其他物体的交界处逐渐透明，并产生冲击岸边的海浪


2017-5-6 21:57:57
修改了法线贴图的算法
加入了对cubemap反射的支持

不能接收实时光
*/
Shader "Custom/water_wave_depth"
{

	Properties {		
    _WaterColor("WaterColor",Color) = (0,.25,.4,1)//海水颜色
    _FarColor("FarColor",Color)=(.2,1,1,.3)//反射颜色
    _BumpMap("BumpMap", 2D) = "white" {}//法线贴图
    _BumpPower("BumpPower",Range(-1,1))=.6//法线强度
    _EdgeColor("EdgeColor",Color)=(0,1,1,0)//海浪颜色
    _EdgeTex("EdgeTex",2D)="white" {}//海浪贴图
    _WaveTex("WaveTex",2D)="white" {}//海浪周期贴图
    _WaveSpeed("WaveSpeed",Range(0,10))=1//海浪速度
    _NoiseTex("Noise", 2D) = "white" {} //海浪躁波
    _NoiseRange ("NoiseRange", Range(0,10)) = 1//海浪躁波强度
    _EdgeRange("EdgeRange",Range(0.1,10))=.4//边缘混合强度
    _WaveSize("WaveSize",Range(0.01,1))=.25//波纹大小
    _WaveOffset("WaveOffset(xy&zw)",vector)=(.1,.2,-.2,-.1)//波纹流动方向
    _LightColor("LightColor",Color)=(1,1,1,1)//光源颜色
    _LightVector("LightVector(xyz for lightDir,w for power)",vector)=(.5,.5,.5,100)//光源方向
	// _Cubemap ("Cubemap", CUBE) = ""{}//反射
	// _ReflAmount ("Reflection Amount", Range(0,1)) = 0.5  
	_DepthTexture("DepthTexture", 2D) = "white"{}
	}
		SubShader{
				Tags{  
                "RenderType" = "Opaque" 
                "Queue" = "Transparent"
                }
				Blend SrcAlpha OneMinusSrcAlpha
				LOD 200
		Pass{
		    CGPROGRAM
	        #pragma vertex vert
	        #pragma fragment frag
	        #pragma multi_compile_fog
            #pragma shader_feature DEPTH_ON DEPTH_OFF
            #pragma target 3.0
            #include "UnityCG.cginc"

        fixed4 _WaterColor;
        fixed4 _FarColor;

    	sampler2D _BumpMap;
    	half _BumpPower;

    	half _WaveSize;
        half4 _WaveOffset;
		sampler2D _DepthTexture;
		
		// samplerCUBE _Cubemap;
		// float _ReflAmount; 

        #ifdef DEPTH_ON
        fixed4 _EdgeColor;
        sampler2D _EdgeTex , _WaveTex , _NoiseTex;
        half4 _NoiseTex_ST;

        half _WaveSpeed;
        half _NoiseRange;
        half _EdgeRange;

        sampler2D_float _CameraDepthTexture;
        #endif

        fixed4 _LightColor;
        half4 _LightVector;

		struct a2v {
			float4 vertex:POSITION;
			float4 texcoord:TEXCOORD1;
			float3 normal : NORMAL;
			float4 tangent : TANGENT;
		};
		struct v2f
		{
			half4 pos : POSITION;
			half3 lightDir:TEXCOORD0;
            half4 screenPos:TEXCOORD1;
            half4 uv : TEXCOORD2;
			#ifdef DEPTH_ON
            half2 uv_noise : TEXCOORD3;
			#endif
			half4 TtoW0 : TEXCOORD4;  
			half4 TtoW1 : TEXCOORD5;  
			half4 TtoW2 : TEXCOORD6; 
            UNITY_FOG_COORDS(7)
		};

		//unity没有取余的函数，自己写一个
		half2 fract(half2 val)
		{
			return val - floor(val);
		}

		v2f vert(a2v v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);

			TANGENT_SPACE_ROTATION;  
			// o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));  
            o.lightDir = normalize(_LightVector.xyz);//世界空间灯光方向
                  
            float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
            // fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
            // fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
            // fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;  

			float3x3 WtoT = mul(rotation, (float3x3)unity_WorldToObject);  
            o.TtoW0 = float4(WtoT[0].xyz, worldPos.x);  
            o.TtoW1 = float4(WtoT[1].xyz, worldPos.y);  
            o.TtoW2 = float4(WtoT[2].xyz, worldPos.z);  

            float4 wPos = mul(unity_ObjectToWorld,v.vertex);
            o.uv.xy = worldPos.xz * _WaveSize + _WaveOffset.xy * _Time.y;
            o.uv.zw = worldPos.xz * _WaveSize * 2 + _WaveOffset.zw * _Time.y;
			#ifdef DEPTH_ON
            o.uv_noise = TRANSFORM_TEX (v.texcoord , _NoiseTex);
			#endif

            o.screenPos = ComputeScreenPos(o.pos);
            COMPUTE_EYEDEPTH(o.screenPos.z);

            UNITY_TRANSFER_FOG(o, o.pos);
			return o;
		}


		fixed4 frag(v2f i):COLOR {

			float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);  //世界空间位置
			fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos)); //世界空间摄像机方向
			fixed3 lightDir = i.lightDir;   // normalize(_LightVector.xyz);//世界空间灯光方向

	

			//海水颜色
            fixed4 col=_WaterColor;

            //计算法线
            half3 nor = UnpackNormal((tex2D(_BumpMap,fract(i.uv.xy)) + tex2D(_BumpMap,fract(i.uv.zw)))*0.5); 
			nor.xy *= _BumpPower;
			half3 worldNormal = normalize(mul(nor, float3x3(i.TtoW0.xyz, i.TtoW1.xyz, i.TtoW2.xyz)));//世界空间的法线

           	//计算高光
            half spec =saturate(dot(worldNormal,normalize(lightDir + worldViewDir)));  
            spec = pow(spec,_LightVector.w); 

            //计算菲涅耳反射
            half fresnel=1-saturate(dot(worldNormal,worldViewDir)); 


			// fixed3 worldRefl = reflect (-worldViewDir, worldNormal); 
			// fixed3 reflCol = texCUBE(_Cubemap, worldRefl).rgb * _ReflAmount ; 

			_FarColor.rgb *= fixed3(12/255, 5/255, 0);   // reflCol;
            col=lerp(col,_FarColor ,fresnel); 

            //计算海水边缘以及海浪
            #ifdef DEPTH_ON  
			half depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));
			//使用自己生成的深度贴图，以达到减少渲染深度图用到的场景。减少面数。graylei20181013
			//使用Unity自带的深度贴图所有RenderType=Opaque,Queue<2500且带ShadowCaster的pass的shader都会被渲染到深度图，造成面数翻倍
			//暂时用不到先注释掉备份起来。
			//half2 depthUV = i.screenPos.xy / i.screenPos.w;
			//half depth = DecodeFloatRGBA(tex2D(_DepthTexture,depthUV)) * _ProjectionParams.z ;   // 用这个方法
			//half depth = DecodeFloatRGBA(SAMPLE_DEPTH_TEXTURE_PROJ(_DepthTexture,UNITY_PROJ_COORD(i.screenPos))) * _ProjectionParams.z ;  // 用这个会有精度丢失，暂时没有查找原因，这个是参照Unity的实现方式。
			depth = saturate((depth - i.screenPos.z)*_EdgeRange);
			//没有开启深度图的情况适配下
			// depth = lerp(depth, 1, step(1, 1- depth));

			fixed noise = tex2D(_NoiseTex,i.uv_noise).r;
           	fixed wave=tex2D(_WaveTex,fract(half2(_Time.y*_WaveSpeed+ depth + noise * _NoiseRange,0.5))).r;
            fixed edge = saturate((tex2D(_EdgeTex,i.uv.xy*5).a + tex2D(_EdgeTex,i.uv.zw *2).a)*0.5) * wave;
            col.rgb +=_EdgeColor * edge *(1-depth);  
            col.a = lerp(0,col.a,depth);
            #endif  



            col.rgb+= _LightColor*spec;  
            UNITY_APPLY_FOG(i.fogCoord, col);
            return col;  
}
		ENDCG
	}
	}
	FallBack OFF
}