let base_dir = Filename.concat (Unix.getenv "HOME") ".donno"
let repo = Filename.concat base_dir "repo"
let files = Filename.concat repo "*.md"

let shell_search (params: string array): unit =
  print_endline ("grep " ^ params.(0) ^ " " ^ files);
  match Sys.command ("grep " ^ params.(0) ^ " " ^ files) with
    0 -> print_endline "Search OK"
  | _ -> print_endline "Search failed"

let filter_files (filelist: string list) (keyword: string): string list =
  let str_in_file kw filename =
    let lines = Core.In_channel.read_lines (Filename.concat repo filename) in
    let kw_reg = Str.regexp (".*" ^ kw ^ ".*") in
    let matched = List.filter (fun line -> Str.string_match kw_reg line 0) lines in
    match List.length matched with
      0 -> false
    | _ -> true
  in
  List.filter (fun afile -> str_in_file keyword afile) filelist

let list_files dir ext =
  let all_files = Array.to_list (Sys.readdir dir) in
  List.filter (fun afile -> Filename.check_suffix afile ext) all_files

let search_note (params: string list): unit =
  let mdfiles = list_files repo "md" in
  let res = List.fold_left filter_files mdfiles params in
  List.iter print_endline res

let complex_search (params: string array): unit =
  print_endline "complex search"

let show_usage () =
  print_endline "dsnote cmd args"

let notes (args: string array): unit =
  let cmd = Array.get args 1 in
  let params = Array.sub args 2 (Array.length args - 2) in
  (*print_endline ("cmd: " ^ cmd);*)
  match cmd with
    "s" -> search_note (Array.to_list params)
  | "ss" -> complex_search params
  | _ -> print_endline "other operations about notes"
  
let () =
  match Array.length Sys.argv with
    0 -> exit 0
  | 1 -> show_usage ()
  | _ -> notes Sys.argv
