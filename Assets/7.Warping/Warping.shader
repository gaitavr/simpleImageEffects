Shader "Hidden/Warping"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Amplitude("Amplitude", float) = 5
		_Speed("Speed", float) = 15
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
			float _Amplitude;
			float _Speed;

            fixed4 frag (v2f i) : SV_Target
            {
				float freq = _Amplitude * sin(_Speed * _Time);
				float2 warp = 
					0.5000 * cos(i.uv.xy * 1.0 * freq + _Time) + 
					0.2500 * cos(i.uv.yx * 2.0 * freq + _Time) + 
					0.1250 * cos(i.uv.xy * 4.0 * freq + _Time) +
					0.0625 * cos(i.uv.yx * 8.0 * freq + _Time);
				warp *= 0.05;
                fixed4 col = tex2D(_MainTex, i.uv + warp);
                return col;
            }
            ENDCG
        }
    }
}
