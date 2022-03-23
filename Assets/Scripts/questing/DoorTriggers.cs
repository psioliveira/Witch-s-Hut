using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoorTriggers : MonoBehaviour
{
    public Quest quest;

    public void Q1Done()
    {
        if (quest.goal.IsReached())
            {
                GetComponent<Animator>().Play("Door 1 Open");
                quest.Complete();
            }
    }
}
