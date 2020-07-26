# Other Implemnentations of dsnote

## nim

```
nim c -d:release dsnote.nim
./dsnote s nim thunder
time ./dsnote s nim thunder
```

## Ocaml

```
ocamlbuild -pkgs core,str dsnote.native
./dsnote.native s nim thunder
```

Or build with ocamlfind:
```
ocamlfind ocamlopt -o dsnote -linkpkg -thread -package core,str dsnote.ml
./dsnote s nim thunder
```

## Python

```
python -m venv env
. env/bin/activate
pip install -r requirements.txt
python dsnote.py s nim thunder
```
