extends CharacterBody2D

var SPEED = 300.0
const JUMP_VELOCITY = -350.0
var canjump := true
@onready var coyote_timer = $CoyoteTimer as Timer
@export var buffer_time: float = 0.15
@export var coyote_time: float = 0.1
var jump_buffered = false
var buffer_timer = 0.0

func _ready():
	coyote_timer.wait_time = coyote_time

func pular():
	velocity.y = JUMP_VELOCITY

func _physics_process(delta):
	# Adiciona a gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Suporta o "jump buffer".
	if Input.is_action_just_pressed("ui_up"):
		jump_buffered = true
		buffer_timer = buffer_time

	# Diminui o tempo do jump buffer.
	if jump_buffered:
		buffer_timer -= delta
		if buffer_timer <= 0.0:
			jump_buffered = false

	# Suporta o pulo, incluindo o coyote time.
	if jump_buffered and canjump:
		pular()
		jump_buffered = false
		canjump = false

	# Reseta a variável canjump quando pisa no chão.
	if is_on_floor():
		canjump = true
		if not coyote_timer.is_stopped():
			coyote_timer.stop()

	# Adiciona o efeito coyote time.
	if canjump and coyote_timer.is_stopped() and not is_on_floor():
		coyote_timer.start()

	# Lógica de movimentação.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _input(event : InputEvent):
	if event.is_action_pressed("ui_down") and is_on_floor():
		position.y += 1

func _on_coyote_timer_timeout() -> void:
	canjump = false
