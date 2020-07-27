import os, strutils, sequtils, algorithm, times, strformat

const BASE_DIR = getHomeDir() / ".donno"
const REPO = BASE_DIR / "repo"
const DEF_NOTES_NUM = 5  # default notes number to be displayed
const NOTE_LIST_HEADER = "No. Updated, Title, Tags, Notebook, Created, Sync?"
const TMP_NOTE = "/tmp/newnote.md"
const VALID_TYPE = {'t', 'j', 'o', 'y', 'c'}
const NOTE_LIST_FILE = BASE_DIR / ".last-result"

let editor = getEnv("EDITOR", "nvim")
let viewer = getEnv("DSNOTE_VIEWER", "nvim -R")
# Here `let` instead of `const` is used to define EDITOR
# Otherwise you have to recompile after changing the value of EDITOR:
# `EDITOR=/usr/bin/vim.tiny nim c dsnote.nim`

proc backupNotes() = discard
proc restoreNotes() = discard
proc complexSearch(stype: string, kw: varargs[string]) = discard

proc getNoteType(inp: seq[string]): string =
  ## Extract note type: the last character in the last line of
  ## the header: "Notebook [t/j/o/y/c]: t" => "t"
  let noteType = inp[^1][^1]
  if not (noteType in VALID_TYPE):
    echo "Invalid note type"
    quit(3)
  $noteType

proc addNote() =
  let created = format(now(), "YYYY-MM-dd HH:mm:ss")
  let noteTempl = "Title: \nTags: \nNotebook [t/j/o/y/c]: \n" &
    "Created: {created}\nModified: {created}\n\n------\n\n".fmt
  if not existsFile(TMP_NOTE): writeFile(TMP_NOTE, noteTempl)
  let ret = execShellCmd(editor & " " & TMP_NOTE)
  if ret != 0: quit(ret)
  # note type is the 3rd line in the note header:
  let noteType = getNoteType(readLines(TMP_NOTE, 3))
  let noteName = noteType & format(now(), "yyMMddHHmmss") & ".md"
  copyFile(TMP_NOTE, REPO / noteName)
  echo "Note created: {noteName}".fmt
  removeFile(TMP_NOTE)

proc editNote(noteNo: Natural) =
  let notePath = readLines(NOTE_LIST_FILE, noteNo)[^1]
  let ret = execShellCmd(editor & " " & notePath)
  if ret != 0: quit(ret)
  # update the modification time of the note:
  let lastMod = format(notePath.getLastModificationTime, "YYYY-MM-dd HH:mm:ss")
  let originLines = readFile(notePath).split("\n")
  let updatedLines = originLines[0 .. 3] & @["Modified: " & lastMod] &
    originLines[5 .. ^1]
  writeFile(notePath, updatedLines.join("\n"))

proc viewNote(noteNo: Natural) =
  let notePath = readLines(NOTE_LIST_FILE, noteNo)[^1]
  let ret = execShellCmd(viewer & " " & notePath)
  if ret != 0: quit(ret)

proc getNoteInfo(notePath: string): string =
  let header = readLines(notePath, 5)
  let title = header[0].split(": ")[1]
  let tags = header[1].split(": ")[1]
  let noteType = header[2].split(": ")[1].toUpperAscii
  let created = header[3].split(": ")[1]
  let updated = header[4].split(": ")[1]
  # TODO add sync? token
  "[" & updated & "] " & title & " [" & tags & "] [" & noteType & "] " & created

func addIndex(lists: seq[string]): seq[string] =
  ## Add index to a sequence:
  ## [aa, bb] => ["1. aa", "2. bb"]
  let idx = toSeq(1 .. lists.len)
  zip(idx, lists).mapIt($it[0] & ". " & it[1])
  
proc notesList(fileList: seq[string]): string =
  fileList.map(getNoteInfo).addIndex.join("\n")

proc listNotes(fileCnt: Natural): string =
  let notes = toSeq(walkFiles(REPO / "*.md"))
  let sortedNotes = notes.sortedByIt(it.getLastModificationTime.toUnix * (-1))
  # here -1 for sorting in descending order
  let firstNotes = sortedNotes[0 .. fileCnt - 1]
  writeFile(NOTE_LIST_FILE, join(firstNotes, "\n"))
  NOTE_LIST_HEADER & "\n" & firstNotes.notesList

proc filterWord(fileList: seq[string], word: string): seq[string] =
  if fileList.len == 0: return @[]
  fileList.filterIt(find(readFile(it).string.normalize, word) > 0)

proc simpleSearch(searchWords: seq[string]): seq[string] =
  let noteList = foldl(searchWords, filterWord(a, b), toSeq(walkFiles(REPO / "*.md")))
  writeFile(NOTE_LIST_FILE, join(noteList, "\n"))
  noteList

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
    editNote(if params.len == 1: 1 else: parseInt(params[1]))
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
  of "v":
    viewNote(if params.len == 1: 1 else: parseInt(params[1]))
  else:
    echo listNotes(if params.len == 1: DEF_NOTES_NUM else: parseInt(params[1]))

