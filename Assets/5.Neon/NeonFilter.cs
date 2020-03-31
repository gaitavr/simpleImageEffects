using UnityEngine;
using System.Collections;

public class NeonFilter : SimpleFilter
{
    protected override void UseFilter(RenderTexture src, RenderTexture dst)
    {
        RenderTexture neonTex = RenderTexture.GetTemporary(src.width, src.height, 0, src.format);
        RenderTexture thresholdTex = RenderTexture.GetTemporary(src.width, src.height, 0, src.format);
        RenderTexture blurTex = RenderTexture.GetTemporary(src.width, src.height, 0, src.format);

        Graphics.Blit(src, neonTex, _mat, 0);
        Graphics.Blit(neonTex, thresholdTex, _mat, 1);
        Graphics.Blit(thresholdTex, blurTex, _mat, 2);
        _mat.SetTexture("_SrcTex", neonTex);
        Graphics.Blit(blurTex, dst, _mat, 3);

        RenderTexture.ReleaseTemporary(neonTex);
        RenderTexture.ReleaseTemporary(thresholdTex);
        RenderTexture.ReleaseTemporary(blurTex);
    }
}
