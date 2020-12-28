Shader "Hidden/CyberpunkGlitchFilter"
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
            fixed2 _ColorDirection;
            half _ColorRadius;
            
            sampler2D _NoiseTex;
            half _DisplacementFactor;
            half _NoiseScale;
            
            half _FlipUp;
            half _FlipDown;
            
            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
         
                uv.y -= (1 - (uv.y + _FlipUp)) * step(uv.y, _FlipUp) + 
                    (1 - (uv.y - _FlipDown)) * step(_FlipDown, uv.y);
                
                fixed4 noise = tex2D(_NoiseTex, i.uv * _NoiseScale);
                uv += (noise.rg - 0.5) * _DisplacementFactor;

                half4 col = tex2D(_MainTex, uv);
                half4 colR = tex2D(_MainTex, uv + _ColorDirection * _ColorRadius * 
                    0.01);
                half4 colG = tex2D(_MainTex, uv - _ColorDirection * _ColorRadius * 
                    0.01);
                float threshold = 0.5;
                float lum = 0.5;
                col.rgb += colR.rbg * step(_ColorRadius, -threshold) * lum;
                col.rgb += colG.gbr * step(threshold, _ColorRadius) * lum;
                return col;
            }
            ENDCG
        }
    }
}
