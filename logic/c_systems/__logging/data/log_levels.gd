extends RefCounted
class_name WL ## stands for Warn Level

## In the order of severity, low -> high

## CUSTOM LEVEL
## only when u know what u r doing
const SILENT := "SILENT"
## print with icon
const WARN := "WARN"
## print with prominent icon! what do u want
const WARN_CRUCIAL := "WARN_CRUCIAL"

## works only in developer build
## not advised to use at all
const ASSERT := "ASSERT"

## ENGINE LEVEL
const PUSH_WARN := "PUSH_WARN"
const PUSH_ERROR := "PUSH_ERROR"
