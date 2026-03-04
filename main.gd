extends Node2D

@onready var state_manager: StateManager2D = $StateManager2D
@onready var rigid_body: RapierRigidBody2D = $RigidBody
@export var use_force: bool = true

@onready var tick_to_load_value: Label = $UI/Control/VBoxContainer/HBoxContainer2/TickToLoadValue
@onready var current_tick_value: Label = $UI/Control/VBoxContainer/HBoxContainer/CurrentTickValue

var saved_states: Dictionary[int, String] = {}
var space: RID
var current_tick: int = 0 : set = _on_set_current_tick
var state_to_load: int = 0 : set = _on_set_state_to_load

func _ready() -> void:
	space = get_viewport().world_2d.space
	PhysicsServer2D.space_set_active(space, false)

func save_state(tick: int) -> void:
	var current_state: String = state_manager.export_state(space, "Json")
	saved_states[tick] = current_state

func load_state(tick: int) -> void:
	if !saved_states.has(tick):
		print("Cannot load state at tick %d" % tick)
		return
	state_manager.import_state(space, saved_states[tick])
	var loaded_state : String = state_manager.export_state(space, "Json")
	if loaded_state != saved_states[tick]:
		print("States should be equal")
		print("Saved state at tick %d :  %s" % [tick,saved_states[tick]])
		print("------------------------------------------------------------------------------------------------------")
		print("Loaded state at tick %d :  %s" % [tick,loaded_state])

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right"):
		current_tick += 1
		if use_force:
			rigid_body.constant_force = Vector2(1000.0, 250)
		RapierPhysicsServer2D.space_step(space, 1/60.0)
		RapierPhysicsServer2D.space_flush_queries(space)
		save_state(current_tick)
	if event.is_action_pressed("ui_up"):
		state_to_load += 1
	if event.is_action_pressed("ui_down"):
		state_to_load -= 1
	if event.is_action_pressed("ui_accept"):
		load_state(state_to_load)


func _on_set_current_tick(new_tick: int) -> void:
	current_tick = new_tick
	current_tick_value.text = str(current_tick)

func _on_set_state_to_load(new_state_to_load: int) -> void:
	if len(saved_states.keys()) <= 0:
		state_to_load = 0
		return
	state_to_load = clampi(new_state_to_load, saved_states.keys().min(), saved_states.keys().max())
	tick_to_load_value.text = str(state_to_load)
