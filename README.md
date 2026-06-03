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

- [macOS 官方风格构建产物 ASTAP-zh-macos](https://github.com/songshugong/ASTAP-zh/actions/runs/26894924289/artifacts/7389257102)
  - 包含 `astap_zh_M1.pkg`、`astap_zh_macOS_M1.zip`、SHA256 校验文件。
  - 基于官方 `astap_M1.pkg`，替换汉化后的主程序并加入 `languages/zh_CN/astap.po`。
- [Windows 官方风格构建产物 ASTAP-zh-windows](https://github.com/songshugong/ASTAP-zh/actions/runs/26894920012/artifacts/7389098001)
  - 包含 `astap_zh_setup.exe`、`astap_zh.zip`、SHA256 校验文件。
  - 基于官方 `astap_setup.exe` 静默安装后的文件结构，替换汉化后的主程序并加入 `languages/zh_CN/astap.po`。
- [iOS 实验性命令行构建产物 ASTAP-zh-iOS-cli](https://github.com/songshugong/ASTAP-zh/actions/runs/25917201535/artifacts/7016844767)
  - 包含 `astap_command-line_version_iOS_aarch64.zip` 和 SHA256 校验文件。
  - 这是 iOS aarch64 命令行 solver，不是图形化 iPhone/iPad App，也未做 App Store 签名。
- [iOS 图形壳原型 IPA ASTAP-zh-iOS-prototype-ipa](https://github.com/songshugong/ASTAP-zh/actions/runs/25922202510/artifacts/7018905732)
  - 包含 `ASTAP-zh-iOS-prototype.ipa` 和 SHA256 校验文件。
  - 内置 W08 wide-field 星表和 iOS CLI 引擎资源，界面可选择文件、查看内置资源、复制 CLI 参数示例；求解核心仍需后续改造成同进程库接口。
- [iOS 核心接入 MVP IPA ASTAP-zh-iOS-core-mvp](https://github.com/songshugong/ASTAP-zh/actions/runs/25935550796/artifacts/7024333782)
  - 包含 `ASTAP-zh-iOS-core-mvp.ipa`、SHA256 校验文件和解包清单，artifact 约 195 MB；本版已串行化 ASTAP core 调用，避免重复点击并发求解导致崩溃。
  - 这是核心已接入的 iOS MVP 原型：UIKit 图形界面通过 C ABI 调用 ASTAP Pascal 求解核心，支持文件选择、FITS 解析、图像预览、头信息/表格、求解参数、日志和结果页。
  - 构建流程从官方 SourceForge 下载并内置 D05/G05 星表数据库；仓库不直接保存这些大文件。

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

本 fork 目前仿造并确认成功的下载内容是 Windows 64 位 GUI 安装器/便携 zip、macOS Apple Silicon GUI pkg/zip、实验性的 iOS aarch64 命令行 solver、iOS 图形壳原型 IPA，以及核心已接入的 iOS MVP IPA。

#### 版本和限制

- 非官方版本：本 fork 与 ASTAP 原作者和官方发布无隶属关系。
- 许可证：ASTAP 使用 MPL-2.0。本 fork 保留原许可证和版权声明，修改源码公开在本仓库。
- macOS：构建流程以官方 macOS 安装包为底包，保留官方辅助工具和资源，再替换汉化后的主程序并加入 `languages/zh_CN/astap.po`。
- macOS 签名：当前使用 ad-hoc 签名，没有 Apple notarization；首次运行可能需要在系统安全设置中手动允许。
- Windows：当前提供官方风格 x64 汉化安装器和 x64 便携 zip。32 位 GUI、Windows ARM64 命令行版暂未提供。
- iOS CLI：实验性 aarch64 命令行二进制仍可单独下载，需要自行嵌入已签名的 iOS App、开发者工具链或自动化环境。
- iOS IPA：核心接入 MVP 使用 ad-hoc 签名，没有开发者证书和 provisioning profile；普通未越狱设备通常不能直接安装运行。它是原型，不是 App Store/TestFlight 分发包。
- iOS MVP 范围：第一版只覆盖文件选择、FITS 解析、图像预览、头信息/表格、求解参数、日志和结果页；没有复刻完整桌面 ASTAP。
- iOS 包体：核心 MVP IPA 内置 D05/G05 星表，所以 artifact 明显大于普通 GUI 或命令行包。
- 汉化范围：主要覆盖静态界面、菜单、提示、常见弹窗和部分动态文本。少量专业术语、日志、第三方/标准 FITS 内容可能仍保留英文。
- 功能限制：星表数据库、索引文件、OpenSSL 依赖等外部数据/组件仍按 ASTAP 官方说明单独安装或配置。

### English

This is an unofficial Simplified Chinese localization fork of ASTAP. The
localization is based on Lazarus `.po` resources plus a small runtime UI text
mapping layer. The goal is to provide a Chinese UI while keeping the official
ASTAP behavior and package layout as intact as possible.

The current localized builds are based on ASTAP `2026.04.21`.

#### Downloads

- [macOS official-style artifact ASTAP-zh-macos](https://github.com/songshugong/ASTAP-zh/actions/runs/26894924289/artifacts/7389257102)
  - Includes `astap_zh_M1.pkg`, `astap_zh_macOS_M1.zip`, and a SHA256 checksum file.
  - Based on the official `astap_M1.pkg`; the main executable is replaced with the localized build and `languages/zh_CN/astap.po` is added.
- [Windows official-style artifact ASTAP-zh-windows](https://github.com/songshugong/ASTAP-zh/actions/runs/26894920012/artifacts/7389098001)
  - Includes `astap_zh_setup.exe`, `astap_zh.zip`, and a SHA256 checksum file.
  - Based on the file layout produced by the official `astap_setup.exe`; the main executable is replaced with the localized build and `languages/zh_CN/astap.po` is added.
- [iOS experimental CLI artifact ASTAP-zh-iOS-cli](https://github.com/songshugong/ASTAP-zh/actions/runs/25917201535/artifacts/7016844767)
  - Includes `astap_command-line_version_iOS_aarch64.zip` and a SHA256 checksum file.
  - This is an iOS aarch64 command-line solver, not a graphical iPhone/iPad app, and it is not signed for App Store distribution.
- [iOS graphical prototype IPA ASTAP-zh-iOS-prototype-ipa](https://github.com/songshugong/ASTAP-zh/actions/runs/25922202510/artifacts/7018905732)
  - Includes `ASTAP-zh-iOS-prototype.ipa` and a SHA256 checksum file.
  - Bundles the W08 wide-field star database and the iOS CLI engine resource. The UI can pick files, show bundled resources, and copy a CLI command example; the solver still needs to be converted into an in-process library interface.
- [iOS core MVP IPA ASTAP-zh-iOS-core-mvp](https://github.com/songshugong/ASTAP-zh/actions/runs/25935550796/artifacts/7024333782)
  - Includes `ASTAP-zh-iOS-core-mvp.ipa`, a SHA256 checksum file, and an unpack manifest. The artifact is about 195 MB. This build serializes ASTAP core calls to avoid crashes caused by concurrent solve requests.
  - This is an iOS MVP prototype with the ASTAP core connected: the UIKit app calls the Pascal solver core through a C ABI bridge and supports file picking, FITS parsing, image preview, header/table views, solve parameters, logs, and result display.
  - The workflow downloads and bundles the D05/G05 star databases from the official SourceForge package source; these large database files are not committed to this repository.

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

This fork currently mirrors the Windows 64-bit GUI installer/portable zip, the macOS Apple Silicon GUI pkg/zip, an experimental iOS aarch64 command-line solver, an iOS graphical prototype IPA, and an iOS core-connected MVP IPA.

#### Version and Limitations

- Unofficial build: this fork is not affiliated with the original ASTAP author or official distribution.
- License: ASTAP is licensed under MPL-2.0. This fork keeps the original license and copyright notices, and publishes the modified source in this repository.
- macOS: the workflow starts from the official ASTAP macOS package, keeps the official helper tools and bundle resources, then replaces the main executable and adds `languages/zh_CN/astap.po`.
- macOS signing: builds are ad-hoc signed and not Apple-notarized; macOS may require manual approval on first launch.
- Windows: the current build provides an official-style localized x64 installer and x64 portable zip. 32-bit GUI and Windows ARM64 CLI packages are not provided yet.
- iOS CLI: the experimental aarch64 command-line binary remains available separately. It must be embedded into a signed iOS app, developer workflow, or automation environment.
- iOS IPA: the core MVP IPA is ad-hoc signed and does not include a developer certificate or provisioning profile. It usually cannot be installed directly on a normal non-jailbroken device. It is a prototype, not an App Store/TestFlight distribution.
- iOS MVP scope: the first version covers file picking, FITS parsing, image preview, header/table views, solve parameters, logs, and result display; it does not replicate the full desktop ASTAP application.
- iOS package size: the core MVP IPA bundles the D05/G05 star databases, so the artifact is much larger than the normal GUI or command-line packages.
- Localization scope: static UI, menus, hints, common dialogs, and part of the dynamic UI text are localized. Some technical terms, logs, third-party strings, and standard FITS content may remain in English.
- Functional dependencies: star databases, index files, OpenSSL libraries, and other external data/components still follow the official ASTAP installation instructions.

### Build Workflows

The localized builds are produced from this fork by GitHub Actions:

- Windows x64: `.github/workflows/windows-astap-zh.yml`
- macOS: `.github/workflows/macos-astap-zh.yml`
- iOS core MVP: `.github/workflows/ios-astap-app.yml`

The macOS workflow starts from the official ASTAP macOS package, keeps the
official helper tools and bundle resources, then replaces the main executable
and adds `languages/zh_CN/astap.po`. The Windows workflow starts from the
official Windows installer layout, keeps the official helper tools and data
files, then replaces the main executable and adds the same language resources.
