using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class HUDInput : MonoBehaviour
{
    [SerializeField]
    Animator anim;

    // Update is called once per frame
    public void ToggleInventory()
    {
        
            //Hide > Show
            if (anim.GetBool("Open") == false)
            {
                anim.SetBool("Open", true);
            }
            else
            {
                anim.SetBool("Open", false);
            }
    }
}
