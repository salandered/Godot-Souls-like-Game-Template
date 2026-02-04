extends RefCounted
class_name WL ## stands for Warn Level

## In the order of severity, low -> high

## CUSTOM LEVEL
## only when u know what u r doing
const SILENT := "SILENT"
## looks more like a usual log print, but goes through the warn print system
## seems redundant but it's often when u need something between SILENT and WARN
## advised to use in utility with "safe_" methods
const INFO := "INFO"
## print with icon
const WARN := "WARN"
## print with prominent icon! what do u want
const WARN_CRUCIAL := "WARN_CRUCIAL"

## works only in developer build
## not advised to use at all
## TODO: consider deleting
const ASSERT := "ASSERT"

## ENGINE LEVEL
## GOOD: allows to see the stack trace. Crucial when some domain agnotic utility reports an error.
## NOTE: lots of logs (like pushing every frame) can stutter the OS.
## BAD (WARNING): when launching game via VS Code (godot-tool), can destroy the OS beyond repair even after closing the app.
##  	reason is unknown, may be win defender problem
const PUSH_WARN := "PUSH_WARN"
const PUSH_ERROR := "PUSH_ERROR"
