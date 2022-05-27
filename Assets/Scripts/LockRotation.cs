using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LockRotation : MonoBehaviour
{
    [SerializeField] bool alsoLockPosition;

    private Quaternion initialRotation;
    private Vector3    initialPositionOffset;

    // Start is called before the first frame update
    void Awake()
    {
        initialRotation = transform.rotation;
        initialPositionOffset = transform.position - transform.parent.position;
    }

    // Update is called once per frame
    void Update()
    {
        transform.rotation = initialRotation;
        if (alsoLockPosition)
        {
            transform.position = transform.parent.position + initialPositionOffset;
        }
    }
}
