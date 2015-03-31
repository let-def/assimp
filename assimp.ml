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

type primitive_type = int

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
