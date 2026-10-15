#!/usr/bin/env python3
"""Shim: the linter ships inside the core skill (skills/mobile-ui/scripts/) so that
`npx skills add` and other Agent Skills installers include it. Same CLI as before."""
import os
import runpy

runpy.run_path(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "skills", "mobile-ui", "scripts", "mobile_ui_lint.py"),
    run_name="__main__",
)
