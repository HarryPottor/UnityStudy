// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "AAA/BaseShader_Struct"
{
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL; // 法线方向[-1.0, 1.0]
				float4 texcoord : TEXCOORD0;
				float3 tangent : TANGENT;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				fixed3 color : COLOR0;
			};


			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				// 把法线的值映射到[0, 1]中
				o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);

				return o;
			}

			fixed4 frag(v2f i): SV_Target
			{
				return fixed4(i.color, 1.0);
			}
			ENDCG
		}
	}


}