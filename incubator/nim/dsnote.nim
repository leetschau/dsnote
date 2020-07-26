import os, strutils, sequtils, algorithm, times

const BASE_DIR = getHomeDir() / ".donno"
const REPO = BASE_DIR / "repo"
const DEF_NOTES_NUM = 5  # default notes number to be displayed

proc addNote() = discard
proc backupNotes() = discard
proc editNote() = discard
proc restoreNotes() = discard
proc complexSearch(stype: string, kw: varargs[string]) = discard

proc getNoteInfo(notePath: string): string =
  let header = readLines(notePath, 5)
  let title = header[0].split(": ")[1]
  let tags = header[1].split(": ")[1]
  let noteType = header[2].split(": ")[1].toUpperAscii
  let created = header[3].split(": ")[1]
  let updated = header[4].split(": ")[1]
  "[" & updated & "] " & title & " [" & tags & "] [" & noteType & "] " & created

func addIndex(lists: seq): seq =
  ## [aa, bb] => ["1. aa", "2. bb"]
  let idx = toSeq(1 .. lists.len)
  zip(idx, lists).mapIt($it[0] & ". " & it[1])
  
proc notesList(fileList: seq): string =
  fileList.map(getNoteInfo).addIndex.join("\n")

proc listNotes(fileCnt: int): string = 
  let notes = toSeq(walkFiles(REPO / "*.md"))
  let sortedNotes = notes.sortedByIt(it.getLastModificationTime.toUnix)
  let firstNotes = sortedNotes[1 .. fileCnt]
  firstNotes.notesList

proc filterWord(fileList: seq, word: string): seq =
  if fileList.len == 0: return @[]
  fileList.filterIt(find(readFile(it).string.normalize, word) > 0)

proc simpleSearch(searchWords: seq[string]): seq[string] =
  foldl(searchWords, filterWord(a, b), toSeq(walkFiles(REPO / "*.md")))

let params = commandLineParams()
if params.len == 0:
  echo listNotes(DEF_NOTES_NUM)
  quit(0)

case params[0]:
  of "a":
    addNote()
  of "b":
    backupNotes()
  of "e":
    editNote()
  of "r":
    restoreNotes()
  of "s":
    let pathList = simpleSearch(params[1 .. ^1])
    if pathList.len == 0:
      echo "Nothing match"
    else:
      echo notesList(pathList)
  of "sc":
    complexSearch(params[1], params[2 .. ^1])
  else:
    echo listNotes(if params.len == 1: DEF_NOTES_NUM else: parseInt(params[1]))

