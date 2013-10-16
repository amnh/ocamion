.PHONY: clean byte native docs top install uninstall tests all dot

.DEFAULT: all

BUILD=ocamlbuild -use-ocamlfind
OFIND=ocamlfind

INST_BYT=_build/ocamion.cma
INST_NAT=_build/ocamion.cmxa _build/ocamion.a _build/ocamion.cmx
INST_OTH=_build/lib/*.mli _build/ocamion.cm[io]

# -----------------------------------

all : native byte

native :
	$(BUILD) ocamion.cmxa

byte :
	$(BUILD) ocamion.cma

top :
	$(BUILD) ocamion.top

clean :
	$(BUILD) -clean

# -----------------------------------
 
install :
	$(OFIND) install ocamion META $(INST_BYT) $(INST_NAT) $(INST_OTH)

uninstall :
	$(OFIND) remove ocamion

# -----------------------------------

docs :
	$(BUILD) ocamion.docdir/index.html

man :
	$(BUILD) -docflags "-man -man-mini" ocamion.docdir/man

%.mli :
	$(BUILD) $*.inferred.mli && cp _build/lib/$*.inferred.mli lib/$*.mli

dot :
	$(BUILD) -docflag -dot ocamion.docdir/dot && cp _build/ocamion.docdir/dot ocamion.dot
