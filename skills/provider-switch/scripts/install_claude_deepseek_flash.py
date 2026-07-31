#!/usr/bin/env python3
"""Install the all-Flash Claude Code + DeepSeek profile."""

import sys

from install_claude_deepseek import main


if __name__ == "__main__":
    sys.exit(main(default_profile="claude-code-deepseek-flash"))
