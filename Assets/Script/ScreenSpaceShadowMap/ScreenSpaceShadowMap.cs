using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.Profiling;

[RequireComponent(typeof(Camera))]
public class ScreenSpaceShadowMap : MonoBehaviour {
    public Material shadowCasterMat = null;
    public Material shadowCollectorMat = null;

    public GameObject _light;
	public static Camera _lightCamera;
    RenderTexture lightDepthTexture = null;
    public float orthographicSize = 6f;
    public float nearClipPlane = 0.3f;
    public float farClipPlane = 20f;
    public float shadowBias = 0.005f;
    public float shadowStrength = 0.5f;

    public static Camera _depthCamera;
    RenderTexture depthTexture = null;

    RenderTexture screenSpaceShadowTexture = null;

    public int qulity = 2;

    void OnDestroy()
    {
        _depthCamera = null;
        _lightCamera = null;

        if (depthTexture)
        {
            DestroyImmediate(lightDepthTexture);
        }

        if (lightDepthTexture)
        {
            DestroyImmediate(lightDepthTexture);
        }

        if (screenSpaceShadowTexture)
        {
            DestroyImmediate(screenSpaceShadowTexture);
        }

        if (shadowCasterMat)
        {
            DestroyImmediate(shadowCasterMat);
        }
    }

    void Awake ()
    {
        Shader.EnableKeyword("_ReceiveShadow"); //for level test
    }

    public Camera CreateDepthCamera()
    {
        GameObject goDepthCamera = new GameObject("Depth Camera");
        Camera depthCamera = goDepthCamera.AddComponent<Camera>();

        depthCamera.CopyFrom(Camera.main);
        depthCamera.backgroundColor = Color.white;
        depthCamera.clearFlags = CameraClearFlags.SolidColor;
        depthCamera.enabled = false;

        if (!depthCamera.targetTexture)
            depthCamera.targetTexture = depthTexture = CreateTextureFor(depthCamera);

        Shader.SetGlobalTexture("_DepthTexture", depthTexture);

        return depthCamera;
    }

    public Camera CreateLightCamera()
    {
        GameObject goLightCamera = new GameObject("Shadow Camera");
        Camera LightCamera = goLightCamera.AddComponent<Camera>();

        LightCamera.cullingMask = 1 << LayerMask.NameToLayer("Pawn") | 1 << LayerMask.NameToLayer("Monster");
        LightCamera.backgroundColor = Color.white;
        LightCamera.clearFlags = CameraClearFlags.SolidColor;
        LightCamera.orthographic = true;
        LightCamera.orthographicSize = 6f;
        LightCamera.nearClipPlane = 0.3f;
        LightCamera.farClipPlane = 20;
        LightCamera.enabled = false;

        if (!LightCamera.targetTexture)
            LightCamera.targetTexture = lightDepthTexture = CreateTextureFor(LightCamera);

        return LightCamera;
    }

    private RenderTexture CreateTextureFor(Camera cam)
    {
        RenderTexture rt = new RenderTexture(Screen.width * qulity, Screen.height * qulity, 24, RenderTextureFormat.R8);
        rt.hideFlags = HideFlags.DontSave;
        rt.autoGenerateMips = false;

        return rt;
    }


	private void LateUpdate()
    {
        if (shadowCasterMat == null || shadowCollectorMat == null)
        {
            return;
        }

        if (!_depthCamera)
        {
            _depthCamera = CreateDepthCamera();

            _depthCamera.transform.parent = Camera.main.transform;
            _depthCamera.transform.localPosition = Vector3.zero;
            _depthCamera.transform.localRotation = Quaternion.identity;
        }

        Profiler.BeginSample("ScreenSpaceShadowMap");
        _depthCamera.RenderWithShader(shadowCasterMat.shader, "");

        if (!_lightCamera)
        {
            _lightCamera = CreateLightCamera();

            _lightCamera.transform.parent = _light.transform;
            _lightCamera.transform.localPosition = Vector3.zero;
            _lightCamera.transform.localRotation = Quaternion.identity;
        }

        _lightCamera.orthographicSize = orthographicSize;
        _lightCamera.nearClipPlane = nearClipPlane;
        _lightCamera.farClipPlane = farClipPlane;
        Shader.SetGlobalFloat("_gShadowBias", shadowBias);
        Shader.SetGlobalFloat("_gShadowStrength", shadowStrength);

        _lightCamera.RenderWithShader(shadowCasterMat.shader, "");


        // shadow collector
        if (screenSpaceShadowTexture == null)
        {
            screenSpaceShadowTexture = new RenderTexture(Screen.width * qulity, Screen.height * qulity, 0, RenderTextureFormat.R8);
            screenSpaceShadowTexture.hideFlags = HideFlags.DontSave;
            screenSpaceShadowTexture.autoGenerateMips = false;
        }

        Matrix4x4 projectionMatrix = GL.GetGPUProjectionMatrix(Camera.main.projectionMatrix, false);
        Shader.SetGlobalMatrix("_inverseVP", Matrix4x4.Inverse(projectionMatrix * Camera.main.worldToCameraMatrix));

        shadowCollectorMat.SetTexture("_CameraDepthTex", depthTexture);
        shadowCollectorMat.SetTexture("_LightDepthTex", lightDepthTexture);
        projectionMatrix = GL.GetGPUProjectionMatrix(_lightCamera.projectionMatrix, false);
        Shader.SetGlobalMatrix("_WorldToShadow", projectionMatrix * _lightCamera.worldToCameraMatrix);
        Graphics.Blit(depthTexture, screenSpaceShadowTexture, shadowCollectorMat);

        Shader.SetGlobalTexture("_ScreenSpceShadowTexture", screenSpaceShadowTexture);
        Profiler.EndSample();
    }
}
