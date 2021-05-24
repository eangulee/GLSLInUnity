using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Profiling;

public class ShadowMapping : MonoBehaviour
{
    public Light dirLight;
    Camera dirLightCamera;

    public int shadowResolution = 1;
    public Shader shadowCaster = null;
    private RenderTexture rt_2d;

    void OnDestroy()
    {
        dirLightCamera = null;
        DestroyImmediate(rt_2d);
    }

    private RenderTexture CreateRenderTexture()
    {
        RenderTextureFormat rtFormat = RenderTextureFormat.Default;
        if (!SystemInfo.SupportsRenderTextureFormat(rtFormat))
            rtFormat = RenderTextureFormat.Default;

        rt_2d = new RenderTexture(512 * shadowResolution, 512 * shadowResolution, 24, rtFormat);
        rt_2d.hideFlags = HideFlags.DontSave;

        Shader.SetGlobalTexture("_gShadowMapTexture", rt_2d);

        return rt_2d;
    }

    public Camera CreateDirLightCamera()
    {
        GameObject goLightCamera = new GameObject("Directional Light Camera");
        Camera LightCamera = goLightCamera.AddComponent<Camera>();

        LightCamera.cullingMask = 1 << LayerMask.NameToLayer("Caster");
        LightCamera.backgroundColor = Color.white;
        LightCamera.clearFlags = CameraClearFlags.SolidColor;

        LightCamera.orthographic = true;
        LightCamera.orthographicSize = 10f;
        LightCamera.nearClipPlane = 0.3f;
        LightCamera.farClipPlane = 100;
        LightCamera.transform.rotation = dirLight.transform.rotation;
        LightCamera.transform.position = dirLight.transform.position;
        //LightCamera.enabled = false;
        return LightCamera;
    }

    private void Update()
    {
        if (dirLight)
        {
            if (!dirLightCamera)
            {
                dirLightCamera = CreateDirLightCamera();
                dirLightCamera.targetTexture = CreateRenderTexture();
            }
            Profiler.BeginSample("ShadowMapping");
            //dirLightCamera.RenderWithShader(shadowCaster, "");//没用
            dirLightCamera.SetReplacementShader(shadowCaster, "RenderType");
            Shader.SetGlobalFloat("_gShadowBias", 0.005f);
            Shader.SetGlobalFloat("_gShadowStrength", 0.5f);
            Matrix4x4 projectionMatrix = GL.GetGPUProjectionMatrix(dirLightCamera.projectionMatrix, false);
            Shader.SetGlobalMatrix("_gWorldToShadow", projectionMatrix * dirLightCamera.worldToCameraMatrix);
            Profiler.EndSample();
        }
    }
}
