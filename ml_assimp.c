#include <assert.h>
#include <stdio.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/bigarray.h>
#include <caml/custom.h>
#include <caml/fail.h>

#include <assimp/scene.h>
#include <assimp/cimport.h>
#include <assimp/version.h>

static value Val_pair(value a, value b)
{
  CAMLparam2(a, b);
  CAMLlocal1(ret);

  ret = caml_alloc(2, 0);
  Store_field(ret, 0, a);
  Store_field(ret, 0, b);

  CAMLreturn(ret);
}

static value make_ok(value v)
{
  CAMLparam1(v);
  // (Obj.magic `Ok : int)
  CAMLreturn(Val_pair(Val_int(17724), v));
}

static value make_error(const char *msg)
{
  CAMLparam0();
  CAMLlocal1(str);
  str = caml_copy_string(msg);
  // (Obj.magic `Error : int)
  CAMLreturn(Val_pair(Val_int(106380200), str));
}

static value import_floats(float *v, int n)
{
  CAMLparam0();
  CAMLlocal1(ret);

  ret = caml_alloc(n * Double_wosize, Double_array_tag);

  int i;
  for (i = 0; i < n; ++i)
    Store_double_field(ret, i, v[i]);

  CAMLreturn(ret);
}

static value import_integers(unsigned int *arr, unsigned int len)
{
  CAMLparam0();
  CAMLlocal1(ret);

  ret = caml_alloc(len, 0);
  int i;
  for (i = 0; i < len; ++i)
    Store_field(ret, i, Val_int(arr[i]));

  CAMLreturn(ret);
}

static value import_array(value (*f)(void *), size_t ofs, void *start, size_t n)
{
  CAMLparam0();
  CAMLlocal1(ret);

  if (start)
  {
    ret = caml_alloc(n, 0);
    int i;
    char *ptr = start;
    for (i = 0; i < n; ++i)
    {
      Store_field(ret, i, f((void*)ptr));
      ptr += ofs;
    }
  }
  else
  {
    ret = caml_alloc(0, 0);
  }

  CAMLreturn(ret);
}

static value import_arrayp(value (*f)(void *), void **start, size_t n)
{
  CAMLparam0();
  CAMLlocal1(ret);

  if (start)
  {
    ret = caml_alloc(n, 0);
    int i;
    for (i = 0; i < n; ++i)
    {
      Store_field(ret, i, f(start[i]));
    }
  }
  else
  {
    ret = caml_alloc(0, 0);
  }

  CAMLreturn(ret);
}

