# iosdump

> 📱 **Easily transfer photos and videos from iPhones and iPads over USB using AFC (Apple File Conduit).**

![Platform](https://img.shields.io/badge/platform-Linux-2ea44f?logo=linux&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-support-blue?logo=apple&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-yellow?logo=open-source-initiative&logoColor=black)
![Version](https://img.shields.io/badge/version-1.0.0-orange?logo=semantic-release&logoColor=white)

---

## Overview

`iosdump` is a lightweight terminal tool for extracting media from iOS devices without iTunes or proprietary software.

It connects via Apple File Conduit (AFC) and pulls data directly from the **DCIM directory**, preserving the original folder structure (e.g. `123APPLE`).

---

## Features

- Export photos and videos from iOS devices via USB
- Direct access to `DCIM` folders
- Preserves folder structure during export
- No iTunes or GUI required
- Includes device information fetcher
- Fully terminal-based workflow
- Extracts all media files (including photos hidden via iOS "Hidden Album" feature)
---

## Requirements

```bash
sudo apt update
sudo apt install libimobiledevice-utils tree
```

## Installation

### Ubuntu / Debian

```bash
git clone https://github.com/cyb2rS2c/iosdump.git;cd iosdump;chmod +x *.sh
```

### Arch Linux

```bash
sudo pacman -S libimobiledevice tree
```

## Usage

### Dump media
```bash
./ios-media-dumper.sh
```
### Device info
```bash
./info_fetcher.sh
```

## Notes

- Requires AFC access.
- Tested on Linux.
- Empty directories are skipped automatically.
- Errors are logged temporarily to `/tmp/afc_error.log`.
- Media will be downloaded into: `iphone_media/DCIM/`


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
