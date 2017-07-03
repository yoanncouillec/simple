all: main

main: simple.cmo parser.cmi parser.cmo lexer.cmo main.cmo
	ocamlc -o $@ simple.cmo parser.cmo lexer.cmo main.cmo

%.cmi: %.mli
	ocamlc $^

.SUFFIXES: .mll .mly .mli .ml .cmi .cmo .cmx

.mll.mli:
	ocamllex $<

.mll.ml:
	ocamllex $<

.mly.mli:
	ocamlyacc $<

.mly.ml:
	ocamlyacc $<

.mli.cmi:
	ocamlc -c $^

.ml.cmo:
	ocamlc -c $^

clean:
	rm -rf *.cm* main *~ \#*\# *.mli
