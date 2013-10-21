.PHONY: clean byte native test tests

.DEFAULT: byte

BUILD=ocamlbuild -use-ocamlfind

tests : native

test : native

native :
	$(BUILD) test.native

byte :
	$(BUILD) test.byte

clean :
	$(BUILD) -clean
