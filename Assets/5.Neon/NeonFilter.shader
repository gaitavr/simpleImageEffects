Shader "Hidden/NeonFilter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Threshold("Bloom threshold", Range(0,1)) = 0.5
		_Kernel ("Kernel (N)", int) = 21
		_Spread("Spread (sigma)", Float) = 5.0
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
			Name "NeonPass"

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
			float2 _MainTex_TexelSize;

			float getLum(float2 uv, float2 offset, float m)
			{
				fixed3 col = tex2D(_MainTex, uv + offset);
				float lum = col.r * 0.3 + col.g * 0.59 + col.b * 0.11;
				return lum * m;
			}

			float3 sobel(float2 uv)
			{
				float x = 0;
				float y = 0;
				float2 texelSize = _MainTex_TexelSize;

				x += getLum(uv, float2(-texelSize.x, -texelSize.y), -1.0);
				x += getLum(uv, float2(-texelSize.x,            0), -2.0);
				x += getLum(uv, float2(-texelSize.x,  texelSize.y), -1.0);

				x += getLum(uv, float2(texelSize.x, -texelSize.y), 1.0);
				x += getLum(uv, float2(texelSize.x,            0), 2.0);
				x += getLum(uv, float2(texelSize.x,  texelSize.y), 1.0);

				y += getLum(uv, float2(-texelSize.x, -texelSize.y), -1.0);
				y += getLum(uv, float2(           0, -texelSize.y), -2.0);
				y += getLum(uv, float2( texelSize.x, -texelSize.y), -1.0);

				y += getLum(uv, float2(-texelSize.x, texelSize.y), 1.0);
				y += getLum(uv, float2(           0, texelSize.y), 2.0);
				y += getLum(uv, float2( texelSize.x, texelSize.y), 1.0);

				return sqrt(x*x + y*y);
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
                fixed3 s = sobel(i.uv);
				fixed3 tex = tex2D(_MainTex, i.uv);

				fixed3 hsvCol = rgb2hsv(tex);
				hsvCol.y = 1.0;
				hsvCol.z = 1.0;
				fixed3 col = hsv2rgb(hsvCol);

				return fixed4(s * col, 1.0);
            }
            ENDCG
        }

		Pass
        {
			Name "ThresholdPass"

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
			float _Threshold;

			float3 rgb2hsv(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = c.g < c.b ? float4(c.bg, K.wz) : float4(c.gb, K.xy);
				float4 q = c.r < p.x ? float4(p.xyw, c.r) : float4(c.r, p.yzx);

				float d = q.x - min(q.w, q.y);
				float e = 1.0e-10;
				return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 tex = tex2D(_MainTex, i.uv);
				float saturation = rgb2hsv(tex).y;
				return (saturation > _Threshold) ? tex : fixed4(0.0, 0.0, 0.0, 1.0);
            }
            ENDCG
        }

		UsePass "Hidden/GaussBlurFilter/BlurPass"

		Pass
        {
			Name "AddPass"

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
			sampler2D _SrcTex;

            fixed4 frag (v2f i) : SV_Target
            {
				fixed3 originalCol = tex2D(_SrcTex, i.uv);
				fixed3 blurredCol = tex2D(_MainTex, i.uv);
				return fixed4(originalCol + blurredCol, 1.0);
            }
            ENDCG
        }
    }
}
