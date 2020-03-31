
using UnityEngine;

public class SilhouetteFilter : SimpleFilter
{
    [SerializeField] private Color _nearColor;
    [SerializeField] private Color _farColor;

    protected override void OnUpdate()
    {
        _mat.SetColor("_NearColor", _nearColor);
        _mat.SetColor("_FarColor", _farColor);
    }
}
