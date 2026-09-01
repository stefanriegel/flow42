.transitions |= map(if .from == "plan-gate" and .to == "building" then .gate = "plan" else . end)
