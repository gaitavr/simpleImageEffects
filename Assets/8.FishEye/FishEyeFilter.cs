using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FishEyeFilter : SimpleFilter
{
    [SerializeField]
    private float _pow;

    protected override void OnUpdate()
    {
        _mat.SetFloat("_BarrelPower", _pow);
    }
}
