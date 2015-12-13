(*
  Assimp bindings for OCaml by Frédéric Bour <frederic.bour(_)lakaban.net>
  To the extent possible under law, the person who associated CC0 with
  Assimp bindings for OCaml has waived all copyright and related or neighboring
  rights to Assimp bindings for OCaml.

  You should have received a copy of the CC0 legalcode along with this
  work. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

  Website: https://github.com/def-lkb/assimp
  Assimp "Open Asset Import Library" is released as Open Source under the terms
  of a 3-clause BSD license.
  http://assimp.sourceforge.net/

  Version 0.1, September 2015
*)
open Bigarray

type 'a result = ('a, [`Msg of string]) Result.result

(******************************************)
(** {1 Version informations -- version.h} *)

(** Returns a string with legal copyright and licensing information about Assimp. *)
val get_legal_string : unit -> string

(** Returns the current major version number of Assimp. *)
val get_version_major : unit -> int

(** Returns the current minor version number of Assimp. *)
val get_version_minor : unit -> int

(** Returns the repository revision of the Assimp runtime. *)
val get_version_revision : unit -> int

(** Returns assimp's compile flags. *)
val get_compile_flags : unit -> int

(**********************************)
(** {1 Scene import -- cimport.h} *)

(** There are two types for representing Assimp's scenes.
    [raw_scene] is opaque and managed on C-side.
    After processing it with assimp functions, you can turn it to a
    [scene], which is a plain OCaml value. *)
type raw_scene

(** Reads scene from a file. -- aiImportFile *)
val import_file : string -> int -> raw_scene result

(** Reads scene from a memory buffer. -- aiImportFileFromMemory *)
val import_memory : (_,_,_) Bigarray.Array1.t -> int -> string -> raw_scene result

(** Releases all resources associated with a scene. -- aiReleaseImport *)
val release_scene : raw_scene -> unit

(** Apply post-processing to a scene. -- aiApplyPostProcessing *)
val postprocess_scene : raw_scene -> int -> unit


(*******************************)
(** {1 Basic type definitions} *)

(** An array of 3 floats interpreted as a color *)
type color3 = float array

(** An array of 4 floats interpreted as a color with alpha *)
type color4 = float array

(** An array of 3 floats interpreted as a vector *)
type vec3 = float array

(** An array of 4 floats interpreted as a vector *)
type vec4 = float array

(** An array of 4 floats interpreted as a quaternion *)
type quat = float array

(** An array of 9 floats interpreted as a row-major 3x3 matrix *)
type mat3 = float array

(** An array of 16 floats interpreted as a row-major 4x4 matrix *)
type mat4 = float array

(** A scene node -- from scene.h aiNode *)
type node = {
  node_name: string;         (** The name of the node. *)
  node_transformation: mat4; (** The transformation relative to the node's parent. *)
  node_children: node array; (** The child nodes of this node. *)
  node_meshes: int array;    (** The meshes of this node. (indexed from scene) *)
}

(** Defines how an animation channel behaves outside the defined time range. -- from anim.h aiAnimbehaviour *)
type anim_behaviour = int
val anim_behaviour_default  : int
val anim_behaviour_constant : int
val anim_behaviour_linear   : int
val anim_behaviour_repeat   : int

(** Enumerates the types of geometric primitives supported by Assimp. -- from mesh.h asPrimitiveType *)
type primitive_type = int

(** A point primitive.
    This is just a single vertex in the virtual world, aiFace contains just one index for such a primitive. *)
val primitive_type_POINT    : int

(** A line primitive.
    This is a line defined through a start and an end position. aiFace contains exactly two indices for such a primitive. *)
val primitive_type_LINE     : int

(** A triangular primitive.
    A triangle consists of three indices. *)
val primitive_type_TRIANGLE : int

(** A higher-level polygon with more than 3 edges.
    A triangle is a polygon, but polygon in this context means "all polygons that are not triangles". The "Triangulate"-Step is provided for your convenience, it splits all polygons in triangles (which are much easier to handle). *)
val primitive_type_POLYGON  : int

(** A single face in a mesh, referring to multiple vertices. -- mesh.h aiFace *)
type face = int array

(** NOT IN USE IN ASSIMP v3.1.1.
    An AnimMesh is an attachment to an aiMesh stores per-vertex animations for a particular frame. -- mesh.h aiAnimMesh *)
type anim_mesh = {

  (** Replacement for aiMesh::mVertices *)
  anim_mesh_vertices: vec3 array;

  (** Replacement for aiMesh::mNormals. *)
  anim_mesh_normals: vec3 array;

  (** Replacement for aiMesh::mTangents. *)
  anim_mesh_tangents: vec3 array;

  (** Replacement for aiMesh::mBitangents. *)
  anim_mesh_bitangents: vec3 array;

  (** Replacement for aiMesh::mColors. *)
  anim_mesh_colors: color4 array array;

  (** Replacement for aiMesh::mTextureCoords. *)
  anim_mesh_texture_coords: vec3 array array;

}

(** A single influence of a bone on a vertex. -- mesh.h aiVertexWeight *)
type vertex_weight = {
  vw_id: int;       (** Index of the vertex which is influenced by the bone. *)
  vw_weight: float; (** The strength of the influence in the range (0...1). *)
}

(** A single bone of a mesh. -- mesh.h aiBone *)
type bone = {

  (** The name of the bone. *)
  bone_name: string;

  (** The vertices affected by this bone. *)
  bone_weights: vertex_weight array;

  (** Matrix that transforms from mesh space to bone space in bind pose. *)
  bone_offset: mat4;

}

(** A mesh represents a geometry or model with a single material. -- mesh.h aiMesh *)
type mesh = {

  (** Bitwise combination of the members of the aiPrimitiveType enum. *)
  mesh_type: primitive_type;

  (** Vertex positions. *)
  mesh_vertices: vec3 array;

  (** Vertex normals. *)
  mesh_normals: vec3 array;

  (** Vertex tangents. *)
  mesh_tangents: vec3 array;

  (** Vertex bitangents. *)
  mesh_bitangents: vec3 array;

  (** Vertex color sets. *)
  mesh_colors: color4 array array;

  (** Vertex texture coords, also known as UV channels. *)
  mesh_texture_coords: vec3 array array;

  (** Specifies the number of components for a given UV channel. *)
  mesh_uv_components: int array;

  (** The faces the mesh is constructed from. *)
  mesh_faces: face array;

  (** The number of bones this mesh contains. *)
  mesh_bones: bone array;

  (** Name of the mesh. *)
  mesh_name: string;

  (** NOT IN USE AS OF ASSIMP 3.1.1 *)
  mesh_animations: anim_mesh array;

}

type property_type_info = int
val pti_float   : int
val pti_string  : int
val pti_integer : int
val pti_buffer  : int

(** Defines how the Nth texture of a specific type is combined with the result of all previous layers. -- material.h aiTextureOp *)
type texture_op = int
val texture_op_multiply   : int
val texture_op_add        : int
val texture_op_subtract   : int
val texture_op_divide     : int
val texture_op_smooth_add : int
val texture_op_signed_add : int

(** Defines how UV coordinates outside the [0...1] range are handled. aiTextureMapMode *)
type texture_map_mode = int
val texture_map_mode_wrap   : int
val texture_map_mode_clamp  : int
val texture_map_mode_decal  : int
val texture_map_mode_mirror : int

(** Defines how the mapping coords for a texture are generated. -- texture.h aiTextureMapping *)
type texture_mapping_mode = int
val texture_mapping_uv       : int
val texture_mapping_sphere   : int
val texture_mapping_cylinder : int
val texture_mapping_box      : int
val texture_mapping_plane    : int
val texture_mapping_other    : int

(** Defines the purpose of a texture. -- material.h aiTextureType *)
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

(** Defines all shading models supported by the library. -- material.h aiShadingMode *)
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

(** Defines some mixed flags for a particular texture. -- material.h aiTextureFlags *)
type texture_flags = int
val texture_flags_invert : int
val texture_flags_use_alpha : int
val texture_flags_ignore_alpha : int

(** Defines alpha-blend flags. -- material.h aiBlendMode *)
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

(** Data structure for a material. -- material.h aiMaterial *)
type material = material_property array

(** A time-value pair specifying a certain value for the given time. *)
type 'a key = {
  time: float;
  data: 'a;
}

(** Describes the animation of a single node. -- anim.h aiNodeAnim *)
type node_anim = {

  (** The name of the node affected by this animation. *)
  nanim_name: string;

  (** The position keys of this animation channel. *)
  nanim_positions: vec3 key array;

  (** The rotation keys of this animation channel. *)
  nanim_rotations: quat key array;

  (** The scaling keys of this animation channel. *)
  nanim_scaling: vec3 key array;

}

(** Describes vertex-based animations for a single mesh or a group of meshes. -- anim.h aiMeshAnim *)
type mesh_anim = {

  (* Name of the mesh to be animated. *)
  manim_name: string;

  (* Key frames of the animation. *)
  manim_keys: int key array;

}

(** An animation consists of keyframe data for a number of nodes. -- anim.h aiAnimation *)
type animation = {

  (** The name of the animation. *)
  anim_name: string;

  (** Duration of the animation in ticks. *)
  anim_duration: float;

  (** Ticks per second. *)
  anim_tickspersecond: float;

  (** The node animation channels. *)
  anim_channels: node_anim array;

  (** The mesh animation channels. *)
  anim_mesh_channels: mesh_anim array;

}

(** A hint from the loader to make it easier for applications to determine the type of embedded compressed textures. -- texture.h *)
type hint = string

(** Raw image content. *)
type buffer = (int, int8_unsigned_elt, c_layout) Array1.t


type image = {

  (** Width of the texture, in pixels. *)
  width: int;

  (** Height of the texture, in pixels. *)
  height: int;

  (** See [hint] type. *)
  hint: hint;

  (** Data of the texture. *)
  data: buffer;
}

(** Helper structure to describe an embedded texture. -- texture.h aiTexture
    Normally textures are contained in external files but some file formats embed them directly in the model file. There are two types of embedded textures: *)
type texture =
  | (** Uncompressed textures. The color data is given in an uncompressed format. *)
    Decoded of image
  | (** Compressed textures stored in a file format like png or jpg. The raw file bytes are given so the application must utilize an image decoder (e.g. DevIL) to get access to the actual color data. *)
    Raw of hint * buffer

(** Enumerates all supported types of light sources. -- light.h aiLightSourceType *)
type light_source_type = int
val light_source_type_UNDEFINED   : int
val light_source_type_DIRECTIONAL : int
val light_source_type_POINT       : int
val light_source_type_SPOT        : int

(** Helper structure to describe a light source. -- light.h aiLight *)
type light = {

  (** The name of the light source. *)
  light_name: string;

  (** The type of the light source. *)
  light_source_type: light_source_type;

  (** Position of the light source in space. *)
  light_position: vec3;

  (** Direction of the light source in space. *)
  light_direction: vec3;

  (** Constant light attenuation factor. *)
  light_attenuation_constant: float;

  (** Linear light attenuation factor. *)
  light_attenuation_linear: float;

  (** Quadratic light attenuation factor. *)
  light_attenuation_quadratic: float;

  (** Diffuse color of the light source. *)
  light_color_diffuse: color3;

  (** Specular color of the light source. *)
  light_color_specular: color3;

  (** Ambient color of the light source. *)
  light_color_ambient: color3;

  (** Inner angle of a spot light's light cone. *)
  light_angle_inner_cone: float;

  (** Outer angle of a spot light's light cone. *)
  light_angle_outer_cone: float;

}

(** Helper structure to describe a virtual camera. -- camera.h aiCamera *)
type camera = {

  (** The name of the camera. *)
  camera_name: string;

  (** Position of the camera relative to the coordinate space defined by the corresponding node. *)
  camera_position: vec3;

  (** 'Up' - vector of the camera coordinate system relative to the coordinate space defined by the corresponding node. *)
  camera_up: vec3;

  (** 'LookAt' - vector of the camera coordinate system relative to the coordinate space defined by the corresponding node. *)
  camera_look_at: vec3;

  (** Half horizontal field of view angle, in radians. *)
  camera_horizontal_fov: float;

  (** Distance of the near clipping plane from the camera. *)
  camera_clip_plane_near: float;

  (** Distance of the far clipping plane from the camera. *)
  camera_clip_plane_far: float;

  (** Screen aspect ratio. *)
  camera_aspect: float;

}

(** The root structure of the imported data. -- scene.h aiScene *)
type scene = {

  (** Any combination of the AI_SCENE_FLAGS_XXX flags. *)
  scene_flags: int;

  (** The root node of the hierarchy. *)
  scene_root: node;

  (** The array of meshes. *)
  scene_meshes: mesh array;

  (** The array of materials. *)
  scene_materials: material array;

  (** The array of animations. *)
  scene_animations: animation array;

  (** The array of embedded textures. *)
  scene_textures: texture array;

  (** The array of light sources. *)
  scene_lights: light array;

  (** The array of cameras. *)
  scene_cameras: camera array;

}

(** Turn an opaque [raw_scene] into a [scene] value. *)
val view_scene : raw_scene -> scene
