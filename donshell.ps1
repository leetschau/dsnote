$baseDir = "c:\apps\cygRoot\home\lee_c\.donno"
$repo = "$baseDir\repo"
$editor = "vim"
$viewer = "vim -R"
$lastResult = "$baseDir\.last-result-win"
$lastSync = "$baseDir\.last-sync-win"
$noteFileExt = ".md"
$titleLineIndex = 0
$tagLineIndex = 1
$noteTypeLineIndex = 2
$createdLineIndex = 3
$modifiedLineIndex = 4   # the line index of "Modified: 2017-09-27 13:11:23"

function printNotes {
  $file_list = Get-Content $lastResult
  #write-host $file_list
  $noteNo = 0
  Write-Host No. Type Title Updated Tags Created Sync?
  foreach ($fullname in $file_list) {
    $note_no++
    $updated = Get-Date (Get-Item $fullname).LastWriteTime -format "yy.M.d H:m"
    $metaInfo = Get-Content -Encoding UTF8 $fullname
    $x, $title = $metaInfo[$titleLineIndex] -split ': '
    $x, $tags = $metaInfo[$tagLineIndex] -split ': '
    $x, $type = ($metaInfo[$noteTypeLineIndex] -split ': ').ToUpper()
    $x, $createdStr = $metaInfo[$createdLineIndex] -split ': '
    $y = [datetime]::ParseExact($createdStr, "yyyy-MM-dd HH:mm:ss",
         [Globalization.CultureInfo]::InvariantCulture)
    $created = $y.ToString("yy.M.d H:m")
    $toSync = If ((Get-Item $fullname).LastWriteTime -gt
              (Get-Item $lastSync).LastWriteTime) {"*"} Else {""}
    Write-Host "$note_no. [ $type ] $title [$updated] $tags [$created] $toSync".replace(' .', '.')
  }
}

function simpleSearch {
  param([String[]] $items)
  #write-host $items
  if ($items.length -eq 0) {
    "add search items"
    return
  }

  $res = "$repo\*$noteFileExt"
  foreach ($kw in $items) {
    $res = Select-String -Path $res -Pattern $kw | % { $_.Path } | Get-Unique
    if ($res.Length -eq 0) {
      Write-Host Nothing match.
      return
    }
  }

  $res | % { Get-Item $_ } | Sort-Object LastWriteTime -Descending |
    % { $_.FullName } | Out-File -encoding UTF8 $lastResult
  printNotes
}

function complexSearch {
  param([String[]] $items)
  if ($items.length -le 1) {
    "add search items"
    return
  }

  $lineno = 1  # searching title by default
  if ($items[0] -eq '-g') {
    $lineno = 2
  }

  $res = "$repo\*$noteFileExt"
  foreach ($kw in ($items | Select-Object -Skip 1)) {
    $res = Select-String -Path $res -Pattern $kw |
           Where-Object { $_.LineNumber -eq $lineno } |
           % { $_.Path } | Get-Unique
    if ($res.Length -eq 0) {
      Write-Host Nothing match.
      return
    }
  }

  $res | % { Get-Item $_ } | Sort-Object LastWriteTime -Descending |
    % { $_.FullName } | Out-File -encoding UTF8 $lastResult
  printNotes
}

function listNotes {
  param([String[]] $items)
  $listNo = 5
  if ($items.length -gt 0) {
    $listNo = $items[0]
  }
  $noteList = Get-ChildItem $repo -Filter "*$noteFileExt" |
    sort LastWriteTime -descending | select -first $listno | % {$_.FullName} 
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

  $updated = Get-Date (Get-Item $target).LastWriteTime -format "yy.M.d H:m:s"
  $content = Get-Content $target
  $content[$modifiedLineIndex] = "Modified: $updated"
  $content | Out-File -encoding UTF8 $target

  $x, $noteType = (Get-Content -First $modifiedLineIndex `
                       -Encoding UTF8 $target)[$noteTypeLineIndex] -split ': '
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
  $tempNote = Join-Path $repo "temp$noteFileExt"
  $created = Get-Date -format "yyyy-MM-dd HH:mm:ss"
  $template = @"
Title: 
Tags: 
Notebook [t/j/o/y/c]: j
Created: $created
Modified: $created

------


"@
  $template | Out-File -encoding UTF8 $tempNote
  invoke-expression "$editor $tempNote"
  $x, $noteType = (Get-Content -First $modifiedLineIndex `
                       -Encoding UTF8 $tempNote)[$noteTypeLineIndex] -split ': '
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
  
  foreach ($afile in (Get-ChildItem $repo\*$noteFileExt)) {
    $x, $modified = (Get-Content -Encoding UTF8 $afile)[$modifiedLineIndex] `
                    -split ": "
    $afile.LastWriteTime = Get-Date $modified
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
    sc { complexSearch $params }
    v { viewNote $params }
    default {"invalid params"}
  }
}

switch ($args.length) {
  0 {Write-Host help doc}
  default {runCommand $args}
}
