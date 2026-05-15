# ASTAP - A Free Stacking and Astrometric Solver

[![License](https://img.shields.io/badge/license-MPL%202.0-blue.svg)](https://opensource.org/licenses/MPL-2.0)
[![Mirror](https://img.shields.io/badge/Mirror-SourceForge-blue?color=red)](https://sourceforge.net/p/astap-program/code/)
![GitHub commit activity (branch)](https://img.shields.io/github/commit-activity/m/CanardConfit/ASTAP)

> **Important Note** : This repository is a mirror of the original SourceForge project. Visit the SourceForge project page [here](https://sourceforge.net/p/astap-program/code/).

**ASTAP** is a free stacking and astrometric solver program for deep sky images. It is written in Object Pascal and compiled with the Free Pascal Compiler using Lazarus, the open-source cross-platform IDE.

## ASTAP Introduction

ASTAP is designed to work with astronomical images in the FITS format but can also import RAW DSLR images, XISF, PGM, PPM, TIF, PNG, and JPG images. Its native astrometric solver can be integrated with imaging programs like CCDCiel, NINA, APT, Voyager, or SGP for mount synchronization.

### Features

- Native astrometric solver, command-line compatible with PlateSolve2.
- Stacking astronomical images with dark frame and flat field correction.
- Filtering of deep sky images based on HFD value and average value.
- Alignment using an internal star match routine and internal astrometric solver.
- Mosaic building covering large areas using the astrometric linear solution WCS or WCS+SIP polynomial.
- Background equalizing.
- FITS viewer with swipe functionality, deep sky, and star annotation, photometry, and CCD inspector.
- FITS thumbnail viewer.
- Export to JPEG, PNG, TIFF (ASTRO-TIFF), PFM, PPM, PGM files.
- FITS header edit.
- FITS crop function.
- Automatic photometry calibration against Gaia database, Johnson -V, or Gaia Bm.
- CCD inspector.
- Deepsky and Hyperleda annotation.
- Solar object annotation using MPC ephemerides.
- Read/writes FITS binary and reads ASCII tables.
- Pixel math functions and digital development process.
- Display images and tables from a multi-extension FITS.
- Blink routine.
- Photometry routine.

For more informations, follow the author's website: https://www.hnsky.org/astap

### Installation

Follow the author's instructions [Here](https://www.hnsky.org/astap#installation).

## ASTAP-zh Fork Builds

### 简体中文

这是 ASTAP 的非官方简体中文本地化 fork。汉化基于 Lazarus `.po`
资源和少量运行时界面文本映射，目标是在尽量保留官方功能和包结构的前提下提供中文界面。

当前汉化构建基于 ASTAP `2026.04.21`。

#### 下载

- [macOS 官方风格构建产物 ASTAP-zh-macos](https://github.com/songshugong/ASTAP/actions/runs/25625623510/artifacts/6902817503)
  - 包含 `astap_zh_M1.pkg`、`astap_zh_macOS_M1.zip`、SHA256 校验文件。
  - 基于官方 `astap_M1.pkg`，替换汉化后的主程序并加入 `languages/zh_CN/astap.po`。
- [Windows 官方风格构建产物 ASTAP-zh-windows](https://github.com/songshugong/ASTAP/actions/runs/25626397452/artifacts/6903028400)
  - 包含 `astap_zh_setup.exe`、`astap_zh.zip`、SHA256 校验文件。
  - 基于官方 `astap_setup.exe` 静默安装后的文件结构，替换汉化后的主程序并加入 `languages/zh_CN/astap.po`。
- [iOS 实验性命令行构建产物 ASTAP-zh-iOS-cli](https://github.com/songshugong/ASTAP/actions/runs/25917201535/artifacts/7016844767)
  - 包含 `astap_command-line_version_iOS_aarch64.zip` 和 SHA256 校验文件。
  - 这是 iOS aarch64 命令行 solver，不是图形化 iPhone/iPad App，也未做 App Store 签名。

这些链接是 GitHub Actions artifact 直链，可能需要登录 GitHub，并受 GitHub artifact
保留期限限制。更适合长期公开分发的方式是后续创建 GitHub Release，并把同一批 `.zip`、
`.pkg`、`.exe`/Windows zip 上传为 Release assets。

#### 官网包结构对照

官方当前公开包结构核对自 SourceForge：

- Windows GUI：`astap_setup.exe` 64 位安装器，约 6.3 MB；`astapwin32.zip` 32 位便携包，约 5.7 MB。
- Windows 命令行：`astap_command-line_version_win64.zip`、`win32.zip`、`win11_aarch64.zip`，约 275-331 kB。
- macOS GUI：`astap_M1.pkg` Apple Silicon，约 4.0 MB；`astap.pkg` Intel x86_64，约 4.5 MB。
- macOS 命令行：`astap_command-line_version_macOS_M1.zip`、`macOS_x86_64.zip`，约 1.3-1.4 MB。
- Linux GUI：amd64、i386、aarch64、armhf，并按 deb、tar.gz、rpm、pkg.tar.zst、GTK/QT 变体分发，约 4.0-8.9 MB。
- Android：只有命令行 solver，aarch64、armhf、x86、x86_64，约 330-338 kB。
- iOS：源码里有命令行 `.lpi` 目标，但官网当前没有公开 iOS 下载包。

本 fork 目前仿造并确认成功的下载内容是 Windows 64 位 GUI 安装器/便携 zip、macOS Apple Silicon GUI pkg/zip，以及实验性的 iOS aarch64 命令行 solver。

#### 版本和限制

- 非官方版本：本 fork 与 ASTAP 原作者和官方发布无隶属关系。
- 许可证：ASTAP 使用 MPL-2.0。本 fork 保留原许可证和版权声明，修改源码公开在本仓库。
- macOS：构建流程以官方 macOS 安装包为底包，保留官方辅助工具和资源，再替换汉化后的主程序并加入 `languages/zh_CN/astap.po`。
- macOS 签名：当前使用 ad-hoc 签名，没有 Apple notarization；首次运行可能需要在系统安全设置中手动允许。
- Windows：当前提供官方风格 x64 汉化安装器和 x64 便携 zip。32 位 GUI、Windows ARM64 命令行版暂未提供。
- iOS：当前只提供实验性 aarch64 命令行二进制，需要自行嵌入已签名的 iOS App、开发者工具链或自动化环境；不提供图形界面。
- 汉化范围：主要覆盖静态界面、菜单、提示、常见弹窗和部分动态文本。少量专业术语、日志、第三方/标准 FITS 内容可能仍保留英文。
- 功能限制：星表数据库、索引文件、OpenSSL 依赖等外部数据/组件仍按 ASTAP 官方说明单独安装或配置。

### English

This is an unofficial Simplified Chinese localization fork of ASTAP. The
localization is based on Lazarus `.po` resources plus a small runtime UI text
mapping layer. The goal is to provide a Chinese UI while keeping the official
ASTAP behavior and package layout as intact as possible.

The current localized builds are based on ASTAP `2026.04.21`.

#### Downloads

- [macOS official-style artifact ASTAP-zh-macos](https://github.com/songshugong/ASTAP/actions/runs/25625623510/artifacts/6902817503)
  - Includes `astap_zh_M1.pkg`, `astap_zh_macOS_M1.zip`, and a SHA256 checksum file.
  - Based on the official `astap_M1.pkg`; the main executable is replaced with the localized build and `languages/zh_CN/astap.po` is added.
- [Windows official-style artifact ASTAP-zh-windows](https://github.com/songshugong/ASTAP/actions/runs/25626397452/artifacts/6903028400)
  - Includes `astap_zh_setup.exe`, `astap_zh.zip`, and a SHA256 checksum file.
  - Based on the file layout produced by the official `astap_setup.exe`; the main executable is replaced with the localized build and `languages/zh_CN/astap.po` is added.
- [iOS experimental CLI artifact ASTAP-zh-iOS-cli](https://github.com/songshugong/ASTAP/actions/runs/25917201535/artifacts/7016844767)
  - Includes `astap_command-line_version_iOS_aarch64.zip` and a SHA256 checksum file.
  - This is an iOS aarch64 command-line solver, not a graphical iPhone/iPad app, and it is not signed for App Store distribution.

These are direct GitHub Actions artifact links. They may require a GitHub login
and are subject to GitHub's artifact retention policy. For public long-term
distribution, GitHub Releases are recommended; the same `.zip`, `.pkg`, and
Windows zip assets can then be attached to a release.

#### Official Package Layout Reference

The current official SourceForge package layout is:

- Windows GUI: `astap_setup.exe` 64-bit installer, about 6.3 MB; `astapwin32.zip` 32-bit portable package, about 5.7 MB.
- Windows CLI: `astap_command-line_version_win64.zip`, `win32.zip`, and `win11_aarch64.zip`, about 275-331 kB.
- macOS GUI: `astap_M1.pkg` for Apple Silicon, about 4.0 MB; `astap.pkg` for Intel x86_64, about 4.5 MB.
- macOS CLI: `astap_command-line_version_macOS_M1.zip` and `macOS_x86_64.zip`, about 1.3-1.4 MB.
- Linux GUI: amd64, i386, aarch64, and armhf packages across deb, tar.gz, rpm, pkg.tar.zst, GTK, and QT variants, about 4.0-8.9 MB.
- Android: command-line solver only, for aarch64, armhf, x86, and x86_64, about 330-338 kB.
- iOS: command-line `.lpi` targets exist in source, but there is no current public iOS download package.

This fork currently mirrors the Windows 64-bit GUI installer/portable zip, the macOS Apple Silicon GUI pkg/zip, and an experimental iOS aarch64 command-line solver.

#### Version and Limitations

- Unofficial build: this fork is not affiliated with the original ASTAP author or official distribution.
- License: ASTAP is licensed under MPL-2.0. This fork keeps the original license and copyright notices, and publishes the modified source in this repository.
- macOS: the workflow starts from the official ASTAP macOS package, keeps the official helper tools and bundle resources, then replaces the main executable and adds `languages/zh_CN/astap.po`.
- macOS signing: builds are ad-hoc signed and not Apple-notarized; macOS may require manual approval on first launch.
- Windows: the current build provides an official-style localized x64 installer and x64 portable zip. 32-bit GUI and Windows ARM64 CLI packages are not provided yet.
- iOS: the current build is only an experimental aarch64 command-line binary. It must be embedded into a signed iOS app, developer workflow, or automation environment; no graphical UI is provided.
- Localization scope: static UI, menus, hints, common dialogs, and part of the dynamic UI text are localized. Some technical terms, logs, third-party strings, and standard FITS content may remain in English.
- Functional dependencies: star databases, index files, OpenSSL libraries, and other external data/components still follow the official ASTAP installation instructions.

### Build Workflows

The localized builds are produced from this fork by GitHub Actions:

- Windows x64: `.github/workflows/windows-astap-zh.yml`
- macOS: `.github/workflows/macos-astap-zh.yml`

The macOS workflow starts from the official ASTAP macOS package, keeps the
official helper tools and bundle resources, then replaces the main executable
and adds `languages/zh_CN/astap.po`. The Windows workflow starts from the
official Windows installer layout, keeps the official helper tools and data
files, then replaces the main executable and adds the same language resources.
