// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "NNN/NormalShaderFrag"
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
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCOORD2;
				float4 TtoW2 : TEXCOORD3;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				float3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));

				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
				fixed3 tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				tangentNormal = normalize(half3(dot(i.TtoW0.xyz, tangentNormal), dot(i.TtoW1.xyz, tangentNormal), dot(i.TtoW2.xyz, tangentNormal)));

				//纹理颜色
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				//环境颜色
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
				//漫反射颜色
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldLightDir, tangentNormal));
				// 镜面反射光
				float3 halfDir = normalize(worldViewDir + worldLightDir);
				fixed3 specular = _LightColor0.rgb * _Specular * pow(max(0, dot(tangentNormal, halfDir)) , _Gloss);

				return fixed4(ambient + diffuse + specular ,1);
			}


		ENDCG
	}

	}


	Fallback "Specular"
}