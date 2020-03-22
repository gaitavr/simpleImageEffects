using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimpleFilter : MonoBehaviour
{
    [SerializeField] private Shader _shader;

    private Material _mat;

    private bool _useFilter = true;

    private void Awake()
    {
        _mat = new Material(_shader);
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
            Graphics.Blit(src, dst, _mat);
        }
        else
        {
            Graphics.Blit(src, dst);
        }
    }
}
