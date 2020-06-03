using System.Collections;
using UnityEngine;

public class DitherFilter : SimpleFilter
{
    [SerializeField] private Texture2D _noiseTexture;
    [SerializeField] private Texture2D _rampTexture;

    private EdgeRenderer _edgeRenderer;

    protected override void Init()
    {
        _edgeRenderer = GetComponent<EdgeRenderer>();
    }

    protected override void UseFilter(RenderTexture src, RenderTexture dst)
    {
        _mat.SetTexture("_NoiseTex", _noiseTexture);
        _mat.SetTexture("_ColorRampTex", _rampTexture);

        RenderTexture big = RenderTexture.GetTemporary(src.width * 2, src.height * 2);
        RenderTexture half = RenderTexture.GetTemporary(src.width / 2, src.height / 2);

        RenderTexture edged = RenderTexture.GetTemporary(src.width, src.height);
        _edgeRenderer.RenderByRobert(src, edged);
        _mat.SetTexture("_EdgedTex", edged);

        Graphics.Blit(src, big);
        Graphics.Blit(big, half, _mat);
        Graphics.Blit(half, dst);

        RenderTexture.ReleaseTemporary(big);
        RenderTexture.ReleaseTemporary(half);
        RenderTexture.ReleaseTemporary(edged);
    }
}
