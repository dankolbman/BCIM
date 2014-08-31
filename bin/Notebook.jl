##
# Handles notebook content requests
#
# Dan Kolbman
##

function writeSummary(conf)
  path = "$(conf["path"])summary.txt"
  touch(path)
  f = open(path,"w")
  write(f, "# Please add a short summary of the experiment batch below\n\n")
  close(f)
  run(`urxvt -e $(conf["editor"]) $path`)
  DataIO.log("Wrote summary to summary.txt" ,conf)
end

function writeNotes(conf)
  path = "$(conf["path"])notes.txt"
  touch(path)
  f = open(path,"w")
  write(f, "# Please write some notes on the results below\n\n")
  close(f)
  run(`urxvt -e $(conf["editor"]) $path`)
  DataIO.log("Wrote notes to notes.txt" ,conf)
end

