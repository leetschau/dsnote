use std::env;

fn main() {
    let arg1: Vec<String> = env::args().collect();
    let args: Vec<&str> = arg1.iter().map(|s| s as &str).collect();
    match &args[1..] {
        [] => println!("empty vec"),
        ["s", end @ ..] => {
            //println!("Start: {:?}", start);
            println!("Searching terms: {:?}", end)
        },
        ["e"] => {
            edit_note(1);
        },
        ["e", no] => {
            edit_note(no.parse::<u32>().unwrap());
        },
        _ => println!("Invalid command!"),
    }
}

fn edit_note(note_no: u32) {
    println!("Edit note No. {}", note_no);
}
