fn main() {
    // Ask the user their unpack system preference
    println!("What unpack system are you looking for?");
    println!("1. Debian-CORE");

    let mut choice = String::new();
    std::io::stdin().read_line(&mut choice).expect("Failed to read line");
    let choice = choice.trim();

    match choice {
        "1" => {
            unpack_debian_core();
        }
        _ => {
            println!("Invalid choice.");
        }
    }
}

fn unpack_debian_core() {
    // Placeholder for Debian-CORE unpacking logic
    println!("Unpacking using Debian-CORE system...");
}
