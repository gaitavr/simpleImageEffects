Shader "Hidden/Mosaic"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_OverlayTex("Overlay tex", 2D) = "white"{}
		_OverlayCol("Overlay color", Color) = (1,1,1,1)
		_XTileCount("x tile count", Int) = 100
		_YTileCount("y tile count", Int) = 100
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
			sampler2D _OverlayTex;
			float4 _OverlayCol;
			int _XTileCount;
			int _YTileCount;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
				float2 overlayUV = i.uv * float2(_XTileCount, _YTileCount);
				float4 overlayCol = tex2D(_OverlayTex, overlayUV) * _OverlayCol;
				col = lerp(col, overlayCol, overlayCol.a);
                return col;
            }
            ENDCG
        }
    }
}
