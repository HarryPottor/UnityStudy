Shader "Custom/uvshader"
{
    Properties
    {
        _MainTex("texture1", 2D) = "white" {}
        _SubTex("texture2", 2D) = "white" {}
    }

    SubShader
    {

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCg.cginc"

            sampler2D _MainTex;
            float2 _MainTex_ST;
            sampler2D _SubTex;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            }

            struct v2f
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            }

            v2f vert(appdata data)
            {
                v2f o;
                o.vertex = mul(UNITY_METRIX_MVP, data.vertex);
                o.uv = TRANSFORM_TEX(data.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f data) : COLOR
            {
                float2 offset = float2(0, 0);
                offset.x = _Time.z;
                offset.y = _Time.z;
                fixed4 subCol = tex2D(_SubTex, data.uv + offset);
                fixed4 mainCol = tex2D(_MainTex, data.uv) + subCol;

                return mainCol;
            }


            ENDCG
        }


    }
    
}