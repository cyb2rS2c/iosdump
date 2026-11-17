# iosdump

> 📱 **iPhone data dumper for Linux. Download media, collect device information, and create local iPhone backups over USB.**

![Platform](https://img.shields.io/badge/platform-Linux-2ea44f?logo=linux&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-support-blue?logo=apple&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-yellow?logo=open-source-initiative&logoColor=black)
![Version](https://img.shields.io/badge/version-1.0.0-orange?logo=semantic-release&logoColor=white)

---

## Overview

`iosdump` is a lightweight, terminal-based iPhone data collection tool for Linux.

It uses Apple's AFC (Apple File Conduit) protocol and the libimobiledevice toolkit to communicate with connected iPhones and iPads over USB.

Unlike a basic media downloader, iosdump combines device information collection, media downloading, and local iPhone backup creation into one workflow.

The goal is to provide a centralized way to collect and organize accessible iPhone data without iTunes or proprietary desktop software.
It connects via Apple File Conduit (AFC) and pulls data directly from the **DCIM directory**, preserving the original folder structure (e.g. `123APPLE`).

---

## Features

Features

    📸 Download photos and videos directly from the iPhone DCIM directory.
    📂 Preserve the original DCIM folder structure.
    📱 Collect iPhone device information and iOS version.
    💾 Create local iPhone backups using idevicebackup2.
    📊 Terminal-based progress indicator.
    📝 Centralized error logging.
    🔌 USB communication using AFC and libimobiledevice.
    📁 Organized output directories for different data categories.
    💻 No graphical interface required.
    🐧 Designed for Linux.
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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
