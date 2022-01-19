using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderFollowPlayer : MonoBehaviour
{
    public static int PosID = Shader.PropertyToID("_Position");
    public static int sizeID = Shader.PropertyToID("_Size");

    public Material WallMaterial;
    public Camera camera;
    public LayerMask mask;

    void Update()
    {
        Vector3 dir = camera.transform.position - transform.position;
        Ray ray = new Ray(transform.position, dir.normalized);

        if (Physics.Raycast(ray, 3000, mask))
        {
            WallMaterial.SetFloat(sizeID, 1);

        }
        else
        {
            WallMaterial.SetFloat(sizeID, 0);
        }

    }
}
