using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class InWorldSpace : MonoBehaviour
{
    public MeshRenderer meshRenderer;
    // Start is called before the first frame update
    void Start()
    {
        if (Application.isPlaying)
        {
            meshRenderer.material.SetVector("_Point", new Vector4(1.0f, 0.0f, 0.0f, 1.0f));
            meshRenderer.material.SetFloat("_DistanceNear", 10.0f);
            meshRenderer.material.SetColor("_ColorNear", new Color(1.0f, 0.0f, 0.0f));
            meshRenderer.material.SetColor("_ColorFar", new Color(0.0f, 0.0f, 1.0f));
        }
        else
        {
            meshRenderer.sharedMaterial.SetVector("_Point", new Vector4(1.0f, 0.0f, 0.0f, 1.0f));
            meshRenderer.sharedMaterial.SetFloat("_DistanceNear", 10.0f);
            meshRenderer.sharedMaterial.SetColor("_ColorNear", new Color(1.0f, 0.0f, 0.0f));
            meshRenderer.sharedMaterial.SetColor("_ColorFar", new Color(0.0f, 0.0f, 1.0f));
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (Application.isPlaying)
        {
            meshRenderer.material.SetVector("_Point", this.transform.position); // set the shader property
        }
        else
        {
            meshRenderer.sharedMaterial.SetVector("_Point", this.transform.position); // set the shader property
        }
    }
}
