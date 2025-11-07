#!/usr/bin/env python3
"""
Hook to check for private GitHub repos in ~/workspace before cloning
"""
import json
import sys
import os
import re
from pathlib import Path

WORKSPACE_DIR = Path.home() / "workspace"

def extract_repo_name(git_url):
    """Extract repository name from various git URL formats"""
    patterns = [
        r'git@github\.com:[\w-]+/([\w-]+)(?:\.git)?',  # SSH format
        r'github\.com[:/][\w-]+/([\w-]+)(?:\.git)?',   # HTTPS or SSH
        r'//([\w-]+)\.git',                             # Just repo name
    ]

    for pattern in patterns:
        match = re.search(pattern, git_url)
        if match:
            return match.group(1)
    return None

def check_local_repo(command):
    """Check if a git clone command references a repo that exists locally"""
    # Check if this is a git clone command
    if 'git' not in command.lower() or 'clone' not in command.lower():
        return None

    # Extract the git URL
    parts = command.split()
    git_url = None
    for i, part in enumerate(parts):
        if 'github.com' in part or part.startswith('git@'):
            git_url = part
            break

    if not git_url:
        return None

    # Extract repo name
    repo_name = extract_repo_name(git_url)
    if not repo_name:
        return None

    # Check if repo exists locally
    local_path = WORKSPACE_DIR / repo_name
    if local_path.exists() and local_path.is_dir():
        # Check if it's a git repo
        if (local_path / ".git").exists():
            return str(local_path)

    return None

def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    tool_name = input_data.get("tool_name", "")

    # Only process Bash commands
    if tool_name != "Bash":
        sys.exit(0)

    # Get the command
    tool_input = input_data.get("tool_input", {})
    command = tool_input.get("command", "")

    if not command:
        sys.exit(0)

    # Check if this references a local repo
    local_path = check_local_repo(command)

    if local_path:
        output = {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "reasoning": f"This repo already exists locally at {local_path}. Use the local version instead of cloning."
            },
            "suppressOutput": False
        }
        print(json.dumps(output))
        sys.exit(0)

    # If no local repo found, allow the command to proceed
    sys.exit(0)

if __name__ == "__main__":
    main()
