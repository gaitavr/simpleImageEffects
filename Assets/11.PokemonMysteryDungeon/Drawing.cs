using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(typeof(DrawingRenderer), PostProcessEvent.AfterStack, "Custom/Drawing")]
public class Drawing : PostProcessEffectSettings
{
    [Tooltip("Main texture")]
    public TextureParameter DrawingTex = new TextureParameter { value = null };
    [Range(0f, 2f), Tooltip("Shift cycle time")]
    public FloatParameter ShiftCycleTime = new FloatParameter { value = 1.0f };
    [Range(0f, 1f), Tooltip("Effect strength")]
    public FloatParameter Strength = new FloatParameter { value = 0.5f };
    [Range(1f, 100f), Tooltip("Tiling")]
    public FloatParameter Tiling = new FloatParameter { value = 10.0f };
    [Range(0f, 1f), Tooltip("Depth threshold")]
    public FloatParameter DepthThreshold = new FloatParameter { value = 0.99f };
}

public sealed class DrawingRenderer : PostProcessEffectRenderer<Drawing>
{
    public override void Render(PostProcessRenderContext context)
    {
        bool isOffset = (Time.time % settings.ShiftCycleTime) < (settings.ShiftCycleTime / 2.0f);

        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/Drawing"));
        sheet.properties.SetTexture("_DrawingTex", settings.DrawingTex);
        sheet.properties.SetFloat("_OverlayOffset", isOffset ? 0.5f : 0.0f);
        sheet.properties.SetFloat("_Strength", settings.Strength);
        sheet.properties.SetFloat("_Tiling", settings.Tiling);
        sheet.properties.SetFloat("_DepthThreshold", settings.DepthThreshold);
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}
