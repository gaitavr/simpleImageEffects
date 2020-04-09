using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WarpingFilter : SimpleFilter
{
    [Range(1, 10)]
    [SerializeField]
    private float _amplitude = 5;
    [Range(1, 50)]
    [SerializeField]
    private float _speed = 15;

    protected override void OnUpdate()
    {
        _mat.SetFloat("_Amplitude", _amplitude);
        _mat.SetFloat("_Speed", _speed);
    }
}
