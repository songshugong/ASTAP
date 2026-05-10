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

当前汉化构建基于 ASTAP `2026.04.21`，源码提交：
`d322a51 Fix macOS official app signing`。

#### 下载

- [macOS 构建产物 ASTAP-zh-macos](https://github.com/songshugong/ASTAP/actions/runs/25603796218/artifacts/6896440313)
- [Windows x64 构建产物 ASTAP-zh-windows-x64](https://github.com/songshugong/ASTAP/actions/runs/25603450911/artifacts/6896293102)

这些链接是 GitHub Actions artifact 直链，可能需要登录 GitHub，并受 GitHub artifact
保留期限限制。更适合长期公开分发的方式是后续创建 GitHub Release，并把同一批 `.zip`、
`.pkg`、`.exe`/Windows zip 上传为 Release assets。

#### 版本和限制

- 非官方版本：本 fork 与 ASTAP 原作者和官方发布无隶属关系。
- 许可证：ASTAP 使用 MPL-2.0。本 fork 保留原许可证和版权声明，修改源码公开在本仓库。
- macOS：构建流程以官方 macOS 安装包为底包，保留官方辅助工具和资源，再替换汉化后的主程序并加入 `languages/zh_CN/astap.po`。
- macOS 签名：当前使用 ad-hoc 签名，没有 Apple notarization；首次运行可能需要在系统安全设置中手动允许。
- Windows：当前提供 x64 汉化 zip 构建；未制作官方风格安装器。
- 汉化范围：主要覆盖静态界面、菜单、提示、常见弹窗和部分动态文本。少量专业术语、日志、第三方/标准 FITS 内容可能仍保留英文。
- 功能限制：星表数据库、索引文件、OpenSSL 依赖等外部数据/组件仍按 ASTAP 官方说明单独安装或配置。

### English

This is an unofficial Simplified Chinese localization fork of ASTAP. The
localization is based on Lazarus `.po` resources plus a small runtime UI text
mapping layer. The goal is to provide a Chinese UI while keeping the official
ASTAP behavior and package layout as intact as possible.

The current localized builds are based on ASTAP `2026.04.21`, source commit:
`d322a51 Fix macOS official app signing`.

#### Downloads

- [macOS artifact ASTAP-zh-macos](https://github.com/songshugong/ASTAP/actions/runs/25603796218/artifacts/6896440313)
- [Windows x64 artifact ASTAP-zh-windows-x64](https://github.com/songshugong/ASTAP/actions/runs/25603450911/artifacts/6896293102)

These are direct GitHub Actions artifact links. They may require a GitHub login
and are subject to GitHub's artifact retention policy. For public long-term
distribution, GitHub Releases are recommended; the same `.zip`, `.pkg`, and
Windows zip assets can then be attached to a release.

#### Version and Limitations

- Unofficial build: this fork is not affiliated with the original ASTAP author or official distribution.
- License: ASTAP is licensed under MPL-2.0. This fork keeps the original license and copyright notices, and publishes the modified source in this repository.
- macOS: the workflow starts from the official ASTAP macOS package, keeps the official helper tools and bundle resources, then replaces the main executable and adds `languages/zh_CN/astap.po`.
- macOS signing: builds are ad-hoc signed and not Apple-notarized; macOS may require manual approval on first launch.
- Windows: the current build is a localized x64 zip package, not an official-style installer.
- Localization scope: static UI, menus, hints, common dialogs, and part of the dynamic UI text are localized. Some technical terms, logs, third-party strings, and standard FITS content may remain in English.
- Functional dependencies: star databases, index files, OpenSSL libraries, and other external data/components still follow the official ASTAP installation instructions.

### Build Workflows

The localized builds are produced from this fork by GitHub Actions:

- Windows x64: `.github/workflows/windows-astap-zh.yml`
- macOS: `.github/workflows/macos-astap-zh.yml`

The macOS workflow starts from the official ASTAP macOS package, keeps the
official helper tools and bundle resources, then replaces the main executable
and adds `languages/zh_CN/astap.po`.
