module Notes

open System
open System.IO

let NOTE_REPO = "/home/vagrant/leohome/.donno/repo"
let TEMP_FILE = "newnote.md"

type Note = {
    Title: string
    Tags: string list
    Notebook: string
    Created: DateTime
    Updated: DateTime
    Content: string }

let parseNote (note: string): Note =
    let lines = note.Split "\n"
    { Title = lines.[0].[7..]
      Tags = lines.[1].Split "; " |> Array.toList
      Notebook = lines.[2].[10..]
      Created = lines.[3].[9..] |> DateTime.Parse
      Updated = lines.[4].[9..] |> DateTime.Parse
      Content = lines.[8..] |> String.concat "\n" }

let loadNotes (path: string): Note list =
    let files = Directory.GetFiles(path, "*.md") |> Array.toList
    List.map (File.ReadAllText >> parseNote) files 

let displayNotes (notes: Note list): string =
    let header = "Resuult:"
    let body = List.map (fun note -> note.Title) notes
    (header :: body) |> String.concat "\n"

let simpleSearch (args: string list): string =
    let wordInNote (word: string) (note: Note): bool =
        (note.Content.Contains word) || (note.Title.Contains word) ||
            (List.exists (fun (tag: string) -> tag.Contains word) note.Tags)
    let notes = List.fold (fun noteList word -> noteList |> List.filter(wordInNote word))
                          (loadNotes NOTE_REPO)
                          args
    displayNotes notes

let addNote () =
    let created = System.DateTime.Now.ToString "yyyy-MM-dd HH:mm:ss"
    let header = $"Title: \n\
                   Tags: \n\
                   Notebook: \n\
                   Created: {created}\n\
                   Updated: {created}\n\n\
                   ------\n\n"
    File.WriteAllText(TEMP_FILE, header)
    let p = System.Diagnostics.Process.Start("nvim", TEMP_FILE)
    p.WaitForExit()
    let timestamp = System.DateTime.Now.ToString "yyMMddHHmmss"
    let fn = $"note{timestamp}.md"
    File.Move(TEMP_FILE, Path.Combine(NOTE_REPO, fn))

let listNotes (num: int): string =
    (loadNotes NOTE_REPO |> List.sortByDescending (fun note -> note.Updated)).[..num] |> displayNotes
