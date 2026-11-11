import logging
import os
import signal
import sys
import threading
import urllib.error
import urllib.request
import xml.etree.ElementTree as ET

import dbus

logger = logging.getLogger(__name__)


def playback_active(preferences):
    # Read at runtime so the token never enters the Nix store, and refresh it
    # on each poll in case Plex rotates it.
    token = ET.parse(preferences).getroot().get("PlexOnlineToken", "")
    request = urllib.request.Request(
        "http://127.0.0.1:32400/status/sessions",
        headers={
            "Accept": "application/xml",
            "X-Plex-Client-Identifier": "plex-inhibit-sleep",
            "X-Plex-Token": token,
        },
    )
    # Ignore proxy environment variables for this loopback-only request.
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
    with opener.open(request, timeout=5) as response:
        sessions = ET.parse(response).getroot()
    return any(
        player.get("state") in {"playing", "buffering"}
        for player in sessions.iter("Player")
    )


def main(preferences):
    logging.basicConfig(level=logging.INFO, format="%(message)s")
    stopped = threading.Event()
    for signum in (signal.SIGTERM, signal.SIGINT):
        signal.signal(signum, lambda *_: stopped.set())

    bus = dbus.SystemBus()
    manager = dbus.Interface(
        bus.get_object("org.freedesktop.login1", "/org/freedesktop/login1"),
        "org.freedesktop.login1.Manager",
    )
    inhibitor = None
    failed = False
    try:
        while not stopped.is_set():
            try:
                active = playback_active(preferences)
                failed = False
            except (OSError, ET.ParseError, urllib.error.URLError, ValueError):
                # Release on failure rather than leaving a stale inhibitor.
                # Avoid logging headers or response data containing credentials.
                if not failed:
                    logger.warning("Cannot read Plex playback status; retrying in 15s")
                failed = True
                active = False

            if active and inhibitor is None:
                inhibitor = manager.Inhibit(
                    "sleep:idle", "Plex", "Plex playback is active", "block"
                ).take()
                logger.info("Plex playback active; inhibiting sleep")
            elif not active and inhibitor is not None:
                os.close(inhibitor)
                inhibitor = None
                logger.info("Plex playback inactive; released sleep inhibitor")
            stopped.wait(15)
    finally:
        if inhibitor is not None:
            os.close(inhibitor)


if __name__ == "__main__":
    main(sys.argv[1])
