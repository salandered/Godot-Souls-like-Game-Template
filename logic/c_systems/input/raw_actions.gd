extends RefCounted
## 'Actions' stands for Input Action as this term is used by Godot 
## Has nothing to do with SM's actions which this project uses.
class_name RawAction


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
const switch_weapon = "switch_weapon"

# UI

const UI_escape = "UI_escape"
const UI_enter = "UI_enter"

# 
const Unstuck = "Unstuck"

## DEV

# tseries
const t1 = "dev_t1"
const t2 = "dev_t2"
const t3 = "dev_t3"
const t4 = "dev_t4"
const t5 = "dev_t5"
const t6 = "dev_t6"
const t7 = "dev_t7"
const t8 = "dev_t8"

# arrows 
const DEV_speed_down = "DEV_speed_down"
const DEV_speed_up = "DEV_speed_up"


# F 
const DEV_cols = "DEV_cols" # F1
const DEV_CAM_cols = "DEV_CAM_cols" # F2
const DEV_profiler = "DEV_profiler" # F3
const DEV_show_col = "DEV_show_col" # F6
const DEV_force_quit = "DEV_force_quit"
const DEV_fly_mode = "DEV_fly_mode" # F9
const DEV_free_cam = "DEV_free_cam"
const DEV_toggle_fullscreen_1 = "DEV_toggle_fullscreen_1"


# Numpad (KP)
const DEV_KP1 = "DEV_KP1"
const DEV_KP2 = "DEV_KP2"
const DEV_KP3 = "DEV_KP3"
const DEV_KP4 = "DEV_KP4" # ex toggle_nest
const DEV_KP7 = "DEV_KP7"
const DEV_CAM_fov = "DEV_CAM_fov"
const DEV_CAM_cycle = "DEV_CAM_cycle"
const DEV_CAM_cycle_prev = "DEV_CAM_cycle_prev"
const DEV_mouse_mode_switch = "DEV_mouse_mode_switch"


# usual keys temporarily as dev
const DEV_J = "DEV_J"
const DEV_K = "DEV_K"
const DEV_L = "DEV_L"
const DEV_I = "DEV_I"
const DEV_O = "DEV_O"
