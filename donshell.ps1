$baseDir = "c:\apps\cygRoot\home\lee_c\.donno"
$repo="$baseDir\repo"
$editor = "vim"
$viewer = "vim -R"
$lastResult = "$baseDir\.last-result-win"
$lastSync = "$baseDir\.last-sync-win"
$noteFileExt = ".md"

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
    $x, $type = ($metaInfo[2] -split ': ').ToUpper()
    $x, $createdStr = $metaInfo[3] -split ': '
    $y = [datetime]::ParseExact($createdStr, "yyyy-MM-dd HH:mm:ss", [Globalization.CultureInfo]::InvariantCulture)
    $created = $y.ToString("yy.M.d H:m")
    $toSync = If ((Get-Item $fullname).LastWriteTime -gt (Get-Item $lastSync).LastWriteTime) {"*"} Else {""}
    write-host "$note_no. [ $type ] $title [$updated] $tags [$created] $toSync".replace(' .', '.')
  }
}

function simpleSearch {
  param([String[]] $items)
  #write-host $items
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
  }
  $res | Out-File -encoding UTF8 $lastResult
  #[System.IO.File]::WriteAllLines($lastResult, $res)
  printNotes
}

function listNotes {
  param([String[]] $items)
  $listNo = 5
  if ($items.length -gt 0) {
    $listNo = $items[0]
  }
  $noteList = Get-ChildItem $repo -Filter ("*" + $noteFileExt) | sort LastWriteTime -descending | select -first $listno | % {$_.FullName} 
  #[System.IO.File]::WriteAllLines($lastResult, $noteList)
  $noteList | Out-File -encoding UTF8 $lastResult
  printnotes 
}

function editNote {
  param([String[]] $items)
  $noteNo = 0
  if  ($items.length -gt 0) {
    $noteNo = [int]$items[0] - 1
  }
  $target = Get-Content $lastResult | Select -Index $noteNo
  invoke-expression "$editor $target"
  $x, $noteType = (Get-Content -First 4 -Encoding UTF8 $target)[2] -split ': '
  $originName = split-path $target -leaf
  $newName = $noteType + $originName.Substring(1)
  $newFullName = Join-Path $repo $newName
  if (-not (Test-Path $newFullName)) {
    Rename-Item $target $newName
  }
  listNotes
}

function viewNote {
  param([String[]] $items)
  $noteNo = 0
  if  ($items.length -gt 0) {
    $noteNo = [int]$items[0] - 1
  }
  $target = Get-Content $lastResult | Select -Index $noteNo
  invoke-expression "$viewer $target"
}

function addNote {
  $tempNote = Join-Path $repo ("temp" + $noteFileExt)
  $created = Get-Date -format "yyyy-MM-dd HH:mm:ss"
  $template = @"
Title: 
Tags: 
Notebook [t/j/o/y/c]: j
Created: $created

------
"@
  [System.IO.File]::WriteAllLines($tempNote, $template)
  invoke-expression "$editor $tempNote"
  $x, $noteType = (Get-Content -First 4 -Encoding UTF8 $tempNote)[2] -split ': '
  $creMark = Get-Date -format "yyMMddHHmmss"
  $newName = $noteType + $creMark + $noteFileExt
  Rename-Item $tempNote $newName
  listNotes
}

function delNote {
  param([String[]] $items)
  $noteNo = 0
  if  ($items.length -gt 0) {
    $noteNo = [int]$items[0] - 1
  }
  $target = Get-Content $lastResult | Select -Index $noteNo
  $trashPath = Join-Path $baseDir "trash"
  New-Item -ItemType Directory -Force -Path $trashPath | Out-Null
  Move-Item $target $trashPath -force
  listNotes
}

function backupNotes {
  param([String[]] $items)
  Push-Location $repo
  if (($items.length -gt 0) -and ($items[0] -eq 'c')) {
    git push
  } else {
    git add -A
    git commit -m 'update notes'
  }
  Pop-Location
  $timeStr = (Get-Date).ToString()
  $timeStr | Out-File -encoding UTF8 $lastSync
}

function restoreNotes {
  if (-not (Test-Path $repo)) {
    New-Item -Path $baseDir
    Push-Location $baseDir
    $noteRepo = Read-Host -Prompt 'Input note repo address (git@...)'
    git clone $noteRepo repo
  } else {
    Push-Location $repo
    git pull
  }
  Pop-Location
  $timeStr = (Get-Date).ToString()
  $timeStr | Out-File -encoding UTF8 $lastSync
  listNotes
}

function runCommand {
  param([String[]] $items)
  $action = $items[0]
  #write-host action: $action
  $params = $items | select-object -skip 1
  #write-host params: $params
  switch ($action) {
    a { addNote }
    b { backupNotes $params }
    del { delNote $params }
    e { editNote $params }
    l { listNotes $params }
    r { restoreNotes }
    s { simpleSearch $params }
    v { viewNote $params }
    default {"invalid params"}
  }
}

switch ($args.length) {
  0 {write-host help doc}
  default {runCommand $args}
}
