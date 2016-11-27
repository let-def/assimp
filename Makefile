OCAMLC=ocamlfind c
OCAMLOPT=ocamlfind opt
OCAMLMKLIB=ocamlfind mklib

EXT_DLL=$(shell $(OCAMLC) -config | grep ext_dll | cut -f 2 -d ' ')
EXT_LIB=$(shell $(OCAMLC) -config | grep ext_lib | cut -f 2 -d ' ')
EXT_OBJ=$(shell $(OCAMLC) -config | grep ext_obj | cut -f 2 -d ' ')

CFLAGS=-std=gnu99 -ffast-math

all: assimp.cma assimp.cmxa

ml_assimp$(EXT_OBJ): ml_assimp.c
	$(OCAMLC) -c -ccopt "$(CFLAGS)" $<

dll_assimp_stubs$(EXT_DLL) lib_assimp_stubs$(EXT_LIB): ml_assimp$(EXT_OBJ)
	$(OCAMLMKLIB) -o _assimp_stubs $< -cclib -lassimp

assimp.cmi: assimp.mli
	$(OCAMLC) -package result -c $<

assimp.cmo: assimp.ml assimp.cmi
	$(OCAMLC) -package result -c $<

assimp.cma: assimp.cmo dll_assimp_stubs$(EXT_DLL)
	$(OCAMLC) -package result -a -custom -o $@ $< \
	       -dllib dll_assimp_stubs$(EXT_DLL) -dllib libassimp$(EXT_DLL) \
	       -ccopt -L/usr/local/lib -cclib -l_assimp_stubs -cclib -lassimp

assimp.cmx: assimp.ml assimp.cmi
	$(OCAMLOPT) -package result -c $<

assimp.cmxa assimp$(EXT_LIB): assimp.cmx dll_assimp_stubs$(EXT_DLL)
	$(OCAMLOPT) -package result -a -o $@ $< \
	       -cclib -l_assimp_stubs -cclib -lassimp

.PHONY: clean install

clean:
	rm -f *$(EXT_LIB) *$(EXT_OBJ) *$(EXT_DLL) *.cm[ixoa] *.cmxa

DIST_FILES=           \
	assimp$(EXT_LIB)    \
	assimp.cmi          \
	assimp.cmo          \
	assimp.cma          \
	assimp.cmx          \
	assimp.cmxa         \
	assimp.ml           \
	assimp.mli          \
	lib_assimp_stubs$(EXT_LIB)  \
	dll_assimp_stubs$(EXT_DLL)

install: $(DIST_FILES) META
	ocamlfind install assimp $^

uninstall:
	ocamlfind remove assimp

reinstall:
	-$(MAKE) uninstall
	$(MAKE) install
