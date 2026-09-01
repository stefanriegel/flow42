.side_transitions |= map(if .from == "blocked" then .to = "complete" else . end)
