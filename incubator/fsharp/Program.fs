open System

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
    printfn "%s" (Notes.simpleSearch args)
  | ["a"] ->
    Notes.addNote ()
  | ["l"; num] ->
    printfn "%s" (num |> int |> Notes.listNotes)
  | [] ->
    printf "%s" usage
  | _ ->
    printfn "%s" usage
  0
