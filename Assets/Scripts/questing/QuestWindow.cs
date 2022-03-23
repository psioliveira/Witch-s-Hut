using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class QuestWindow : MonoBehaviour
{ 
    [SerializeField]
    Animator anim;

    // Update is called once per frame
    public void ToggleQuest()
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
