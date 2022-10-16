use clap::{command, Arg, ArgAction, Command};

//const REPO_HOME: &str = "/tmp/dsnote";
//const TEMP_NOTE: &str = "/tmp/dsnote-tmp.md";

pub fn run() {
    let matches = command!()
        .bin_name("dn")
        .propagate_version(true)
        .infer_subcommands(true)
        .next_line_help(true)
        .subcommand(
            Command::new("add")
                .visible_alias("a")
                .about("add a new note"),
        )
        .subcommand(
            Command::new("delete")
                .visible_alias("del")
                .about("delete the selected note")
                .arg(
                    Arg::new("index")
                        .help("index of the note to be edited.")
                        .value_parser(clap::value_parser!(u16).range(..30000))
                        .default_value("1"),
                ),
        )
        .subcommand(
            Command::new("edit")
                .visible_alias("e")
                .about("edit the selected note")
                .arg(
                    Arg::new("index")
                        .help("index of the note to be edited.")
                        .value_parser(clap::value_parser!(u16).range(..30000))
                        .default_value("1"),
                ),
        )
        .subcommand(
            Command::new("list")
                .visible_alias("l")
                .about("list recent updated notes")
                .arg(
                    Arg::new("number")
                        .help("number of notes to be listed.")
                        .value_parser(clap::value_parser!(u8))
                        .default_value("5"),
                ),
        )
        .subcommand(
            Command::new("search")
                .visible_alias("s")
                .about("search pattern(s) in notes")
                .arg(
                    Arg::new("patterns")
                        .help("pattern(s) to be searched")
                        .action(ArgAction::Append),
                ),
        )
        .subcommand(
            Command::new("search-complex")
                .visible_alias("sc")
                .about("search complex pattern(s) in notes")
                .arg(
                    Arg::new("patterns")
                        .help("pattern(s) to be searched")
                        .action(ArgAction::Append),
                ),
        )
        .get_matches();

    match matches.subcommand() {
        Some(("add", _)) => {
            println!("add a new note")
        },
        Some(("delete", args)) => {
            let idx = args.get_one::<u16>("index").unwrap();
            println!("delete note: #{}", idx)
        },
        Some(("edit", args)) => {
            let idx = args.get_one::<u16>("index").unwrap();
            println!("edit note: #{}", idx)
        },
        Some(("list", args)) => {
            let num = args.get_one::<u8>("number").unwrap();
            println!("list {} most recent notes", num)
        },
        Some(("search", args)) => {
            let ptns: Vec<String>  = args.get_many("patterns").unwrap().cloned().collect();
            println!("Patterns are: {:?}", ptns)
        },
        _ => unreachable!("Exhausted list of subcommands and subcommand_required prevents `None`"),
    }

}
