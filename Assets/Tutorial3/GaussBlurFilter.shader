Shader "Hidden/GaussBlurFilter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Kernel ("Kernel (N)", int) = 21
		_Spread("Spread (sigma)", Float) = 5.0
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
			Name "BlurPass"
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

			static const float TWO_PI = 6.28319;
			static const float E = 2.71828;

            sampler2D _MainTex;
			float2 _MainTex_TexelSize;
			int _Kernel;
			float _Spread;

			float gaussian(int x, int y)
			{
				float sigmaSqu = _Spread * _Spread;
				return (1 / sqrt(TWO_PI * sigmaSqu)) * pow(E, -((x * x) + (y * y)) / (2 * sigmaSqu));
			}

            fixed4 frag (v2f i) : SV_Target
            {
                fixed originAlpha = tex2D(_MainTex, i.uv).a;
				fixed3 col = fixed3(0.0, 0.0, 0.0);
				float kernelSum = 0.0;

				int upper = ((_Kernel - 1) / 2);
				int lower = -upper;

				for (int x = lower; x <= upper; ++x)
				{
					for (int y = lower; y <= upper; ++y)
					{
						float gauss = gaussian(x, y);
						kernelSum += gauss;
						fixed2 offset = fixed2(_MainTex_TexelSize.x * x, _MainTex_TexelSize.y * y);
						col += gauss * tex2D(_MainTex, i.uv + offset);
					}
				}
				col /= kernelSum;
				return fixed4(col, originAlpha);
            }
            ENDCG
        }
    }
}
