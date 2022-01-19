using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderFollowPlayer : MonoBehaviour
{
    public static int PosID = Shader.PropertyToID("_Position");
    public static int sizeID = Shader.PropertyToID("_Size");

    public Material WallMaterial;
    public LayerMask mask;
    [SerializeField] private float maskSize;

    void Update()
    {
        Vector3 dir = Camera.main.transform.position - transform.position;
        Ray ray = new Ray(transform.position, dir.normalized);

        if (Physics.Raycast(ray, 3000, mask))
        {
            WallMaterial.SetFloat(sizeID, maskSize);

        }
        else
        {
            WallMaterial.SetFloat(sizeID, 0);
        }

    }
}
