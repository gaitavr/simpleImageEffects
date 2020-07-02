Shader "Hidden/Custom/Outline"
{
    HLSLINCLUDE

    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    float4 _MainTex_TexelSize;
    float _ColorSensitivity;
    float _ColorStrength;

    TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);
    float _DepthSensitivity;
    float _DepthStrength;

    TEXTURE2D_SAMPLER2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture);
    float _NormalsSensitivity;
    float _NormalsStrength;

    struct UvData
    {
        float2 leftUV;
        float2 rightUV;
        float2 bottomUV;
        float2 topUV;
    };

    UvData Expand(float2 uv)
    {
        UvData data;

        data.leftUV = uv + float2(-_MainTex_TexelSize.x, 0);
        data.rightUV = uv + float2(_MainTex_TexelSize.x, 0);
        data.bottomUV = uv + float2(0, -_MainTex_TexelSize.y);
        data.topUV = uv + float2(0, _MainTex_TexelSize.y);

        return data;
    }

    float ColorEdge(UvData data)
    {
        float3 col0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, data.leftUV).rgb;
        float3 col1 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, data.rightUV).rgb;
        float3 col2 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, data.bottomUV).rgb;
        float3 col3 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, data.topUV).rgb;

        float3 c0 = col1 - col0;
        float3 c1 = col3 - col2;

        float edgeCol = sqrt(dot(c0, c0) + dot(c1, c1));
        return edgeCol > _ColorSensitivity ? _ColorStrength : 0;
    }

    float DepthEdge(UvData data)
    {
        float depth0 = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, data.leftUV).r;
        float depth1 = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, data.rightUV).r;
        float depth2 = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, data.bottomUV).r;
        float depth3 = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, data.topUV).r;

        depth0 = Linear01Depth(depth0);
        depth1 = Linear01Depth(depth1);
        depth2 = Linear01Depth(depth2);
        depth3 = Linear01Depth(depth3);

        float d0 = depth1 - depth0;
        float d1 = depth3 - depth2;

        float edgeDepth = sqrt(d0 * d0 + d1 * d1);
        return edgeDepth > _DepthSensitivity ? _DepthStrength : 0;
    }

    float NormalEdge(UvData data)
    {
        float3 normal0 = SAMPLE_TEXTURE2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture,
            data.leftUV).rgb;
        float3 normal1 = SAMPLE_TEXTURE2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture,
            data.rightUV).rgb;
        float3 normal2 = SAMPLE_TEXTURE2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture,
            data.bottomUV).rgb;
        float3 normal3 = SAMPLE_TEXTURE2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture,
            data.topUV).rgb;

        float3 n0 = normal1 - normal0;
        float3 n1 = normal3 - normal2;

        float edgeNormal = sqrt(dot(n0, n0) + dot(n1, n1));
        return edgeNormal > _NormalsSensitivity ? _NormalsStrength : 0;
    }

    float4 Frag(VaryingsDefault i) : SV_Target
    {
        float2 uv = i.texcoord;
        float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);

        UvData data = Expand(uv);
        float colorEdge = ColorEdge(data);
        float depthEdge = DepthEdge(data);
        float normalEdge = NormalEdge(data);

        float edge = max(max(colorEdge, depthEdge), normalEdge);

        return color * (1.0f - edge);
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