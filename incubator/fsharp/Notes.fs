module Notes

open System
open System.IO

let EDITOR = "nvim"
let VIEWER = "nvim -R"
let BASE = "/home/leo/.donno"
let NOTE_REPO = Path.Combine(BASE, "repo")
let REC_PATH = Path.Combine(BASE, "records")
let TEMP_FILE = "newnote.md"
let DEFAULT_REC_NO = 5

type Note = {
    Title: string
    Tags: string list
    Notebook: string
    Created: DateTime
    Updated: DateTime
    Content: string
    FilePath: string }

let parseNote (note: string): Note =
    let lines = File.ReadAllLines note
    { Title = lines.[0].[7..]
      Tags = lines.[1].Split "; " |> Array.toList
      Notebook = lines.[2].[10..]
      Created = lines.[3].[9..] |> DateTime.Parse
      Updated = lines.[4].[9..] |> DateTime.Parse
      Content = lines.[8..] |> String.concat "\n"
      FilePath = note }

let loadNotes (path: string): Note list =
    let files = Directory.GetFiles(path, "*.md") |> Array.toList
    List.map parseNote files 

let saveAndDisplayNotes (notes: Note list): string =
    File.WriteAllText (REC_PATH,
        List.map (fun note -> note.FilePath) notes |> String.concat "\n")
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
    saveAndDisplayNotes notes

let listNotes (num: int): string =
    (loadNotes NOTE_REPO |> List.sortByDescending (fun note -> note.Updated)).[..num - 1] |> saveAndDisplayNotes

let addNote (): string =
    let created = System.DateTime.Now.ToString "yyyy-MM-dd HH:mm:ss"
    let header = $"Title: \n\
                   Tags: \n\
                   Notebook: \n\
                   Created: {created}\n\
                   Updated: {created}\n\n\
                   ------\n\n"
    File.WriteAllText(TEMP_FILE, header)
    let p = System.Diagnostics.Process.Start(EDITOR, TEMP_FILE)
    p.WaitForExit ()
    let timestamp = System.DateTime.Now.ToString "yyMMddHHmmss"
    let target = Path.Combine(NOTE_REPO, $"note{timestamp}.md")
    File.Move(TEMP_FILE, target)
    listNotes DEFAULT_REC_NO

let editNote (no: int): string =
    let path = (File.ReadAllLines REC_PATH).[no - 1]
    let p = System.Diagnostics.Process.Start(EDITOR, path)
    p.WaitForExit ()
    listNotes DEFAULT_REC_NO

let viewNote (no: int): string =
    let path = (File.ReadAllLines REC_PATH).[no - 1]
    let cmd = (VIEWER + " " + path).Split(" ")  // there may be whitespace in VIEWER, for example `nvim -R`
    let p = System.Diagnostics.Process.Start(cmd.[0], cmd.[1..] |> String.concat " ")
    p.WaitForExit ()
    File.ReadAllText(REC_PATH)

