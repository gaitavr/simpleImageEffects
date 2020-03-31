Shader "Hidden/PaintFilter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Kernel("Kernel size", int) = 15
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
			int _Kernel;
			float2 _MainTex_TexelSize;

			struct region
			{
				float3 mean;
				float variance;
			};

			region calculateRegion(int2 lower, int2 upper, int samples, float2 uv)
			{
				region r;
				float3 sum = 0.0;
				float3 squareSum = 0.0;

				for(int x = lower.x; x <= upper.x; ++x)
				{
					for(int y = lower.y; y <= upper.y; ++y)
					{
						fixed2 offset = fixed2(_MainTex_TexelSize.x * x, _MainTex_TexelSize.y * y);
						fixed3 col = tex2D(_MainTex, uv + offset);

						sum += col;
						squareSum += col * col;
					}
				}

				r.mean = sum / samples;

				float3 variance = abs((squareSum / samples) - (r.mean * r.mean));
				r.variance = length(variance);

				return r;
			}

			float3 rgb2hsv(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = c.g < c.b ? float4(c.bg, K.wz) : float4(c.gb, K.xy);
				float4 q = c.r < p.x ? float4(p.xyw, c.r) : float4(c.r, p.yzx);

				float d = q.x - min(q.w, q.y);
				float e = 1.0e-10;
				return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}

			float3 hsv2rgb(float3 c)
			{
				float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
				float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
				return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
			}

            fixed4 frag (v2f i) : SV_Target
            {
                int upper = (_Kernel - 1) / 2;
				int lower = -upper;

				int samples = (upper + 1) * (upper + 1);

				region regionA = calculateRegion(int2(lower, lower), int2(0, 0), samples, i.uv);
				region regionB = calculateRegion(int2(0, lower), int2(upper, 0), samples, i.uv);
				region regionC = calculateRegion(int2(lower, 0), int2(0, upper), samples, i.uv);
				region regionD = calculateRegion(int2(0, 0), int2(upper, upper), samples, i.uv);

				fixed3 col = regionA.mean;
				fixed minVar = regionA.variance;

				float testVal;

				testVal = step(regionB.variance, minVar);
				col = lerp(col, regionB.mean, testVal);
				minVar = lerp(minVar, regionB.variance, testVal);

				testVal = step(regionC.variance, minVar);
				col = lerp(col, regionC.mean, testVal);
				minVar = lerp(minVar, regionC.variance, testVal);

				testVal = step(regionD.variance, minVar);
				col = lerp(col, regionD.mean, testVal);

				fixed3 hasvCol = rgb2hsv(col);
				hasvCol.y *= 2;
				col = hsv2rgb(hasvCol);

				return fixed4(col, 1.0);
            }
            ENDCG
        }
    }
}
