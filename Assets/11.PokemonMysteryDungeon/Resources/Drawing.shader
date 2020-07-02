Shader "Hidden/Custom/Drawing"
{
    HLSLINCLUDE

    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);
    TEXTURE2D_SAMPLER2D(_DrawingTex, sampler_DrawingTex);

    float _OverlayOffset;
    float _Strength;
    float _Tiling;
    float _DepthThreshold;

    float4 Frag(VaryingsDefault i) : SV_Target
    {
        float2 drawingUV = i.texcoord * _Tiling + _OverlayOffset;
        drawingUV.y *= _ScreenParams.y / _ScreenParams.x;

        float4 drawingCol = SAMPLE_TEXTURE2D(_DrawingTex, sampler_DrawingTex, drawingUV)
            + SAMPLE_TEXTURE2D(_DrawingTex, sampler_DrawingTex, drawingUV * 0.33f);
        drawingCol *= 0.5f;

        float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);

        float lum = dot(col, float3(0.3f, 0.59f, 0.11f));
        float4 drawing = lerp(col, drawingCol * col, (1.0f - lum) * _Strength);

        float depth = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, i.texcoord).r;
        depth = Linear01Depth(depth);

        return depth < _DepthThreshold ? drawing : col;
    }

    ENDHLSL

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM

            #pragma vertex VertDefault
            #pragma fragment Frag

            ENDHLSL
        }
    }
}