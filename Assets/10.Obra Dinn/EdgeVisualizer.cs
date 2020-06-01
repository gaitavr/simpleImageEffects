using UnityEngine;

public class EdgeVisualizer : MonoBehaviour
{
    [SerializeField]
    private float _sensitivityDepth = 1.0f;
    [SerializeField]
    private float _sensitivityNormals = 1.0f;
    [SerializeField, Range(0f, 1f)]
    private float _edgesOnly = 0.0f;
    [SerializeField]
    private Color _edgesOnlyBgColor = Color.black;
    [SerializeField]
    private Color _edgesColor = Color.white;

    private Material _robertMat;
    private Material _sobelMat;

    private void Awake()
    {
        _robertMat = new Material(Shader.Find("Hidden/EdgeDetectColors"));
        _sobelMat = new Material(Shader.Find("Hidden/EdgeDetectFilter"));
        var cam = GetComponent<Camera>();
        cam.depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    public void RenderByRobert(RenderTexture src, RenderTexture dst)
    {
        Vector2 sensitivity = new Vector2(_sensitivityDepth, _sensitivityNormals);
        _robertMat.SetVector("_Sensitivity", new Vector4(sensitivity.x, sensitivity.y, 1.0f, sensitivity.y));
        _robertMat.SetFloat("_BgFade", _edgesOnly);
        _robertMat.SetVector("_BgColor", _edgesOnlyBgColor);
        _robertMat.SetVector("_Color", _edgesColor);
        Graphics.Blit(src, dst, _robertMat);
    }

    public void RenderBySobel(RenderTexture src, RenderTexture dst)
    {
        Graphics.Blit(src, dst, _sobelMat);
    }
}
