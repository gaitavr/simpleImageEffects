﻿Shader "Hidden/SepiaFilter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

				half3x3 sepiaMatrix = half3x3
				(
					0.393, 0.349, 0.272,	// Red
					0.769, 0.686, 0.534,	// Green
					0.189, 0.168, 0.131		// Blue
				);

				half3 rgb = col.rgb;
				half3 result = mul(rgb, sepiaMatrix);
				return fixed4(result, col.a);
            }
            ENDCG
        }
    }
}
