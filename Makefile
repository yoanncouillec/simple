all: eval repl

eval: simple.cmo parser.cmi parser.cmo lexer.cmo eval.cmo
	ocamlc -o $@ simple.cmo parser.cmo lexer.cmo eval.cmo

repl: simple.cmo parser.cmi parser.cmo lexer.cmo repl.cmo
	ocamlc -o $@ simple.cmo parser.cmo lexer.cmo repl.cmo

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

test: eval
	./eval < test/app.spl
	./eval < test/abs.spl
	./eval < test/int.spl

clean:
	rm -rf *.cm* eval repl *~ \#*\# *.mli
