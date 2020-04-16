Shader "Hidden/FishEyeFilter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_BarrelPower("Barrel power", float) = 1.5
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
			float _BarrelPower;

			float2 distort(float2 uv, float radius)
			{
				float theta = atan2(uv.y, uv.x);
				radius = pow(radius, _BarrelPower);
				uv.x = radius * cos(theta);
				uv.y = radius * sin(theta);

				return 0.5 * (uv + 1.0);
			}

            fixed4 frag (v2f i) : SV_Target
            {
				float2 uv = (i.uv * 2.0) - 1.0;
				float radius = length(uv);
                fixed4 col = tex2D(_MainTex, i.uv);
				if(radius >= 1)
				{
					return col;
				}
				uv = distort(uv, radius);
                col = tex2D(_MainTex, uv);
                return col;
            }
            ENDCG
        }
    }
}
