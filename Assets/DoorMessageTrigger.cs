using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class DoorMessageTrigger : MonoBehaviour
{
    void Update()
    {
      GetComponent<Animator>().Play("Door message 1");
    }
}
