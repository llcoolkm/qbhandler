#!/usr/bin/env python3
# -----------------------------------------------------------------------------
#
# WHO
#  km@grogg.org
#
# WHAT
#  Add torrents to qBittorrent web API, to be used as .torrent handler in W11
#
# -----------------------------------------------------------------------------

import sys
import os
import requests
import argparse
import bencodepy


def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Add torrents to qBittorrent')
    parser.add_argument('torrent_path', help='Path to the torrent file')
    args = parser.parse_args()

    # CONFIGURATION
    qb_url = "http://torrent:8080"
    username = "admin"
    password = "..."
    torrent_path = args.torrent_path.strip('"')

    # DETERMINE CONTENT LAYOUT by parsing the torrent file
    try:
        with open(torrent_path, 'rb') as f:
            torrent_data = f.read()

        # Parse the torrent file
        decoded = bencodepy.decode(torrent_data)
        info = decoded.get(b'info', {})

        # Check if it's a multi-file torrent
        if b'files' in info:
            # Multi-file torrent - check if it already has a root folder
            files = info[b'files']
            paths = [file.get(b'path', []) for file in files]

            # Check if all files are already in a subfolder
            has_root_folder = all(len(path) > 1 for path in paths if path)

            if has_root_folder:
                # Already has a root folder structure - use Original
                content_layout = "Original"
                print(
                    "Multi-file torrent with root folder detected. Using Original layout.")
            else:
                # No root folder - create one
                content_layout = "Subfolder"
                print(
                    "Multi-file torrent without root folder detected. Using Subfolder layout.")
        else:
            # Single-file torrent - create a subfolder
            content_layout = "Subfolder"
            print("Single-file torrent detected. Using Subfolder layout.")
    except Exception as e:
        # If we can't parse the torrent, default to Subfolder layout
        content_layout = "Subfolder"
        print(f"Error parsing torrent file: {
              e}. Defaulting to Subfolder layout.")

    # AUTH
    session = requests.Session()
    login_data = {'username': username, 'password': password}
    response = session.post(f"{qb_url}/api/v2/auth/login", data=login_data)

    if not ((response.status_code == 200 and response.text == "Ok.") or response.status_code == 204):
        print(f"Login failed. HTTP {response.status_code}.", file=sys.stderr)
        sys.exit(1)

    # FILE PREP
    filename = os.path.basename(torrent_path)

    # SEND TORRENT
    with open(torrent_path, 'rb') as f:
        torrent_file = f.read()

    files = {'torrents': (filename, torrent_file, 'application/x-bittorrent')}
    data = {'contentLayout': content_layout}

    response = session.post(
        f"{qb_url}/api/v2/torrents/add", files=files, data=data)

    print(f"Torrent added: {filename}")


if __name__ == "__main__":
    main()
