Shader "Hidden/BoxBlurFilter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Kernel ("Kernel (N)", int) = 21
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

            fixed4 frag (v2f i) : SV_Target
            {
				fixed originAlpha = tex2D(_MainTex, i.uv).a;
				fixed3 col = fixed3(0.0, 0.0, 0.0);

				int upper = ((_Kernel - 1) / 2);
				int lower = -upper;

				for (int x = lower; x <= upper; ++x)
				{
					for (int y = lower; y <= upper; ++y)
					{
						fixed2 offset = fixed2(_MainTex_TexelSize.x * x, _MainTex_TexelSize.y * y);
						col += tex2D(_MainTex, i.uv + offset);
					}
				}
				col /= (_Kernel * _Kernel);
				return fixed4(col, originAlpha);
            }
            ENDCG
        }
    }
}
