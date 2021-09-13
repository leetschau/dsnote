use std::env;
mod notes;

fn main() {
    let arg_sv: Vec<String> = env::args().collect();
    let args: Vec<&str> = arg_sv.iter().map(|s| s as &str).collect();
    match &args[1..] {
        [] => println!("empty vec"),
        ["s", words @ ..] => {
            println!("{:?}", notes::simple_search(words));
        },
        ["e"] => {
            notes::edit_note(1);
        },
        ["e", no] => {
            notes::edit_note(no.parse::<u32>().unwrap());
        },
        _ => println!("Invalid command!"),
    }
}
