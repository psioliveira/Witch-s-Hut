
using UnityEngine;

[RequireComponent(typeof(Animator))]
[RequireComponent(typeof(Rigidbody))]
public class Animation : MonoBehaviour
{
    [SerializeField] private Animator playerAnimator;
    [SerializeField] private PlayerController playerController;


    void Start()
    {
        playerAnimator = GetComponent<Animator>();
        playerController = GetComponent<PlayerController>();
    }



    private void Update()
    {
        UpdateAnimatorVariables();
    }

    private void UpdateAnimatorVariables()
    {
        playerAnimator.SetFloat("Velocity up down", playerController.GetRawInput().z);
        playerAnimator.SetFloat("Velocity left right", playerController.GetRawInput().x);
    }


}
