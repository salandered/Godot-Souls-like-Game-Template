@tool
extends RefCounted
class_name PIConfig


# collision reparent
const COLLISION_COLLECTION_PREFIXES = ["--col", "-- col", "-col", "- col"]


# material reimport

const REIMP_SUFFIX = "_Reimp"

const BASE_MAT_PATH = "res://-assets-/materials-shared/"


const SUBFOLDER_RULES = {
	# specific
	"mines": ["minestrim"],
	"different": ["gold"],
	"collage": ["baked"],

	# usual
	"metal": ["metal", "steel", "iron", "copper"],
	"concrete": ["concrete", "cement", "asphalt"],
	"ground": ["ground", "dirt", "grass", "mud", "sand", "soil"],
	"rocks-stone": ["rock", "stone"],
	"wood": ["wood"],
	"fabric": ["fabric", "cloth", "silk", "wool", "leather"],

	# no found means would be 'unsorted'
}

const MAT_IGNORE_LIST = ["pixpal", "-skipreimp"]

const ROUGH_SUFFIXES = ["_rough", "_roughness"]

const DIFF_SUFFIXES = ["_diff", "_diffuse", "_albedo", "_col", "_color"]
	
const METAL_SUFFIXES = ["_metal", "_metallic"]
