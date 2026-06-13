# ASTAP-zh

[![License](https://img.shields.io/badge/license-MPL%202.0-blue.svg)](https://opensource.org/licenses/MPL-2.0)
[![Mirror](https://img.shields.io/badge/Mirror-SourceForge-blue?color=red)](https://sourceforge.net/p/astap-program/code/)
![GitHub commit activity (branch)](https://img.shields.io/github/commit-activity/m/CanardConfit/ASTAP)

ASTAP-zh 是 ASTAP 的非官方简体中文本地化 fork。项目保留上游 ASTAP 的源码结构、主程序文件名、命令行协议和外部软件调用方式，在此基础上补充中文界面资源、Windows/macOS 打包流程，以及少量面向外部程序集成的双语提示。

本仓库基于公开的 ASTAP 源码镜像。ASTAP 原项目和官方发布仍由 Han Kleijn 维护：

- 原始 SourceForge 项目：https://sourceforge.net/p/astap-program/code/
- ASTAP 官方网站：https://www.hnsky.org/astap
- 官方安装说明：https://www.hnsky.org/astap#installation

当前汉化构建基于 ASTAP `2026.04.21`。

## 下载

- [macOS 安装包 astap_zh_M1.pkg](https://github.com/songshugong/ASTAP-zh/releases/download/v2026.06.13-zh.1/astap_zh_M1.pkg)
- [Windows 安装包 astap_zh_setup.exe](https://github.com/songshugong/ASTAP-zh/releases/download/v2026.06.13-zh.1/astap_zh_setup.exe)

## 项目概览

ASTAP 是一个面向天文图像的免费叠加、测光、FITS 浏览和天文解析程序。它使用 Object Pascal 编写，通过 Free Pascal Compiler 和 Lazarus 构建。ASTAP 的内置 plate solver 可以被 NINA、APT、Voyager、CCDCiel、SGP 等拍摄软件调用，用于解析图像、同步赤道仪或辅助构图。

ASTAP-zh 的目标不是重做 ASTAP，也不是改动其天文算法。这个 fork 主要做三件事：

- 提供简体中文界面资源，覆盖菜单、按钮、提示、常见弹窗和部分动态文本。
- 保留官方目录结构、主程序文件名和外部软件调用方式，尽量避免用户重新配置 NINA 等软件。
- 生成接近官方安装习惯的 Windows/macOS 构建产物，同时保留若干 iOS 实验性验证分支。

## 汉化范围

目前汉化主要来自 Lazarus `.po` 语言资源，以及少量运行时文本映射。已经覆盖的内容包括：

- 主界面菜单、工具栏、右键菜单和常见对话框。
- 多数静态提示文本和部分长提示语。
- Windows 构建中的 `languages/zh_CN/astap.po`。
- NINA 等外部程序可能显示的 ASTAP 命令行 `.ini` 错误和警告说明。

仍然会保留英文的内容包括：

- FITS 标准关键字，例如 `NAXIS`、`BITPIX`、`BAYERPAT`、`CRPIX`、`CRVAL`。
- 外部程序集成用字段，例如 `PLTSOLVD`、`ERROR`、`WARNING`。
- 数据库名、滤镜名、通道名、坐标缩写和部分专业术语。
- 上游日志、第三方字符串、星表字段和用户常按英文教程识别的内容。

保留这些英文不是遗漏，而是为了避免破坏 FITS、命令行输出、外部软件解析和教程对应关系。

## NINA 和外部软件兼容性

NINA 调用 ASTAP 时主要运行 `astap.exe`，然后读取同名 `.ini` 结果文件。NINA 解析的是固定键名，例如：

- `PLTSOLVD=T/F`
- `ERROR=...`
- `WARNING=...`
- `CRPIX1`、`CRPIX2`、`CRVAL1`、`CRVAL2`
- `CD1_1`、`CD1_2`、`CD2_1`、`CD2_2`

因此 ASTAP-zh 不翻译这些键名，只在 `ERROR=` 和 `WARNING=` 后面的用户可见内容中保留英文原文并追加中文说明。例如：

- `ERROR=No star database found. / 未找到星表数据库。`
- `WARNING=Warning scale was inaccurate! / 警告：图像比例不准确，请参考后续 FOV/scale/FL 数值。`

这样 NINA 的解析逻辑仍按官方 ASTAP 的格式工作，弹窗里也能看到中文原因说明。

## Windows 构建逻辑

Windows 版本的目标是同时具备“补丁”和“独立安装包”两种特性：

- 如果用户已经安装官方 ASTAP，安装器会尽量复用官方目录和 `astap.exe` 文件名。
- 安装到已有官方目录时，强制更新主程序、语言资源和说明文件。
- 其他官方运行文件只在缺失时补齐，避免覆盖用户已有的辅助文件、数据文件和官方卸载记录。
- 如果系统里没有 ASTAP，安装包也可以作为完整汉化版安装使用。
- 便携 zip 保留官方运行所需文件，适合解压后直接运行。

这套逻辑是为了减少 NINA、APT、Voyager 等软件重新指定 solver 路径的需求。

## 安装和使用

Windows 用户通常可以直接使用 `astap_zh_setup.exe`。如果已经安装官方 ASTAP，可以选择官方安装目录进行覆盖式安装；安装器会保留 `astap.exe` 文件名，以便外部软件继续通过原路径调用。

macOS 构建基于官方包结构，当前使用 ad-hoc 签名，没有 Apple notarization。首次运行可能需要在系统安全设置中手动允许。

## 官方包结构参考

官方当前公开包结构核对自 SourceForge：

- Windows GUI：`astap_setup.exe` 64 位安装器，约 6.3 MB；`astapwin32.zip` 32 位便携包，约 5.7 MB。
- Windows 命令行：`astap_command-line_version_win64.zip`、`win32.zip`、`win11_aarch64.zip`，约 275-331 kB。
- macOS GUI：`astap_M1.pkg` Apple Silicon，约 4.0 MB；`astap.pkg` Intel x86_64，约 4.5 MB。
- macOS 命令行：`astap_command-line_version_macOS_M1.zip`、`macOS_x86_64.zip`，约 1.3-1.4 MB。
- Linux GUI：amd64、i386、aarch64、armhf，并按 deb、tar.gz、rpm、pkg.tar.zst、GTK/QT 变体分发，约 4.0-8.9 MB。
- Android：只有命令行 solver，aarch64、armhf、x86、x86_64，约 330-338 kB。
- iOS：源码里有命令行 `.lpi` 目标，但官网当前没有公开 iOS 下载包。

本 fork 目前仿造并确认成功的下载内容是 Windows 64 位 GUI 安装器/便携 zip、macOS Apple Silicon GUI pkg/zip、实验性的 iOS aarch64 命令行 solver、iOS 图形壳原型 IPA，以及核心已接入的 iOS MVP IPA。

## 构建工作流

本地化构建主要由 GitHub Actions 生成：

- Windows x64：`.github/workflows/windows-astap-zh.yml`
- macOS：`.github/workflows/macos-astap-zh.yml`
- iOS core MVP：`.github/workflows/ios-astap-app.yml`

Windows workflow 会下载官方 Windows installer，静默安装到临时目录，然后以官方目录为底包替换本 fork 编译出的 `astap.exe` 和语言资源。macOS workflow 采用类似思路，从官方 macOS package 出发，保留官方 bundle 结构后替换主程序和语言资源。

本机如果要完整构建 Windows 安装包，需要 Windows 环境、Lazarus/lazbuild 和 Inno Setup。只有 Free Pascal Compiler 时，可以编译部分命令行目标，但不能生成完整 Windows GUI 安装包。

## 仓库结构

主要目录和文件：

- `astap_main.pas`、`*.lfm`、`*.lpi`：ASTAP GUI 主程序和 Lazarus 工程文件。
- `languages/zh_CN/astap.po`：简体中文语言资源。
- `command-line_version/`：ASTAP CLI 版本源码和工程文件。
- `.github/workflows/`：Windows、macOS、iOS 构建工作流。
- `ios_app/`：iOS 原型壳和核心接入 MVP 相关代码。
- `WINDOWS_ZH_OPTIMIZATION.md`：Windows 汉化安装、覆盖逻辑和 NINA 兼容处理记录。

## 限制

- 这是非官方 fork，不代表 ASTAP 原作者或官方发布渠道。
- 汉化仍在整理中，部分专业内容会保留英文。
- 外部程序依赖的字段、文件名和命令行协议不会为了中文显示而改名。
- iOS 产物为实验性原型，不保证可直接安装到普通设备。
- 星表数据库等大文件通常不提交到仓库，仍从官方来源下载或由 workflow 获取。

## License

ASTAP is licensed under MPL-2.0. This fork keeps the original license and copyright notices. Source modifications are published in this repository under the same license.

## 上游官方 README

以下内容保留自上游 ASTAP README，方便对照官方项目定位、功能和安装入口。

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
