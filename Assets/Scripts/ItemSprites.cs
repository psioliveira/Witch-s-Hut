using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemSprites : MonoBehaviour
{
    public static ItemSprites Instance { get; private set; }

    private void Awake()
    {
        Instance = this;
    }

    public Transform itemWorldPrefab;

    public Sprite crystal;
    public Sprite fur;
    public Sprite batWing;
    public Sprite blood;
    public Sprite venom;
    public Sprite Bone;


}
