BEGIN { for (i in ARGV)
  if (ARGC < 2) {
    print "Bad format"
    exit 1
  }
  if (ARGV[1] == "s") {
    system("ls -l")
  } else if (ARGV[1] == "l") {
    system("pwd")
  }
}

/thunder/ {print FILENAME}
