using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GodRayPostEffect : PostEffectBase
{
    public Color colorThreshold = Color.gray;

    public Color lightColor = Color.white;

    [Range(0.0f, 20.0f)]
    public float lightFactor = 0.5f;

    [Range(0.0f, 10.0f)]
    public float samplerScale = 1;

    [Range(1, 3)]
    public int blurIteration = 2;

    [Range(0, 3)]
    public int downSample = 1;

    public Transform lightTransform;

    [Range(0.0f, 5.0f)]
    public float lightRadius = 2.0f;

    [Range(1.0f, 4.0f)]
    public float lightPowFactor = 3.0f;

    private Camera targetCamera = null;

    void Awake()
    {
        targetCamera = GetComponent<Camera>();
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        
        if (_Material && targetCamera)
        {
            int rtWidth = source.width >> downSample;
            int rtHeight = source.height >> downSample;

            RenderTexture temp1 = RenderTexture.GetTemporary(rtWidth, rtHeight, 0, source.format);

            Vector3 viewPortLightPos = lightTransform == null ? new Vector3(.5f, .5f, 0) : targetCamera.WorldToViewportPoint(lightTransform.position);

            _Material.SetVector("_ColorThreshold", colorThreshold);
            _Material.SetVector("_ViewPortLightPos", new Vector4(viewPortLightPos.x, viewPortLightPos.y, viewPortLightPos.z, 0));
            _Material.SetFloat("_LightRadius", lightRadius);
            _Material.SetFloat("_PowFactor", lightPowFactor);

            Graphics.Blit(source, temp1, _Material, 0);

            //_Material.SetVector("_ViewPortLightPos", new Vector4)

            float samplerOffset = samplerScale / source.width;

            for (int i = 0; i < blurIteration; i ++)
            {
                RenderTexture temp2 = RenderTexture.GetTemporary(rtWidth, rtHeight, 0, source.format);
                float offset = samplerOffset * (i * 2 + 1);
                _Material.SetVector("_offsets", new Vector4(offset, offset, 0, 0));
                Graphics.Blit(temp1, temp2, _Material, 1);

                offset = samplerOffset * (i * 2 + 2);
                _Material.SetVector("_offsets", new Vector4(offset, offset, 0, 0));
                Graphics.Blit(temp2, temp1, _Material, 1);
                RenderTexture.ReleaseTemporary(temp2);
            }

            _Material.SetTexture("_BlurTex", temp1);
            _Material.SetVector("_LightColor", lightColor);
            _Material.SetFloat("_LightFactor", lightFactor);

            Graphics.Blit(source, destination, _Material, 2);

            RenderTexture.ReleaseTemporary(temp1);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
