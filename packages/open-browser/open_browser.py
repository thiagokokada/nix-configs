#!/usr/bin/env python3

"""Open browser according to user preference

Very simple script that expects a "$HOME/.open-browser-map.json" file and
maps the browser accordingly. For example:

{
  "only-works-in-chromium.com": "chromium",
  "only-works-in-firefox.com": "firefox",
  "another-broken-site": chromium
}

The rule is really simple, it just checks if the substring is present in the
URL. So of course, a site called "https://random-site/another-broken-site"
will match the third rule, even if this is maybe unexpected. But it generally
works fine.

Anything that doesn't match the JSON mapping will default to the browser set
in BROWSER environment variable, or Firefox as fallback.
"""

import json
import os
import sys
from pathlib import Path
from subprocess import run

DEFAULT_BROWSER = os.environ.get("BROWSER", "firefox")
CONFIG_PATH = Path("~/.open-browser-map.json").expanduser()
EXEC_PATH = Path(sys.argv[0])


def get_browser_for_url(url, url_map):
    for url_pattern, browser in url_map.items():
        if url_pattern in url:
            return browser

    return DEFAULT_BROWSER


def get_url_map(config_path):
    try:
        with config_path.open() as f:
            return json.loads(f.read())
    except FileNotFoundError:
        print(f"Config file not found in {config_path}", file=sys.stderr)
        return {}


def main(argv=sys.argv):
    url = argv[-1]
    url_map = get_url_map(CONFIG_PATH)
    browser = get_browser_for_url(url, url_map)

    print(f"Selected browser: {browser}", file=sys.stderr)

    run([browser, *argv[1:]])


if __name__ == "__main__":
    main(sys.argv)
