using UnityEngine;

public class DitherFilter : SimpleFilter
{
    [SerializeField]
    private Texture2D _noiseTexture;
    [SerializeField]
    private Texture2D _rampTexture;

    private Camera _cam;
    private EdgeVisualizer _edgeVisualizer;

    private const float OFFSET_MULTIPLIER = 0.005f;

    protected override void Init()
    {
        _cam = GetComponent<Camera>();
        _mat.SetTexture("_NoiseTex", _noiseTexture);
        _mat.SetTexture("_ColorRampTex", _rampTexture);
        _edgeVisualizer = GetComponent<EdgeVisualizer>();
    }

    private bool _robert;

    protected override void OnUpdate()
    {
        if (Input.GetKeyDown(KeyCode.T))
        {
            _robert = !_robert;
        }
    }

    protected override void UseFilter(RenderTexture src, RenderTexture dst)
    {
        var camEuler = _cam.transform.eulerAngles;
        var xOffset = camEuler.y / _cam.fieldOfView * OFFSET_MULTIPLIER;
        var yOffset = _cam.aspect * camEuler.x / _cam.fieldOfView * OFFSET_MULTIPLIER;

        _mat.SetFloat("_XOffset", xOffset);
        _mat.SetFloat("_YOffset", yOffset);

        RenderTexture edged = RenderTexture.GetTemporary(src.width, src.height);
        RenderTexture big = RenderTexture.GetTemporary(src.width * 2, src.height * 2);
        RenderTexture half = RenderTexture.GetTemporary(src.width / 2, src.height / 2);

        if (_robert)
        {
            _edgeVisualizer.RenderByRobert(src, edged);
        }
        else
        {
            _edgeVisualizer.RenderBySobel(src, edged);
        }
        _mat.SetTexture("_Edged", edged);

        Graphics.Blit(src, big);
        Graphics.Blit(big, half, _mat);
        Graphics.Blit(half, dst);

        RenderTexture.ReleaseTemporary(edged);
        RenderTexture.ReleaseTemporary(half);
        RenderTexture.ReleaseTemporary(big);
    }
}
