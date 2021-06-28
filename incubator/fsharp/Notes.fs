module Notes

open System
open System.IO

let NOTE_REPO = "/home/vagrant/leohome/.donno/repo"

type Note =
    { Title: string
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

let wordInNote (word: string) (note: Note): bool =
    note.Content.Contains word

let simpleSearch (args: string list): string list =
    let notes = List.fold (fun noteList word -> noteList |> List.filter(wordInNote word))
                          (loadNotes NOTE_REPO)
                          args
    List.map (fun note -> note.Title) notes
