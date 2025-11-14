extends RefCounted
## 'Actions' stands for Input Action as this term is used by Godot 
## Has nothing to do with SM's actions which this project uses.
class_name RawAction

## slots

const slot_1 = "slot_1"
const slot_2 = "slot_2"
const slot_3 = "slot_3"
const slot_4 = "slot_4"


## loco
# wasd
const move_left = "move_left"
const move_right = "move_right"
const move_forward = "move_forward"
const move_back = "move_back"

# move 
const sprint = "sprint"
const jump = "jump"

# attack
const light_attack = "light_attack"
const heavy_attack = "heavy_attack"

# interact
const lock_target = "lock_target"
const interact = "interact"

# other
const wheel_up = "wheel_up"
const wheel_down = "wheel_down"

# UI

const UI_menu = "UI_menu"
const UI_esc = "UI_esc"
const UI_enter = "UI_enter"


## DEV

# tseries
const t1 = "t1"
const t2 = "t2"
const t3 = "t3"
const t4 = "t4"
const t5 = "t5"
const t6 = "t6"
const t7 = "t7"
const t8 = "t8"

# arrows 
const DEV_speed_down = "DEV_speed_down"
const DEV_speed_up = "DEV_speed_up"

# numabers
const DEV_8 = "DEV_8"
const DEV_9 = "DEV_9"
const DEV_mouse_mode_switch = "DEV_mouse_mode_switch"

# F 
const DEV_F2 = "DEV_F2"
const DEV_CAM_cols = "DEV_CAM_cols"
const DEV_cols = "DEV_cols"
const DEV_force_quit = "DEV_force_quit"
const DEV_toggle_fullscreen_1 = "DEV_toggle_fullscreen_1"
const DEV_fly_mode = "DEV_fly_mode"
const DEV_toggle_fullscreen_2 = "DEV_toggle_fullscreen_2"


# Numpad (KP)
const DEV_KP1 = "DEV_KP1"
const DEV_KP2 = "DEV_KP2"
const DEV_KP3 = "DEV_KP3"
const DEV_toggle_nest = "DEV_toggle_nest"
const DEV_unstuck = "DEV_unstuck"
const DEV_awake_enemy = "DEV_awake_enemy"
const DEV_KP7 = "DEV_KP7"
const DEV_CAM_fov = "DEV_CAM_fov"
const DEV_CAM_cycle = "DEV_CAM_cycle"
const DEV_CAM_cycle_prev = "DEV_CAM_cycle_prev"


# usual keys temporarily as dev
const DEV_H = "DEV_H"
const DEV_J = "DEV_J"
const DEV_K = "DEV_K"
const DEV_L = "DEV_L"
const DEV_I = "DEV_I"
const DEV_O = "DEV_O"
