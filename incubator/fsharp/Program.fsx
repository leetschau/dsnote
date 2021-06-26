#load "Notes.fs"

let usage = """Usage:
search:
edit:
add:
backup:
"""

[<EntryPoint>]
let main argv =
  match argv |> Array.toList with
  | "s" :: args ->
    Notes.simpleSearch args
  | [] ->
    printf "%s" usage
  | _ ->
    printfn "%s" usage
  0
