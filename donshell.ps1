$baseDir = "c:\apps\cygRoot\home\lee_c\.donno"
$repo="$baseDir\repo"
$lastResult = "$baseDir\.last-result-win"

function printNotes {
  $file_list = get-content $lastResult
  #write-host $file_list
  $noteNo = 0
  foreach ($fullname in $file_list) {
    $note_no++
    $updated = Get-Date (Get-Item $fullname).LastWriteTime -format "yy.M.d H:m"
    $metaInfo = Get-Content -First 4 -Encoding UTF8 $fullname
    $x, $title = $metaInfo[0] -split ': '
    $x, $tags = $metaInfo[1] -split ': '
    #write-host $tags
    $x, $type = ($metaInfo[2] -split ': ').ToUpper()
    $x, $createdStr = $metaInfo[3] -split ': '
    $y = [datetime]::ParseExact($createdStr, "yyyy-MM-dd HH:mm:ss", [Globalization.CultureInfo]::InvariantCulture)
    $created = $y.ToString("yy.M.d H:m")
    write-host $note_no [$updated] $title [$tags] [$type] $created
  }
}

function simpleSearch {
  param([String[]] $items)
  #write-host $items
  #write-host $items.length
  if ($items.length -eq 0) {
    "add search items"
    return
  }
  $res = $repo
  foreach ($kw in $items) {
    #write-host $kw
    $res = @(pt /i /l $kw $res)
    if ($res.length -eq 0) {
      write-host Nothing match.
      return
    }
    #write-host $res
  }
  #write-host $res
  $res | out-file -encoding ASCII $lastResult
  printNotes
}

function runCommand {
  param([String[]] $items)
  $action = $items[0]
  #write-host action: $action
  $params = $items | select-object -skip 1
  #write-host params: $params
  switch ($action) {
    a {"add note"}
    s { simpleSearch $params }
    l {"list notes"}
    del {"delete note"}
    default {"invalid params"}
  }
}

switch ($args.length) {
  0 {write-host help doc}
  default {runCommand $args}
}
