all: assimp.cma assimp.cmxa

CFLAGS=-Og -ggdb -std=gnu99 -ffast-math
ml_assimp.o: ml_assimp.c
	ocamlc -c -ccopt "$(CFLAGS)" $<

dll_assimp_stubs.so lib_assimp_stubs.a: ml_assimp.o
	ocamlmklib \
	    -o _assimp_stubs $< \
			-ccopt "$(CFLAGS)" \
			-cclib -lassimp

assimp.cmi: assimp.mli
	ocamlc -c $<

assimp.cmo: assimp.ml assimp.cmi
	ocamlc -c $<

assimp.cma: assimp.cmo dll_assimp_stubs.so
	ocamlc -a -custom -o $@ $< \
	       -ccopt -L/usr/local/lib \
	       -dllib dll_assimp_stubs.so \
	       -cclib -l_assimp_stubs \
				 -cclib -lassimp

assimp.cmx: assimp.ml assimp.cmi
	ocamlopt -c $<

assimp.cmxa assimp.a: assimp.cmx dll_assimp_stubs.so
	ocamlopt -a -o $@ $< \
	      -cclib -l_assimp_stubs \
				-ccopt "$(CFLAGS)" \
				-cclib -lassimp

.PHONY: clean-doc clean clean-mlpp run-opt-demo test install

clean: clean-doc clean-mlpp
	rm -f *.[oa] *.so *.cm[ixoa] *.cmxa

DIST_FILES=              \
	assimp.a            \
	assimp.cmi          \
	assimp.cmo          \
	assimp.cma          \
	assimp.cmx          \
	assimp.cmxa         \
	lib_assimp_stubs.a  \
	dll_assimp_stubs.so

install: $(DIST_FILES) META
	ocamlfind install assimp $^

uninstall:
	ocamlfind remove assimp

reinstall:
	-$(MAKE) uninstall
	$(MAKE) install
