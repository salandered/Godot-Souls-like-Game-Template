extends RefCounted
class_name WarnLevel

## custom level
const SILENT := "SILENT" ## only when u know what u r doing
const WARN := "WARN"
const WARN_CRUCIAL := "WARN_CRUCIAL"

## only while developing
## not advised to use at all
const ASSERT := "ASSERT"

## engine level
const PUSH_WARNING := "PUSH_WARNING"
const PUSH_ERROR := "PUSH_ERROR"