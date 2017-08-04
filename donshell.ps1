$baseDir = "c:\apps\cygRoot\home\lee_c\.donno"
$repo="$baseDir\repo"
$editor = "vim"
$lastResult = "$baseDir\.last-result-win"

function printNotes {
  $file_list = get-content $lastResult
  #write-host $file_list
  $noteNo = 0
  write-host No. Type Title Updated Tags Created Sync?
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
    #$aline = "$note_no. $title [$updated] $tags [$type] $created"
    #write-host $aline.replace(' .', '.')
    write-host "$note_no. [ $type ] $title [$updated] $tags [$created]".replace(' .', '.')
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

function listNotes {
  param([String[]] $items)
  $listNo = 5
  if ($items.length -gt 0) {
    $listNo = $items[0]
  }
  $noteList = Get-ChildItem $repo -Filter *.md | sort LastWriteTime -descending | select -first $listno | % {$_.FullName} 
  $noteList | out-file -encoding ASCII $lastResult
  printnotes 
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
    l { listNotes $params }
    del {"delete note"}
    default {"invalid params"}
  }
}

switch ($args.length) {
  0 {write-host help doc}
  default {runCommand $args}
}
