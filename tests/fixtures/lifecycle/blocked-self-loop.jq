.side_transitions |= map(if .to == "blocked" then .from = "any-non-final" else . end)
