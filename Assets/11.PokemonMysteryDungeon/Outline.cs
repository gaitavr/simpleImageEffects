using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(typeof(OutlineRenderer), PostProcessEvent.AfterStack, "Custom/Outline")]
public class Outline : PostProcessEffectSettings
{
    [Range(0f, 0.3f), Tooltip("Sensitivity color.")]
    public FloatParameter ColorSensitivity = new FloatParameter { value = 0.1f };
    [Range(0f, 1f), Tooltip("Strength of color.")]
    public FloatParameter ColorStrength = new FloatParameter { value = 1.0f };

    [Range(0f, 0.1f), Tooltip("Sensitivity depth.")]
    public FloatParameter DepthSensitivity = new FloatParameter { value = 0.1f };
    [Range(0f, 1f), Tooltip("Strength of depth.")]
    public FloatParameter DepthStrength = new FloatParameter { value = 1.0f };

    [Range(0f, 0.3f), Tooltip("Sensitivity normals.")]
    public FloatParameter NormalsSensitivity = new FloatParameter { value = 0.1f };
    [Range(0f, 1f), Tooltip("Strength of normals.")]
    public FloatParameter NormalsStrength = new FloatParameter { value = 1.0f };
}

public sealed class OutlineRenderer : PostProcessEffectRenderer<Outline>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/Outline"));
        sheet.properties.SetFloat("_ColorSensitivity", settings.ColorSensitivity);
        sheet.properties.SetFloat("_ColorStrength", settings.ColorStrength);
        sheet.properties.SetFloat("_DepthSensitivity", settings.DepthSensitivity);
        sheet.properties.SetFloat("_DepthStrength", settings.DepthStrength);
        sheet.properties.SetFloat("_NormalsSensitivity", settings.NormalsSensitivity);
        sheet.properties.SetFloat("_NormalsStrength", settings.NormalsStrength);
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}
