// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "BBB/SpecularVertexRender"
{
	Properties{
		_Diffuse("Diffuse", Color) = (1,1,1,1)
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
	}

	SubShader{
		Pass{
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "Lighting.cginc"

				fixed4 _Diffuse;
				fixed4 _Specular;
				float _Gloss;

				struct a2v
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
				};
				struct v2f
				{
					float4 pos : SV_POSITION;
					fixed3 color : COLOR;
				};

				v2f vert(a2v v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
						
					fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
					fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
					fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));

					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

					//获取反射方向, worldLight 是从 物体到光源的方向，计算反射需要光源到物体的方向，所以取反
					float3 ref = normalize(reflect(-worldLight, worldNormal));
					//获取视口方向, 物体到摄像机的向量，用摄像机的位置 - 物体位置 即可
					float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
					//计算反射光
					float3 specular = _LightColor0.rgb * _Specular.rbg * pow(saturate(dot(viewDir, ref)), _Gloss);

					o.color = diffuse + ambient + specular;

					return o;
				}

				fixed4 frag(v2f data) : SV_Target
				{
					return fixed4(data.color, 1.0) ;
				}
				ENDCG
		}
	}

	Fallback "Diffuse"
}