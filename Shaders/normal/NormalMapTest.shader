// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "NNN./NormalTest"
{
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("MainTex", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "dump" {}
		_NormalScale("NormalScale", Float) = 1
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8, 256)) = 20
	}

		SubShader{
		Pass{
		Tags{ "LightMode" = "ForwardBase" }

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "Lighting.cginc"
		#include "UnityCG.cginc"

		fixed4 _Color;
		sampler2D _MainTex;
		float4 _MainTex_ST;
		sampler2D _NormalMap;
		float4 _NormalMap_ST;
		float _NormalScale;
		fixed4 _Specular;
		float _Gloss;


		struct a2v
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 tangent : TANGENT;
			float4 texcoord : TEXCOORD0;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			float4 uv : TEXCOORD0;

			float4 transformX : TEXCOORD1;
			float4 transformY : TEXCOORD2;
			float4 transformZ : TEXCOORD3;
		};

		v2f vert(a2v v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv.xy = o.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			o.uv.zw = o.uv.zw * _NormalMap_ST.xy + _NormalMap_ST.zw;

			float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
			float3 dinormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
			o.transformX = mul(unity_ObjectToWorld, float4(v.tangent.x, dinormal.x, v.normal.x, worldPos.x));
			o.transformY = mul(unity_ObjectToWorld, float4(v.tangent.y, dinormal.y, v.normal.y, worldPos.y));
			o.transformZ = mul(unity_ObjectToWorld, float4(v.tangent.z, dinormal.z, v.normal.z, worldPos.z));


			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			float3 worldPos = float3(i.transformX.w, i.transformY.w, i.transformX.w);
			float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
			float3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));

			fixed4 texColor = tex2D(_MainTex, i.uv.xy) * _Color;

			fixed4 packedNormal = tex2D(_NormalMap, i.uv.zw);
			fixed3 tangentNormal = UnpackNormal(packedNormal);
			tangentNormal.xy *= _NormalScale;
			tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

			tangentNormal = normalize(half3(dot(i.transformX.xyz, tangentNormal.xyz), dot(i.transformY.xyz, tangentNormal.xyz),dot(i.transformZ.xyz, tangentNormal.xyz)));


			fixed3 albedo = texColor * _Color;
			float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

			float3 diffuse = _LightColor0.xyz * albedo * max(0, dot(worldLightDir, tangentNormal));

			float3 halfDir = normalize(worldViewDir + worldLightDir);
			float3 specular = _LightColor0.xyz * _Specular.xyz * pow(dot(halfDir, tangentNormal) , _Gloss);

			return fixed4(ambient + diffuse + specular, 1.0);
		}



		ENDCG
	}
	}

		Fallback "Specular"
}