using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MosaicFilter : SimpleFilter
{
    [SerializeField]
    private int _xTileCount = 100;

    [SerializeField]
    private Texture2D _overlayTexture;

    [SerializeField]
    private Color _overlayCol = Color.white;

    protected override void OnUpdate()
    {
        _mat.SetTexture("_OverlayTex", _overlayTexture);
        _mat.SetColor("_OverlayCol", _overlayCol);
        _mat.SetInt("_XTileCount", _xTileCount);
        _mat.SetInt("_YTileCount", Mathf.RoundToInt((float)Screen.height / Screen.width * _xTileCount));
    }

    protected override void UseFilter(RenderTexture src, RenderTexture dst)
    {
        var temp = RenderTexture.GetTemporary(_xTileCount,
            Mathf.RoundToInt((float) src.height / src.width * _xTileCount));
        temp.filterMode = FilterMode.Point;
        Graphics.Blit(src, temp);
        Graphics.Blit(temp, dst, _mat);
        RenderTexture.ReleaseTemporary(temp);
    }
}
