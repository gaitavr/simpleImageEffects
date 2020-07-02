using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class DungeonCamera : MonoBehaviour
{
    private Camera _camera;

    private void Awake()
    {
        _camera = GetComponent<Camera>();
        _camera.depthTextureMode = DepthTextureMode.DepthNormals;
    }
}
