open Bigarray

external get_legal_string : unit -> string = "ml_aiGetLegalString"
external get_version_major : unit -> int = "ml_aiGetVersionMajor"
external get_version_minor : unit -> int = "ml_aiGetVersionMinor"
external get_version_revision : unit -> int = "ml_aiGetVersionRevision"
external get_compile_flags : unit -> int = "ml_aiGetCompileFlags"

type raw_scene
type 'a result = [ `Ok of 'a | `Error of string ]
external import_file : string -> int -> raw_scene result = "ml_aiImportFile"
external import_memory : _ Bigarray.Array1.t -> int -> string -> raw_scene result = "ml_aiImportFileFromMemory"
external release_scene : raw_scene -> unit = "ml_aiScene_release"
external postprocess_scene : raw_scene -> int -> unit = "ml_aiApplyPostProcessing"

type color3 = float array
type color4 = float array
type vec3 = float array
type vec4 = float array
type quat = float array
type mat3 = float array
type mat4 = float array

type node = {
  node_name: string;
  node_transformation: mat4;
  node_children: node array;
  node_meshes: int array;
}

type anim_behaviour = int
let anim_behaviour_default  = 0
let anim_behaviour_constant = 1
let anim_behaviour_linear   = 2
let anim_behaviour_repeat   = 3

type primitive_type = int
let primitive_type_POINT    = 1
let primitive_type_LINE     = 2
let primitive_type_TRIANGLE = 4
let primitive_type_POLYGON  = 8

type anim_mesh = {
  anim_mesh_vertices: vec3 array;
  anim_mesh_normals: vec3 array;
  anim_mesh_tangents: vec3 array;
  anim_mesh_bitangents: vec3 array;
  anim_mesh_colors: color4 array array;
  anim_mesh_texture_coords: vec3 array array;
}

type face = int array

type vertex_weight = {
  vw_id: int;
  vw_weight: float;
}

type bone = {
  bone_name: string;
  bone_weights: vertex_weight array;
  bone_offset: mat4;
}

type mesh = {
  mesh_type: primitive_type;
  mesh_vertices: vec3 array;
  mesh_normals: vec3 array;
  mesh_tangents: vec3 array;
  mesh_bitangents: vec3 array;
  mesh_colors: color4 array array;
  mesh_texture_coords: vec3 array array;
  mesh_uv_components: int array;
  mesh_faces: face array;
  mesh_bones: bone array;
  mesh_name: string;
  mesh_animations: anim_mesh array;
}

type property_type_info = int
let pti_float   = 1
let pti_string  = 3
let pti_integer = 4
let pti_buffer  = 5

type texture_op = int
let texture_op_multiply   = 0
let texture_op_add        = 1
let texture_op_subtract   = 2
let texture_op_divide     = 3
let texture_op_smooth_add = 4
let texture_op_signed_add = 5

type texture_map_mode = int
let texture_map_mode_wrap   = 0
let texture_map_mode_clamp  = 1
let texture_map_mode_decal  = 3
let texture_map_mode_mirror = 2

type texture_mapping_mode = int
let texture_mapping_uv       = 0
let texture_mapping_sphere   = 1
let texture_mapping_cylinder = 2
let texture_mapping_box      = 3
let texture_mapping_plane    = 4
let texture_mapping_other    = 5

type texture_type = int
let texture_type_none         = 0
let texture_type_diffuse      = 1
let texture_type_specular     = 2
let texture_type_ambient      = 3
let texture_type_emissive     = 4
let texture_type_height       = 5
let texture_type_normals      = 6
let texture_type_shininess    = 7
let texture_type_opacity      = 8
let texture_type_displacement = 9
let texture_type_lightmap     = 10
let texture_type_reflection   = 11
let texture_type_unknown      = 12

type shading_mode = int
let shading_mode_flat          = 1
let shading_mode_gouraud       = 2
let shading_mode_phong         = 3
let shading_mode_blinn         = 4
let shading_mode_toon          = 5
let shading_mode_oren_nayar    = 6
let shading_mode_minnaert      = 7
let shading_mode_cook_torrance = 8
let shading_mode_no_shading    = 9
let shading_mode_fresnel       = 10

type texture_flags = int
let texture_flags_invert = 1
let texture_flags_use_alpha = 2
let texture_flags_ignore_alpha = 4

type blend_mode = int
let blend_mode_default = 0
let blend_mode_additive = 1


type material_property = {
  prop_key: string;
  prop_semantic: int;
  prop_index: int;
  prop_type: property_type_info;
  prop_data: string;
}

type material = material_property array

type 'a key = {
  time: float;
  data: 'a;
}


type node_anim = {
  nanim_name: string;
  nanim_positions: vec3 key array;
  nanim_rotations: quat key array;
  nanim_scaling: vec3 key array;
}

type mesh_anim = {
  manim_name: string;
  manim_keys: int key array;
}

type animation = {
  anim_name: string;
  anim_duration: float;
  anim_tickspersecond: float;
  anim_channels: node_anim array;
  anim_mesh_channels: mesh_anim array;
}

type hint = string

type buffer = (int, int8_unsigned_elt, c_layout) Array1.t
type image = {
  width: int;
  height: int;
  hint: hint;
  data: buffer;
}

type texture =
  | Decoded of image
  | Raw of hint * buffer

type light_source_type = int
let light_source_type_UNDEFINED   = 0
let light_source_type_DIRECTIONAL = 1
let light_source_type_POINT       = 2
let light_source_type_SPOT        = 3

type light = {
  light_name: string;
  light_source_type: light_source_type;
  light_position: vec3;
  light_direction: vec3;
  light_attenuation_constant: float;
  light_attenuation_linear: float;
  light_attenuation_quadratic: float;
  light_color_diffuse: color3;
  light_color_specular: color3;
  light_color_ambient: color3;
  light_angle_inner_cone: float;
  light_angle_outer_cone: float;
}

type camera = {
  camera_name: string;
  camera_position: vec3;
  camera_up: vec3;
  camera_look_at: vec3;
  camera_horizontal_fov: float;
  camera_clip_plane_near: float;
  camera_clip_plane_far: float;
  camera_aspect: float;
}

type scene = {
  scene_flags: int;
  scene_root: node;
  scene_meshes: mesh array;
  scene_materials: material array;
  scene_animations: animation array;
  scene_textures: texture array;
  scene_lights: light array;
  scene_cameras: camera array;
}

external view_scene : raw_scene -> scene = "ml_aiScene_view"
