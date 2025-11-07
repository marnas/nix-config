#!/usr/bin/env python3
"""
Hook to suggest using comma (,) for programs not in PATH in Nix environments
"""
import json
import sys
import os
import shutil
import re

# Programs that should be ignored (shell builtins, control flow, etc.)
IGNORE_COMMANDS = {
    'cd', 'pwd', 'echo', 'exit', 'export', 'source', 'eval', 'exec',
    'if', 'then', 'else', 'fi', 'for', 'while', 'do', 'done', 'case', 'esac',
    'function', 'return', 'break', 'continue', 'test', '[', '[[',
    'true', 'false', 'set', 'unset', 'alias', 'unalias',
}

# Programs that are commonly available and shouldn't trigger comma
COMMON_COMMANDS = {
    'ls', 'cat', 'grep', 'find', 'head', 'tail', 'awk', 'sed', 'sort',
    'cut', 'wc', 'chmod', 'chown', 'mkdir', 'rm', 'cp', 'mv', 'touch',
    'date', 'which', 'whereis', 'type', 'bash', 'sh', 'python3', 'python',
}

def extract_primary_command(command):
    """Extract the primary command from a bash command line"""
    # Remove leading/trailing whitespace
    command = command.strip()

    # Skip empty commands
    if not command:
        return None

    # Skip comments
    if command.startswith('#'):
        return None

    # Handle pipes - get the first command
    if '|' in command:
        command = command.split('|')[0].strip()

    # Handle command chaining - get the first command
    for sep in ['&&', '||', ';']:
        if sep in command:
            command = command.split(sep)[0].strip()

    # Handle redirections
    for redir in ['>', '<', '>>']:
        if redir in command:
            command = command.split(redir)[0].strip()

    # Extract the first word (the command)
    parts = command.split()
    if not parts:
        return None

    # Handle variable assignments (VAR=value command)
    for i, part in enumerate(parts):
        if '=' not in part or part.startswith('-'):
            # This is the actual command
            cmd = part
            break
    else:
        return None

    # Remove any path prefix (e.g., /usr/bin/foo -> foo)
    if '/' in cmd:
        cmd = cmd.split('/')[-1]

    return cmd

def check_command_exists(command):
    """Check if a command exists in PATH"""
    return shutil.which(command) is not None

def should_suggest_comma(command, original_command):
    """Determine if we should suggest using comma"""
    if not command:
        return False

    # Skip ignored commands
    if command in IGNORE_COMMANDS:
        return False

    # Skip common commands
    if command in COMMON_COMMANDS:
        return False

    # Skip if command already uses comma
    if original_command.strip().startswith(','):
        return False

    # Check if command exists in PATH
    if check_command_exists(command):
        return False

    return True

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

    # Extract the primary command
    primary_cmd = extract_primary_command(command)

    # Check if we should suggest comma
    if should_suggest_comma(primary_cmd, command):
        output = {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "reasoning": f"The command '{primary_cmd}' is not in PATH. In a Nix environment, try using ', {primary_cmd}' instead to fetch and run it automatically."
            },
            "suppressOutput": False
        }
        print(json.dumps(output))
        sys.exit(0)

    # Command exists or is ignored, allow it to proceed
    sys.exit(0)

if __name__ == "__main__":
    main()
