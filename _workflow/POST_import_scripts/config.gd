@tool
extends RefCounted
class_name PIConfig


# collision reparent
const COLLISION_COLLECTION_PREFIXES: Array[String] = ["--col", "-- col", "-col", "- col"]


# material reimport

const REIMP_SUFFIX: String = "_Reimp"

const BASE_MAT_PATH: String = "res://-assets-/materials-shared/"


## case insensitive
const SUBFOLDER_RULES: Dictionary[String, Array] = {
	# specific
	"mines": ["minestrim", "mine_carts", "mines"],
	"baked": [
		"baked",
		"08___Default.001", # Pinga
		"Engel_C", # angels,
		"Wall_Trim",
		"WallTrim",
		"ChurchCeiling",
		],
	"solid": ["_P col", "P orange", "P white", "P sand", "P blue", "P green", "P dark_grey"],
	"different": ["gold", "glass"],

	# usual
	"metal": ["metal", "steel", "iron", "copper", "bronze"],
	"concrete": ["concrete", "cement", "asphalt", "plaster"],
	"rocks-stone": ["rock", "stone"],
	"ground": ["ground", "dirt", "grass", "mud", "sand", "soil", "roots"],
	"wood": ["wood"],
	"fabric": ["fabric", "cloth", "silk", "wool", "leather"],
	
	# no found means would be 'unsorted' or 'baked'
}

const MAT_IGNORE_LIST: Array[String] = ["pixpal", "-skipreimp"]

const ROUGH_SUFFIXES: Array[String] = ["_rough", "_roughness"]

const DIFF_SUFFIXES: Array[String] = ["_diff", "_diffuse", "_albedo", "_col", "_color"]
	
const METAL_SUFFIXES: Array[String] = ["_metal", "_metallic"]
