open Bigarray

val get_legal_string : unit -> string
val get_version_major : unit -> int
val get_version_minor : unit -> int
val get_version_revision : unit -> int
val get_compile_flags : unit -> int

type raw_scene
type 'a result = [ `Ok of 'a | `Error of string ]
val import_file : string -> int -> raw_scene result
val import_memory : _ Bigarray.Array1.t -> int -> string -> raw_scene result
val release_scene : raw_scene -> unit
val postprocess_scene : raw_scene -> int -> unit

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
val anim_behaviour_default  : int
val anim_behaviour_constant : int
val anim_behaviour_linear   : int
val anim_behaviour_repeat   : int

type primitive_type = int
val primitive_type_POINT    : int
val primitive_type_LINE     : int
val primitive_type_TRIANGLE : int
val primitive_type_POLYGON  : int

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
val pti_float   : int
val pti_string  : int
val pti_integer : int
val pti_buffer  : int

type texture_op = int
val texture_op_multiply   : int
val texture_op_add        : int
val texture_op_subtract   : int
val texture_op_divide     : int
val texture_op_smooth_add : int
val texture_op_signed_add : int

type texture_map_mode = int
val texture_map_mode_wrap   : int
val texture_map_mode_clamp  : int
val texture_map_mode_decal  : int
val texture_map_mode_mirror : int

type texture_mapping_mode = int
val texture_mapping_uv       : int
val texture_mapping_sphere   : int
val texture_mapping_cylinder : int
val texture_mapping_box      : int
val texture_mapping_plane    : int
val texture_mapping_other    : int

type texture_type = int
val texture_type_none         : int
val texture_type_diffuse      : int
val texture_type_specular     : int
val texture_type_ambient      : int
val texture_type_emissive     : int
val texture_type_height       : int
val texture_type_normals      : int
val texture_type_shininess    : int
val texture_type_opacity      : int
val texture_type_displacement : int
val texture_type_lightmap     : int
val texture_type_reflection   : int
val texture_type_unknown      : int

type shading_mode = int
val shading_mode_flat          : int
val shading_mode_gouraud       : int
val shading_mode_phong         : int
val shading_mode_blinn         : int
val shading_mode_toon          : int
val shading_mode_oren_nayar    : int
val shading_mode_minnaert      : int
val shading_mode_cook_torrance : int
val shading_mode_no_shading    : int
val shading_mode_fresnel       : int

type texture_flags = int
val texture_flags_invert : int
val texture_flags_use_alpha : int
val texture_flags_ignore_alpha : int

type blend_mode = int
val blend_mode_default : int
val blend_mode_additive : int

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
val light_source_type_UNDEFINED   : int
val light_source_type_DIRECTIONAL : int
val light_source_type_POINT       : int
val light_source_type_SPOT        : int

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

val view_scene : raw_scene -> scene
