# ios-media-dumper

> **Dump photos and videos from iPhones and iPads using AFC (`afcclient`) and `libimobiledevice`.**

![Platform](https://img.shields.io/badge/%7C%20Linux-green?logo=linux)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Version](https://img.shields.io/badge/Version-1.0-orange)

---


## Features

- Pulls media directly from the `DCIM` folder
- Preserves folder structure
- No iTunes required

## Requirements

- `afcclient` (part of `libimobiledevice`)
- `libimobiledevice` tools

## Installation

### Ubuntu / Debian

```bash
sudo apt update
sudo apt install libimobiledevice-utils tree
git clone https://github.com/cyb2rS2c/ios-media-dumper.git
cd ios-media-dumper
```

### Arch Linux

```bash
sudo pacman -S libimobiledevice tree
```

## Usage

1. Connect your iPhone or iPad via USB and trust the computer.
2. Make the script executable:

```bash
chmod +x ios-media-dumper.sh
```

3. Run the script:

```bash
./ios-media-dumper.sh
```

4. Media will be downloaded into:

```text
iphone_media/DCIM/
```

## Notes

- Requires AFC access.
- Tested on Linux.
- Empty directories are skipped automatically.
- Errors are logged temporarily to `/tmp/afc_error.log`.


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
