using UnityEngine;

public class CyberpunkGlitchFilter : SimpleFilter
{
    [SerializeField, Range(0, 1f)]
    private float _colorIntensity = 1f;
    private float _flickerTimer;
    private float _flickerTime = 0.5f;
    
    [SerializeField, Range(0, 1)]
    private float _noiseIntensity = 1f;
    [SerializeField]
    private Texture2D _noiseTexture;
    
    [SerializeField, Range(0, 1)]
    private float _flipIntensity = 1f;
    private float _flipUpTimer;
    private float _flipUpTime = 0.05f;
    private float _flipDownTimer;
    private float _flipDownTime = 0.05f;
    
    protected override void UseFilter(RenderTexture src, RenderTexture dst)
    {
        _flipUpTimer += Time.deltaTime * _flipIntensity;
        if (_flipUpTimer > _flipUpTime)
        {
            if (Random.value < 0.1f * _flipIntensity)
            {
                _mat.SetFloat("_FlipUp", Random.value * _flipIntensity);
            }
            else
            {
                _mat.SetFloat("_FlipUp", 0);
            }
            _flipUpTimer = 0;
            _flipUpTime = Random.value * 0.1f;
        }

        _flipDownTimer += Time.deltaTime * _flipIntensity;
        if (_flipDownTimer > _flipDownTime)
        {
            if (Random.value < 0.1f * _flipIntensity)
            {
                _mat.SetFloat("_FlipDown", 1 - Random.value * _flipIntensity);
            }
            else
            {
                _mat.SetFloat("_FlipDown", 1);
            }
            _flipDownTimer = 0;
            _flipDownTime = Random.value * 0.1f;
        }
        
        if (_flipIntensity == 0)
        {
            _mat.SetFloat("_FlipUp", 0);
            _mat.SetFloat("_FlipDown", 1);
        }
        
        _mat.SetTexture("_NoiseTex", _noiseTexture);
        if (Random.value < 0.05 * _noiseIntensity)
        {
            _mat.SetFloat("_DisplacementFactor", Random.value * _noiseIntensity);
            _mat.SetFloat("_NoiseScale", 1 - Random.value - _noiseIntensity);
        }
        else
        {
            _mat.SetFloat("_DisplacementFactor", 0);
        }
        
        _flickerTimer += Time.deltaTime * _colorIntensity;
        if (_flickerTimer > _flickerTime)
        {
            _mat.SetVector("_ColorDirection", Random.insideUnitCircle);
            _mat.SetFloat("_ColorRadius", Random.Range(-3f, 3f) * 
                                          _colorIntensity);
            _flickerTimer = 0;
            _flickerTime = Random.value;
        }

        if (_colorIntensity == 0)
        {
            _mat.SetFloat("_ColorRadius", 0);
        }
        Graphics.Blit(src, dst, _mat);
    }
}