#define import_array(ty,start,n) \
  import_array((value (*)(void *))Val_##ty, sizeof(struct ty), start, n)
#define import_arrayp(ty,start,n) \
  import_arrayp((value (*)(void *))Val_##ty, (void**)start, n)



/* Basic types */

value Val_aiColor3D(struct aiColor3D *color)
{
  return import_floats(&color->r, 3);
}

value Val_aiColor4D(struct aiColor4D *color)
{
  return import_floats(&color->r, 4);
}

value Val_aiVector2D(struct aiVector2D *v)
{
  return import_floats(&v->x, 2);
}

value Val_aiVector3D(struct aiVector3D *v)
{
  return import_floats(&v->x, 3);
}

value Val_aiQuaternion(struct aiQuaternion *q)
{
  return import_floats(&q->w, 4);
}

value Val_aiMatrix3x3(struct aiMatrix3x3 *m)
{
  return import_floats(&m->a1, 9);
}

value Val_aiMatrix4x4(struct aiMatrix4x4 *m)
{
  return import_floats(&m->a1, 16);
}

value Val_aiPlane(struct aiPlane *plane)
{
  return import_floats(&plane->a, 4);
}

value Val_aiRay(struct aiRay *ray)
{
  return Val_pair(Val_aiVector3D(&ray->pos), Val_aiVector3D(&ray->dir));
}

static value caml_import_string(void *data, size_t n)
{
  CAMLparam0();
  CAMLlocal1(ret);

  ret = caml_alloc_string(n);
  memcpy(String_val(ret), data, n);

  CAMLreturn(ret);
}

value Val_aiString(struct aiString *string)
{
  return caml_import_string(&string->data[0], string->length);
}

value Val_aiMemoryInfo(struct aiMemoryInfo *info)
{
  CAMLparam0();
  CAMLlocal1(ret);

  ret = caml_alloc(8, 0);
  Store_field(ret, 0, Val_int(info->textures));
  Store_field(ret, 1, Val_int(info->materials));
  Store_field(ret, 2, Val_int(info->meshes));
  Store_field(ret, 3, Val_int(info->nodes));
  Store_field(ret, 4, Val_int(info->animations));
  Store_field(ret, 5, Val_int(info->cameras));
  Store_field(ret, 6, Val_int(info->lights));
  Store_field(ret, 7, Val_int(info->total));

  CAMLreturn(ret);
}

/* Animation */

static value import_key(double mTime, value payload)
{
  CAMLparam1(payload);
  CAMLlocal1(ret);

  ret = caml_alloc(2, 0);
  Store_field(ret, 0, caml_copy_double(mTime));
  Store_field(ret, 1, payload);

  CAMLreturn(ret);
}

value Val_aiVectorKey(struct aiVectorKey* x)
{
  return import_key(x->mTime, Val_aiVector3D(&x->mValue));
}

value Val_aiQuatKey(struct aiQuatKey* x)
{
  return import_key(x->mTime, Val_aiQuaternion(&x->mValue));
}

value Val_aiMeshKey(struct aiMeshKey* x)
{
  return import_key(x->mTime, Val_int(x->mValue));
}

#define Val_aiAnimBehaviour Val_int

value Val_aiNodeAnim(struct aiNodeAnim *anim)
{
  CAMLparam0();
  CAMLlocal1(ret);

  ret = caml_alloc(6, 0);
  Store_field(ret, 0, Val_aiString(&anim->mNodeName));
  Store_field(ret, 1, import_array(aiVectorKey, anim->mPositionKeys, anim->mNumPositionKeys));
  Store_field(ret, 2, import_array(aiQuatKey, anim->mRotationKeys, anim->mNumRotationKeys));
  Store_field(ret, 3, import_array(aiVectorKey, anim->mScalingKeys, anim->mNumScalingKeys));
  Store_field(ret, 4, Val_aiAnimBehaviour(anim->mPreState));
  Store_field(ret, 5, Val_aiAnimBehaviour(anim->mPostState));

  CAMLreturn(ret);
}

value Val_aiMeshAnim(struct aiMeshAnim *anim)
{
  CAMLparam0();
  CAMLlocal1(ret);

  ret = caml_alloc(2, 0);
  Store_field(ret, 0, Val_aiString(&anim->mName));
  Store_field(ret, 1, import_array(aiMeshKey, anim->mKeys, anim->mNumKeys));

  CAMLreturn(ret);
}

value Val_aiAnimation(struct aiAnimation *anim)
{
  CAMLparam0();
  CAMLlocal1(ret);

  ret = caml_alloc(5, 0);
  Store_field(ret, 0, Val_aiString(&anim->mName));
  Store_field(ret, 1, caml_copy_double(anim->mDuration));
  Store_field(ret, 2, caml_copy_double(anim->mTicksPerSecond));
  Store_field(ret, 3, import_arrayp(aiNodeAnim, anim->mChannels, anim->mNumChannels));
  Store_field(ret, 4, import_arrayp(aiMeshAnim, anim->mMeshChannels, anim->mNumMeshChannels));

  CAMLreturn(ret);
}

/* Camera */

value Val_aiCamera(struct aiCamera *cam)
{
  CAMLparam0();
  CAMLlocal1(ret);

  ret = caml_alloc(8, 0);

  Store_field(ret, 0, Val_aiString(&cam->mName));
  Store_field(ret, 1, Val_aiVector3D(&cam->mPosition));
  Store_field(ret, 2, Val_aiVector3D(&cam->mUp));
  Store_field(ret, 3, Val_aiVector3D(&cam->mLookAt));

  Store_field(ret, 4, caml_copy_double(cam->mHorizontalFOV));
  Store_field(ret, 5, caml_copy_double(cam->mClipPlaneNear));
  Store_field(ret, 6, caml_copy_double(cam->mClipPlaneFar));
  Store_field(ret, 7, caml_copy_double(cam->mAspect));

  CAMLreturn(ret);
}

/* Light */

#define Val_aiLightSourceType Val_int

value Val_aiLight(struct aiLight *light)
{
  CAMLparam0();
  CAMLlocal1(ret);

  ret = caml_alloc(12, 0);

  Store_field(ret, 0, Val_aiString(&light->mName));

  Store_field(ret, 1, Val_aiLightSourceType(&light->mType));
  Store_field(ret, 2, Val_aiVector3D(&light->mPosition));
  Store_field(ret, 3, Val_aiVector3D(&light->mDirection));

  Store_field(ret, 4, caml_copy_double(light->mAttenuationConstant));
  Store_field(ret, 5, caml_copy_double(light->mAttenuationLinear));
  Store_field(ret, 6, caml_copy_double(light->mAttenuationQuadratic));

  Store_field(ret, 7, Val_aiColor3D(&light->mColorDiffuse));
  Store_field(ret, 8, Val_aiColor3D(&light->mColorSpecular));
  Store_field(ret, 9, Val_aiColor3D(&light->mColorAmbient));

  Store_field(ret, 10, caml_copy_double(light->mAngleInnerCone));
  Store_field(ret, 11, caml_copy_double(light->mAngleOuterCone));

  CAMLreturn(ret);
}

/* Material */

#define Val_aiTextureOp Val_int
#define Val_aiTextureMapMode Val_int
#define Val_aiTextureMapping Val_int
#define Val_aiTextureType Val_int
#define Val_aiShadingMode Val_int
#define Val_aiTextureFlags Val_int
#define Val_aiBlendMode Val_int

value Val_aiUVTransform(struct aiUVTransform *trans)
{
  CAMLparam0();
  CAMLlocal1(ret);

  ret = caml_alloc(3, 0);

  Store_field(ret, 0, Val_aiVector2D(&trans->mTranslation));
  Store_field(ret, 1, Val_aiVector2D(&trans->mScaling));
  Store_field(ret, 2, caml_copy_double(trans->mRotation));

  CAMLreturn(ret);
}

#define Val_aiPropertyTypeInfo Val_int

value Val_aiMaterialProperty(struct aiMaterialProperty *mat)
{
  CAMLparam0();
  CAMLlocal1(ret);

  ret = caml_alloc(5, 0);

  Store_field(ret, 0, Val_aiString(&mat->mKey));
  Store_field(ret, 1, Val_int(mat->mSemantic));
  Store_field(ret, 2, Val_int(mat->mIndex));
  Store_field(ret, 3, Val_aiPropertyTypeInfo(mat->mType));
  Store_field(ret, 4, caml_import_string(mat->mData, mat->mDataLength));

  CAMLreturn(ret);
}

value Val_aiMaterial(struct aiMaterial *mat)
{
  return import_arrayp(aiMaterialProperty, mat->mProperties, mat->mNumProperties);
}

/* Mesh */

value Val_aiFace(struct aiFace *face)
{
  return import_integers(face->mIndices, face->mNumIndices);
}

value Val_aiVertexWeight(struct aiVertexWeight *weight)
{
  CAMLparam0();
  CAMLlocal1(ret);

  ret = caml_alloc(2, 0);
  Store_field(ret, 0, Val_int(weight->mVertexId));
  Store_field(ret, 1, caml_copy_double(weight->mWeight));

  CAMLreturn(ret);
}

value Val_aiBone(struct aiBone *bone)
{
  CAMLparam0();
  CAMLlocal1(ret);

  ret = caml_alloc(3, 0);
  Store_field(ret, 0, Val_aiString(&bone->mName));
  Store_field(ret, 1, import_arrayp(aiVertexWeight, bone->mWeights, bone->mNumWeights));
  Store_field(ret, 2, Val_aiMatrix4x4(&bone->mOffsetMatrix));

  CAMLreturn(ret);
}

#define Val_aiPrimitiveType Val_int

value Val_animMesh(struct aiAnimMesh *anim)
{
  CAMLparam0();
  CAMLlocal2(ret, tmp);

  assert (AI_MAX_NUMBER_OF_COLOR_SETS == 8);
  assert (AI_MAX_NUMBER_OF_TEXTURECOORDS == 8);
  ret = caml_alloc(6, 0);
  Store_field(ret, 0, import_array(aiVector3D, anim->mVertices, anim->mNumVertices));
  Store_field(ret, 1, import_array(aiVector3D, anim->mNormals, anim->mNumVertices));
  Store_field(ret, 2, import_array(aiVector3D, anim->mTangents, anim->mNumVertices));
  Store_field(ret, 3, import_array(aiVector3D, anim->mBitangents, anim->mNumVertices));

  int i;
  tmp = caml_alloc(8, 0);
  for (i = 0; i < 8; ++i)
    Store_field(tmp, i, import_array(aiColor4D, anim->mColors[i], anim->mNumVertices));
  Store_field(ret, 4, tmp);

  tmp = caml_alloc(8, 0);
  for (i = 0; i < 8; ++i)
    Store_field(tmp, i, import_array(aiVector3D, anim->mTextureCoords[i], anim->mNumVertices));
  Store_field(ret, 5, tmp);

  CAMLreturn(ret);
}

value Val_aiMesh(struct aiMesh *mesh)
{
  CAMLparam0();
  CAMLlocal2(ret, tmp);

  assert (AI_MAX_NUMBER_OF_COLOR_SETS == 8);
  assert (AI_MAX_NUMBER_OF_TEXTURECOORDS == 8);

  ret = caml_alloc(13, 0);
  Store_field(ret, 0, Val_aiPrimitiveType(mesh->mPrimitiveTypes));
  Store_field(ret, 1, import_array(aiVector3D, mesh->mVertices, mesh->mNumVertices));
  Store_field(ret, 2, import_array(aiVector3D, mesh->mNormals, mesh->mNumVertices));
  Store_field(ret, 3, import_array(aiVector3D, mesh->mTangents, mesh->mNumVertices));
  Store_field(ret, 4, import_array(aiVector3D, mesh->mBitangents, mesh->mNumVertices));

  int i;
  tmp = caml_alloc(8, 0);
  for (i = 0; i < 8; ++i)
    Store_field(tmp, i, import_array(aiColor4D, mesh->mColors[i], mesh->mNumVertices));
  Store_field(ret, 5, tmp);

  tmp = caml_alloc(8, 0);
  for (i = 0; i < 8; ++i)
    Store_field(tmp, i, import_array(aiVector3D, mesh->mTextureCoords[i], mesh->mNumVertices));
  Store_field(ret, 6, tmp);

  tmp = caml_alloc(8, 0);
  for (i = 0; i < 8; ++i)
    Store_field(tmp, i, Val_int(mesh->mNumUVComponents[i]));
  Store_field(ret, 7, tmp);

  Store_field(ret, 8, import_array(aiFace, mesh->mFaces, mesh->mNumFaces));
  Store_field(ret, 9, import_arrayp(aiBone, mesh->mBones, mesh->mNumBones));
  Store_field(ret, 10, Val_int(mesh->mMaterialIndex));
  Store_field(ret, 11, Val_aiString(&mesh->mName));
  Store_field(ret, 12, import_arrayp(animMesh, mesh->mAnimMeshes, mesh->mNumAnimMeshes));

  CAMLreturn(ret);
}

/* Texture */

value Val_aiTexture(struct aiTexture *tex)
{
  CAMLparam0();
  CAMLlocal4(ret, hint, record, ba);

  hint = caml_import_string(&tex->achFormatHint[0], 4);

  if (tex->mHeight == 0)
  {
    ba = caml_ba_alloc_dims(CAML_BA_INT32 | CAML_BA_C_LAYOUT, 1, NULL,
        tex->mWidth * tex->mHeight);

    record = caml_alloc(4, 0);
    Store_field(record, 0, Val_int(tex->mWidth));
    Store_field(record, 1, Val_int(tex->mHeight));
    Store_field(record, 2, hint);
    Store_field(record, 3, ba);
    ret = caml_alloc(1, 0);
    Store_field(ret, 0, record);
  }
  else
  {
    ba = caml_ba_alloc_dims(CAML_BA_UINT8 | CAML_BA_C_LAYOUT, 1, NULL, tex->mWidth);
    ret = caml_alloc(2, 1);
    Store_field(ret, 0, hint);
    Store_field(ret, 1, ba);
  }

  memcpy(Caml_ba_data_val(ba), tex->pcData,
      caml_ba_byte_size(Caml_ba_array_val(ba)));

  CAMLreturn(ret);
}

/* Version */

CAMLprim value ml_aiGetLegalString(value unit)
{
  return caml_copy_string(aiGetLegalString());
}

CAMLprim value ml_aiGetVersionMinor(value unit)
{
  return Val_int(aiGetVersionMinor());
}

CAMLprim value ml_aiGetVersionMajor(value unit)
{
  return Val_int(aiGetVersionMajor());
}

CAMLprim value ml_aiGetVersionRevision(value unit)
{
  return Val_int(aiGetVersionRevision());
}

CAMLprim value ml_aiGetCompileFlags(value unit)
{
  return Val_int(aiGetCompileFlags());
}

/* Metadata */

value Val_aiMetadataEntry(struct aiMetadataEntry *entry)
{
  CAMLparam0();
  CAMLlocal1(ret);

  if (entry)
  {
    switch (entry->mType)
    {
      case AI_BOOL:
        ret = caml_alloc(1, 0);
        Store_field(ret, 0, Val_int(*(int*)entry->mData));
        break;
      case AI_INT:
        ret = caml_alloc(1, 1);
        Store_field(ret, 0, Val_int(*(int*)entry->mData));
        break;
      case AI_UINT64:
        ret = caml_alloc(1, 2);
        Store_field(ret, 0, caml_copy_int64(*(int64*)entry->mData));
        break;
      case AI_FLOAT:
        ret = caml_alloc(1, 3);
        Store_field(ret, 0, caml_copy_double(*(float*)entry->mData));
        break;
      case AI_AISTRING:
        ret = caml_alloc(1, 4);
        Store_field(ret, 0, Val_aiString((struct aiString *)entry->mData));
        break;
      case AI_AIVECTOR3D:
        ret = caml_alloc(1, 5);
        Store_field(ret, 0, Val_aiVector3D((struct aiVector3D*)entry->mData));
        break;
      default:
        ret = Val_unit;
    }
  }
  else
    ret = Val_unit;

  CAMLreturn(ret);
}

value Val_aiMetadata(struct aiMetadata *mdata)
{
  CAMLparam0();
  CAMLlocal4(ret, v0, v1, empty);

  ret = caml_alloc(mdata->mNumProperties, 0);
  empty = Val_unit;
  int i;
  for (i = 0; i < mdata->mNumProperties; ++i)
  {
    v0 = Val_aiString(&mdata->mKeys[i]);
    v1 = Val_aiMetadataEntry(&mdata->mValues[i]);

    Store_field(ret, i, Val_pair(v0, v1));
  }

  CAMLreturn(ret);
}

/* Postprocess */

#define Val_aiPostProcessSteps Val_int

/* Scene */

value Val_aiNode(struct aiNode *node)
{
  CAMLparam0();
  CAMLlocal1(ret);

  ret = caml_alloc(5, 0);
  Store_field(ret, 0, Val_aiString(&node->mName));
  Store_field(ret, 1, Val_aiMatrix4x4(&node->mTransformation));
  Store_field(ret, 2, import_arrayp(aiNode, node->mChildren, node->mNumChildren));
  Store_field(ret, 3, import_integers(node->mMeshes, node->mNumMeshes));

  CAMLreturn(ret);
}

value Val_scene_of_aiScene(const struct aiScene *scene)
{
  CAMLparam0();
  CAMLlocal1(ret);

  ret = caml_alloc(8, 0);
  Store_field(ret, 0, Val_int(scene->mFlags));
  Store_field(ret, 1, Val_aiNode(scene->mRootNode));
  Store_field(ret, 2, import_arrayp(aiMesh, scene->mMeshes, scene->mNumMeshes));
  Store_field(ret, 3, import_arrayp(aiMaterial, scene->mMaterials, scene->mNumMaterials));
  Store_field(ret, 4, import_arrayp(aiAnimation, scene->mAnimations, scene->mNumAnimations));
  Store_field(ret, 5, import_arrayp(aiTexture, scene->mTextures, scene->mNumTextures));
  Store_field(ret, 6, import_arrayp(aiLight, scene->mLights, scene->mNumLights));
  Store_field(ret, 7, import_arrayp(aiCamera, scene->mCameras, scene->mNumCameras));

  CAMLreturn(ret);
}

/* OCaml interface */

#define aiScene_val(v) (*((struct aiScene **)Data_custom_val(v)))

static void aiScene_finalize(value v)
{
  CAMLparam1(v);
  if (aiScene_val(v))
  {
    aiReleaseImport(aiScene_val(v));
    aiScene_val(v) = NULL;
  }
  CAMLreturn0;
}

static struct custom_operations aiScene_custom_ops = {
    identifier: "aiScene",
    finalize:    aiScene_finalize,
    compare:     custom_compare_default,
    hash:        custom_hash_default,
    serialize:   custom_serialize_default,
    deserialize: custom_deserialize_default
};

value alloc_aiScene(const struct aiScene *scene)
{
  CAMLparam0();
  CAMLlocal1(ret);

  ret = caml_alloc_custom(&aiScene_custom_ops, sizeof(struct aiScene *), 0, 1);
  aiScene_val(ret) = (struct aiScene *)scene;

  CAMLreturn(ret);
}

CAMLprim value ml_aiScene_release(value scene)
{
  CAMLparam1(scene);

  if (aiScene_val(scene))
  {
    aiReleaseImport(aiScene_val(scene));
    aiScene_val(scene) = NULL;
  }
  else
    caml_invalid_argument("Assimp.release_scene");

  CAMLreturn(Val_unit);
}

CAMLprim value ml_aiScene_view(value scene)
{
  CAMLparam1(scene);
  CAMLlocal1(ret);

  if (aiScene_val(scene))
    ret = Val_scene_of_aiScene(aiScene_val(scene));
  else
    caml_invalid_argument("Assimp.release_scene");

  CAMLreturn(ret);
}

CAMLprim value ml_aiImportFile(value filename, value flags)
{
  CAMLparam2(filename, flags);
  CAMLlocal1(ret);

  const struct aiScene* scene = aiImportFile(String_val(filename), Int_val(flags));
  if (scene)
  {
    ret = make_ok(alloc_aiScene(scene));
    aiReleaseImport(scene);
  }
  else
    ret = make_error(aiGetErrorString());

  CAMLreturn(ret);
}

CAMLprim value ml_aiImportFileFromMemory(value ba, value flags, value hint)
{
  CAMLparam3(ba, flags, hint);
  CAMLlocal1(ret);

  const struct aiScene* scene = aiImportFileFromMemory(
      Caml_ba_data_val(ba), caml_ba_byte_size(Caml_ba_array_val(ba)),
      Int_val(flags), String_val(hint));
  if (scene)
  {
    ret = make_ok(alloc_aiScene(scene));
    aiReleaseImport(scene);
  }
  else
    ret = make_error(aiGetErrorString());

  CAMLreturn(ret);
}

CAMLprim value ml_aiApplyPostProcessing(value scene, value flags)
{
  CAMLparam1(scene);
  CAMLlocal1(ret);

  if (aiScene_val(scene))
  {
    if (aiApplyPostProcessing(aiScene_val(scene), Int_val(flags)))
      ret = Val_int(1);
    else
      ret = Val_int(0);
  }
  else
    caml_invalid_argument("Assimp.release_scene");

  CAMLreturn(ret);
}
