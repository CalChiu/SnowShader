using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class CameraSnowScript : MonoBehaviour {
    [SerializeField] private Texture2D SnowTexture;

    [SerializeField] private Light sun;

    [SerializeField] private float SnowTextureScale = 0.1f;

    [Range(0, 1)]
    [SerializeField] private float BottomThreshold = 0f;
    [Range(0, 1)]
    [SerializeField] private float TopThreshold = 1f;

    [SerializeField] private float DepthLimit = 0f;

    [Range(0, 1)]
    [SerializeField] private float ShadowIntensity = 0.7f;

    CommandBuffer cmd;

    private Color SnowColor = Color.white;

    private Material _material;
    void OnEnable() {
        cmd = new CommandBuffer();
        cmd.SetGlobalTexture("_MyScreenSpaceShadows", BuiltinRenderTextureType.CurrentActive);
        sun.AddCommandBuffer(LightEvent.AfterScreenspaceMask, cmd);

        _material = new Material(Shader.Find("Unlit/SnowShader"));

        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }
    void OnRenderImage(RenderTexture src, RenderTexture dest) {
        Texture shadow = Shader.GetGlobalTexture("_MyScreenSpaceShadows");
        _material.SetMatrix("_CamToWorld", GetComponent<Camera>().cameraToWorldMatrix);
        _material.SetColor("_SnowColor", SnowColor);
        _material.SetFloat("_BottomThreshold", BottomThreshold);
        _material.SetFloat("_TopThreshold", TopThreshold);
        _material.SetTexture("_SnowTex", SnowTexture);
        _material.SetFloat("_SnowTexScale", SnowTextureScale);
        _material.SetFloat("_DepthLimit", DepthLimit);
        _material.SetFloat("_ShadowAmount", ShadowIntensity);
        _material.SetTexture("_ShadowTex", shadow);

        var camera = GetComponent<Camera>();
        _material.SetMatrix("_ViewProjectInverse", (camera.projectionMatrix * camera.worldToCameraMatrix).inverse);

        Graphics.Blit(src, dest, _material);
    }
}
