# Other Implemnentations of dsnote

## Python

[donno](https://github.com/leetschau/donno): graduated

## FSharp

[dof](https://github.com/leetschau//dof): graduated

## Haskell

[hod](https://github.com/leetschau/hod): graduated

## Nim

[donim](https://github.com/leetschau/donim): graduated

## Rust

[ron](https://github.com/leetschau/ron): graduated

## C

[donc](https://gitee.com/charlize/donc): in developing

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

