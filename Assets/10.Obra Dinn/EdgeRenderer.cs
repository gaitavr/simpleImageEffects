using UnityEngine;

public class EdgeRenderer : MonoBehaviour
{
    [SerializeField] private float _sensitivityDepth = 1.0f;
    [SerializeField] private float _sensitivityNormals = 1.0f;
    [SerializeField, Range(0, 1)] private float _edgesOnly = 1.0f;
    [SerializeField] private Color _edgesOnlyBgColor = Color.black;
    [SerializeField] private Color _edgesColor = Color.white;

    private Material _robertMat;
    private Material _sobelMat;

    private void Awake()
    {
        _sobelMat = new Material(Shader.Find("Hidden/EdgeDetectFilter"));
        _robertMat = new Material(Shader.Find("Hidden/EdgeDetectColors"));
        var camera = GetComponent<Camera>();
        camera.depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    public void RenderByRobert(RenderTexture src, RenderTexture dst)
    {
        _robertMat.SetVector("_Sensitivity", new Vector4(_sensitivityDepth, _sensitivityNormals,
            1.0f, _sensitivityNormals));
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
