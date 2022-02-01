using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HUDInput : MonoBehaviour
{
    Animator anim;
    // Start is called before the first frame update
    void Start()
    {
        anim = gameObject.GetComponent<Animator>();
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        if (Input.GetKeyDown(KeyCode.Tab))
        {
            //Hide > Show
            if (anim.GetBool("Shown") == false)
            {
                anim.Play("Show");
                anim.SetBool("Shown", false);
            }
            else
            {
                anim.Play("Hide");
                anim.SetBool("Shown", true);
            }
        }
    }
}
