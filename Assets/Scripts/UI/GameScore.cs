using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu]
public class GameScore : ScriptableObject
{
    [SerializeField]
    private float val;
    public float Value
    {
        get { return val; }
        set { val = value; }
    }
    
    
}
