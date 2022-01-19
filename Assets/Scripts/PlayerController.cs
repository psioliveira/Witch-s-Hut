using PlayerControl;
using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{

    private PlayerControls playerControl;

    [SerializeField] private float playerSpeed = 30;
    private Vector3 rawInput;


    [SerializeField] private float dashSpeed = 15f;
    [SerializeField] private float dashLength = .3f;
    [SerializeField] private bool unableToMove = false;
    [SerializeField] private bool hasDashed = false;
    [SerializeField] private Vector3 playerDirection;
    [SerializeField] private bool _canDash = true;
    private bool dashTriggered;

    private bool attackTriggered;

    [SerializeField] private int attackDamage = 10;


    private Animator playerAnimator;
    [SerializeField] private CharacterController controller;
    private bool groundedPlayer;
    private float gravityValue = -9.81f;
    private Vector3 playerVelocity;



    private void Awake()
    {
        playerControl = new PlayerControls();
    }

    void Start()
    {
        playerAnimator = GetComponent<Animator>();
    }
    private void OnEnable()
    {
        playerControl.Enable();
    }

    private void OnDisable()
    {
        playerControl.Disable();
    }

    private void Update()
    {
        if (!hasDashed)
            _canDash = true;
        UpdateAnimatorVariables();


    }

    private void FixedUpdate()
    {
        if (!unableToMove)
        {
            PlayerMovement();
        }
    }

    private void UpdateAnimatorVariables()
    {
        if (rawInput != Vector3.zero && !unableToMove)
        {
            playerAnimator.SetFloat("Velocity up down", rawInput.z);
            playerAnimator.SetFloat("Velocity left right", rawInput.x);
        }

    }
    public void OnDash(InputAction.CallbackContext ctx)
    {
        if (!PauseManage.paused && ctx.started && _canDash && !unableToMove && !attackTriggered) StartCoroutine(Dash());
     
    }
    public void OnAttack(InputAction.CallbackContext ctx)
    {
        if (!PauseManage.paused && ctx.started && !unableToMove && !dashTriggered)
        {
            StartCoroutine(Attack());
        }
    }


    public void OnMovement(InputAction.CallbackContext ctx)
    {
        if (!PauseManage.paused )
        {
            rawInput = new Vector3(ctx.ReadValue<Vector2>().x, 0, ctx.ReadValue<Vector2>().y);   
        }
        
    }

    private void PlayerMovement()
    {
        groundedPlayer = controller.isGrounded;
        if (groundedPlayer && playerVelocity.y < 0)
        {
            playerVelocity.y = 0f;
        }
        if (rawInput.x != 0 || rawInput.z != 0)
        {
            playerDirection = rawInput;
            controller.Move(rawInput * Time.fixedDeltaTime * playerSpeed);
            if (!unableToMove) playerAnimator.SetBool("Moving", true);
            else { playerAnimator.SetBool("Moving", false); }
        }
        else { playerAnimator.SetBool("Moving", false); }


        playerVelocity.y += gravityValue * Time.fixedDeltaTime;
        controller.Move(playerVelocity * Time.fixedDeltaTime);
    }



    IEnumerator Dash()
    {
        float dashStartTime = 0;
        hasDashed = true;
        unableToMove = true;
        dashTriggered = true;
        playerAnimator.SetBool("Dashing", hasDashed);
        while (dashStartTime < dashLength)
        {
            controller.Move(playerDirection.normalized * dashSpeed * Time.fixedDeltaTime);

            yield return null;
            dashStartTime += Time.fixedDeltaTime;
        }
        yield return null;
        yield return new WaitForSeconds(0.001f);
        dashTriggered = false;
        unableToMove = false;
        hasDashed = false;
        playerAnimator.SetBool("Dashing", hasDashed);
        yield return null;
    }

    private IEnumerator Attack()
    {
        unableToMove = true;
        attackTriggered = true;
        playerAnimator.SetTrigger("Attack");
        yield return null;

        attackTriggered = false;
        
        yield return new WaitForSeconds(.3f);
        hasDashed = false;
        unableToMove = false;
        yield return null;

    }



}
