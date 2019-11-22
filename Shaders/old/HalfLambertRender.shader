// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "BBB/HalfLambertRender"
{
	Properties{
		_Diffuse("Diffuse", color) = (1,1,1,1)
	}

		SubShader{
			Pass{
				Tags {"LightMode" = "ForwardBase"}

				CGPROGRAM
					#pragma vertex vert
					#pragma fragment frag
					#include "Lighting.cginc"

					fixed4 _Diffuse;
					struct a2v
					{
						float4 vertex : POSITION;
						float3 normal : NORMAL;
					};
					struct v2f
					{
						float4 pos : SV_POSITION;
						fixed3 worldNormal : TEXCOORD0;
					};

					v2f vert(a2v v)
					{
						v2f o;
						o.pos = UnityObjectToClipPos(v.vertex);
						o.worldNormal = mul(unity_WorldToObject, v.normal);
						return o;
					}

					fixed4 frag(v2f data) : SV_Target
					{
						fixed3 worldNormal = normalize(data.worldNormal);
						fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
						float halfValue = 0.5 * dot(worldNormal, worldLight) + 0.5;
						fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfValue;
						fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

						fixed3 color = diffuse + ambient;

						return fixed4(color, 1.0) ;
					}
					ENDCG
			}
	}

	Fallback "Diffuse"
}