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

    private float actualValue;

    private void Awake()
    {
        actualValue = maskSize;
    }
    void Update()
    {
        Vector3 dir = Camera.main.transform.position - transform.position;
        Ray ray = new Ray(transform.position, dir.normalized);

        if (Physics.Raycast(ray, 300, mask))
        {
            if (actualValue < maskSize)
            {
                actualValue += 3*Time.deltaTime;
            }

            WallMaterial.SetFloat(sizeID, actualValue);

        }
        else
        {
            if (actualValue < 0)
            {
                WallMaterial.SetFloat(sizeID, 0);
            }

            else
            {
                actualValue -= 3*Time.deltaTime;
                WallMaterial.SetFloat(sizeID, actualValue);
            }
        }

    }
}
