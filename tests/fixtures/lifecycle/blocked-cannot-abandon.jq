.side_transitions |= map(if .to == "abandoned" then .from = "any-unblocked-non-final" else . end)
