.transitions |= map(select(.from != "verifying" or .to != "pr-ready"))
