Shader "Hidden/Dithering"
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
            Name "Dithering"
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

            uniform sampler2D _MainTex;
            uniform float4 _MainTex_TexelSize;

            uniform sampler2D _NoiseTex;
            uniform float4 _NoiseTex_TexelSize;

            uniform sampler2D _ColorRampTex;

            static float3 _greyScale = float3(0.299, 0.587, 0.114);

            uniform sampler2D _EdgedTex;

            fixed4 frag(v2f i) : SV_Target
            {
                half3 returnCol = tex2D(_EdgedTex, i.uv).rgb;
                fixed3 mainCol = tex2D(_MainTex, i.uv).rgb;
                float mainLum = dot(mainCol, _greyScale);

                float2 noiseUV = i.uv * _NoiseTex_TexelSize.xy * _MainTex_TexelSize.zw;
                fixed3 noiseCol = tex2D(_NoiseTex, noiseUV);
                float noiseLum = 1 - dot(noiseCol, _greyScale);

                float rampVal = mainLum < noiseLum ? noiseLum - mainLum - 0.15: 0.99;
                returnCol += tex2D(_ColorRampTex, float2(rampVal, 0.5));

                returnCol = clamp(returnCol, 0.0, 0.88);
                return float4(returnCol, 1.0);
            }
            ENDCG
        }
    }
}
