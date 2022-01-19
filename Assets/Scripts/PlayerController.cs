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
    [SerializeField] private Transform attackPoint;
    private Vector3 attacklocalPosition;
    [SerializeField] private LayerMask enemyLayerMask;
    [SerializeField] private float attackRange;
    [SerializeField] private int attackDamage;

    [SerializeField] private CharacterController controller;
    private bool groundedPlayer;
    private float gravityValue = -9.81f;
    private Vector3 playerVelocity;

    public Vector3 GetRawInput()
    {
        return rawInput;
    }

    private void Awake()
    {
        playerControl = new PlayerControls();
        attacklocalPosition = attackPoint.localPosition;
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
        if (PauseManage.paused)
        {
            return;
        }
        if (!hasDashed)
            _canDash = true;

        
    }

    private void FixedUpdate()
    {
        if (unableToMove)
        {
            if (_canDash && dashTriggered && !attackTriggered) StartCoroutine(Dash());
            if (unableToMove && attackTriggered) StartCoroutine(Attack());
        }

        if (!unableToMove)
        {
            PlayerMovement();
        }
    }


    public void OnDash(InputAction.CallbackContext ctx)
    {
        if (!unableToMove && !dashTriggered)
        {
            unableToMove = true;
            dashTriggered = true;
        }
    }
    public void OnAttack(InputAction.CallbackContext ctx)
    {
        if (!unableToMove && !attackTriggered)
        {
            unableToMove = true;
            attackTriggered = true;
        }
    }


    public void OnMovement(InputAction.CallbackContext ctx)
    {
        rawInput = new Vector3(ctx.ReadValue<Vector2>().x, 0, ctx.ReadValue<Vector2>().y);
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
          //  attackPoint.localPosition = new Vector3(rawInput.x, attackPoint.localPosition.y, attackPoint.localPosition.z);
        }


        playerVelocity.y += gravityValue * Time.fixedDeltaTime;
        controller.Move(playerVelocity * Time.fixedDeltaTime);
    }



    IEnumerator Dash()
    {
        float dashStartTime = 0;
        hasDashed = true;
        unableToMove = true;


        while (dashStartTime < dashLength)
        {
            controller.Move(playerDirection.normalized * dashSpeed * Time.fixedDeltaTime);

            yield return null;
            dashStartTime += Time.fixedDeltaTime;
        }
        dashTriggered = false;
        unableToMove = false;
        yield return new WaitForSeconds(3);
        hasDashed = false;
    }

    IEnumerator Attack()
    {
        GetComponent<PlayerAnimation>().AttackAnimation();
        Collider[] hitEnemies = Physics.OverlapSphere(attackPoint.position, attackRange, enemyLayerMask);

        foreach (Collider enemy in hitEnemies)
        {
            enemy.GetComponent<EnemyDamageHandler>().takeDamage(attackDamage);
        }
        
        attackTriggered = false;
        unableToMove = false;
        hasDashed = false;
        yield return null;
    }



    private void OnDrawGizmosSelected()
    {
        Gizmos.DrawWireSphere(attackPoint.position, attackRange);
    }


}
