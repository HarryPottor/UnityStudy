// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CCC/SingleTextue"
{
	Properties{
		_Color ("Color Tint", Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8, 256)) = 20
	}


	SubShader{
		Pass{
		Tags {"LightMode" = "ForwardBase"}
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"
		#include "Lighting.cginc"

		fixed4 _Color;
		sampler2D _MainTex;
		float4 _MainTex_ST; // 纹理类型的缩放和偏移，x,y 为缩放，z,w 为偏移
		fixed4 _Specular;
		float _Gloss;

		struct a2v
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 texcoord : TEXCOORD0;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			float3 worldNormal : TEXCOORD0;
			float3 worldPos : TEXCOORD1;
			float2 uv : TEXCOORD2;
		};


		v2f vert(a2v v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.worldNormal = UnityObjectToWorldNormal(v.normal);
			// 不可以使用 这个公式，这只是用来 算向量的。
			//UnityObjectToWorldDir(v.vertex).xyz;
			o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
			
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			//o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

			return o;
		}

		fixed4 frag(v2f data):SV_Target
		{
			float3 worldNormal = normalize(data.worldNormal);
			float3 worldLightDir = normalize(UnityWorldSpaceLightDir(data.worldPos)).xyz;
			
			// 使用纹理的采样结果 和 颜色属性_Color 的乘积作为材质的反射率albedo
			fixed3 albedo = tex2D(_MainTex, data.uv).rgb * _Color.rgb;
			fixed3 albient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

			float3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

			float3 viewDir = normalize(UnityWorldSpaceViewDir(data.worldPos));
			float3 h = normalize(viewDir+ worldLightDir);
			float specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal , h)), _Gloss);

			fixed3 color = albient +diffuse  +specular;
			return fixed4(color, 1.0);
		}

			ENDCG
		}
	}

	Fallback "Specular"
}