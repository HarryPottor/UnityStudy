// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "NNN/NormalShader"
{
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("MainTex", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}	// 法线贴图， bump默认的法线纹理
		_BumpScale("Bump Scale", Float) = 1.0 // 控制凹凸程度，0 表示不会对光产生影响
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8, 256)) = 20
	}

	SubShader{
		Pass{
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL; // 注意 normal 是三维
				float4 tangent : TANGENT;	// 注意 tangent 是四维, 因为需要w来获取第三个坐标轴
				float4 texcoord : TEXCOORD0; // 注意 从应用过来的纹理坐标是 四维
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;	//因为要保存两张贴图的纹理，需要保存两个纹理的位置
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				
				// 求局部空间的坐标 到 切线空间坐标
				// y轴, ******因为 切线和法线 垂直的方向有两种，用w来确定。
				// float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w; 
				// 通过x,y,z 轴 获取 从当前空间到上层空间的转换矩阵。该矩阵即为从 切线坐标轴转为局部空间
				///***** x,y,z 按行排序，从上层到本层坐标系；按列排序从本层到上层坐标轴
				// float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal); 
				
				// 或者使用这个命令  获取 rotation
				TANGENT_SPACE_ROTATION;

				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				// 获取法线颜色
				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw); // 法线包
				fixed3 tangentNormal;
				// 由法线颜色 获取 法线向量
				//因为法线都是单位向量 所以 x方 + y方 + z方 = 1
				// 所以 z = 开方(1 - x方 - y方 )
				// x*x + y*y = (x,y)点乘(x,y)
				tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				/*
				// 解法线包 ***** 在法线贴图的类型设置为 NormalType 才能用这个方法，否则只能用上边的方法
				tangentNormal = UnpackNormal(packedNormal); 
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
				*/

				//纹理颜色
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				//环境颜色
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
				//漫反射颜色
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentLightDir, tangentNormal));
				// 镜面反射光
				float3 halfDir = normalize(tangentViewDir + tangentLightDir);
				fixed3 specular = _LightColor0.rgb * _Specular * pow(max(0, dot(tangentNormal, halfDir)) , _Gloss);

				return fixed4(ambient + diffuse + specular ,1);
			}


		ENDCG
	}

	}


	Fallback "Specular"
}