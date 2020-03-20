using UnityEngine;

[RequireComponent(typeof(Camera))]
public class SimpleFilter : MonoBehaviour
{
    [SerializeField]
    private Shader _shader;

    private Material _material;
    private bool _useFilter = true;

    private void Awake()
    {
        _material = new Material(_shader);
    }

    private void Update()
    {
        if (Input.GetKeyUp(KeyCode.F))
        {
            _useFilter = !_useFilter;
        }
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        if (_useFilter)
        {
            Graphics.Blit(src, dst, _material);
        }
        else
        {
            Graphics.Blit(src, dst);
        }
    }
}
