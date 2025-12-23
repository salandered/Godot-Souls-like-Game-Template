@tool
extends RefCounted
class_name PIConfig


# collision reparent
const COLLISION_COLLECTION_PREFIXES = ["--col", "-- col", "-col", "- col"]


# material reimport

const REIMP_SUFFIX = "_Reimp"

const BASE_MAT_PATH = "res://-assets-/materials-shared/"


## case insensitive
const SUBFOLDER_RULES = {
	# specific
	"mines": ["minestrim", "mine_carts", "mines"],
	"baked": [
		"baked",
		"08___Default.001", # Pinga
		"Engel_C" # angels
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
	
	# no found means would be 'unsorted'
}

const MAT_IGNORE_LIST = ["pixpal", "-skipreimp"]

const ROUGH_SUFFIXES = ["_rough", "_roughness"]

const DIFF_SUFFIXES = ["_diff", "_diffuse", "_albedo", "_col", "_color"]
	
const METAL_SUFFIXES = ["_metal", "_metallic"]
