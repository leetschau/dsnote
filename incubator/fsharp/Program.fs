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
    printfn "res: %A" (Notes.simpleSearch args)
  | [] ->
    printf "%s" usage
  | _ ->
    printfn "%s" usage
  0
