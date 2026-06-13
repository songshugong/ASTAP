# Windows 汉化安装与翻译优化说明

本文记录 ASTAP-zh Windows 产物的本地优化目标、安装逻辑和本次已处理内容。

## 目标

Windows 汉化版同时保留两种使用方式：

- 对已经安装官方 ASTAP 的用户，安装器尽量作为最小替换包使用，保留官方目录、文件名和常见联动路径。
- 对没有安装 ASTAP 的用户，安装器仍然可以作为完整汉化安装包使用，补齐官方 Windows 运行文件。

这个目标的重点是兼容官方使用习惯，而不是修改 ASTAP 原项目功能。

## 安装包逻辑

Windows 工作流仍然生成一个主安装包 astap_zh_setup.exe 和一个便携包 astap_zh.zip。

主安装包安装时遵循以下策略：

- astap.exe 始终更新为汉化构建。
- languages\zh_CN\astap.po 始终更新。
- ASTAP-zh_README.txt 始终更新。
- 官方运行辅助文件只在目标目录缺失时补齐，不覆盖已有文件。
- 构建产物不再携带官方安装目录中的 unins*.* 卸载状态文件。
- 安装器会尝试从 Windows 卸载注册表和默认目录识别已有 ASTAP 安装位置，方便直接安装到官方目录。
- ASTAP-zh 自身的卸载记录放在公共数据目录下，避免覆盖官方安装目录里的卸载记录。

这样，新安装时仍然能获得完整目录；覆盖官方目录时，主要变成主程序和语言资源替换。

## 便携包逻辑

astap_zh.zip 保留完整运行所需文件，适合直接解压使用。

便携包不应包含官方安装器生成的 unins000.exe、unins000.dat 等卸载状态文件。它们属于某次安装行为的副产物，不适合跟随便携包分发。

## 翻译处理原则

本次只修复明显影响中文体验的翻译问题，不改变原项目逻辑。

优先修复：

- 明显多出来的快捷键前缀，例如 B平衡...、R获取...。
- 明显误译，例如把 blink 翻成“链接”。
- 明显领域错误，例如把 right ascension correction 翻成“飞行高度校正”。

谨慎保留：

- FITS 关键字，例如 BAYERPAT、NAXIS、BITPIX。
- 坐标和列名缩写，例如 X ref、Y ref、R_out、G_out、B_out。
- 外部系统和标准缩写，例如 AAVSO、Gaia、LRGB、OSC、SNR、SQM。
- 命令行和外部程序集成用的结果键，例如 PLTSOLVD、ERROR、WARNING、CRPIX、CRVAL、CD1_1、CD2_2。

这些字段可能被用户按英文教程识别，也可能在代码里作为列名、通道名或关键字参与处理，因此不做激进汉化。

## NINA 兼容性处理

NINA 调用 ASTAP 时不是读取 ASTAP GUI 弹窗，而是运行 astap.exe 命令行参数，并读取同名 .ini 结果文件。

NINA 依赖的机器可读字段必须保持英文键名：

- PLTSOLVD=T/F
- ERROR=...
- WARNING=...
- CRPIX1、CRPIX2、CRVAL1、CRVAL2
- CD1_1、CD1_2、CD2_1、CD2_2

因此本项目只汉化 ERROR= 和 WARNING= 后面的用户可见内容，并保留英文原文，格式类似：

- ERROR=No star database found. / 未找到星表数据库。
- WARNING=Warning scale was inaccurate! / 警告：图像比例不准确，请参考后续 FOV/scale/FL 数值。 Set FOV=...

这样 NINA 的解析逻辑仍然能按原键名工作；同时 NINA 弹窗里由 ASTAP 传入的失败原因和警告细节会带中文说明。

## 本次已修复的翻译类型

- RGB 平衡说明。
- 2x2 像素合并说明。
- 在线区域查询说明。
- AAVSO 星图获取说明。
- 光污染梯度移除说明。
- 蓝色信号标签。
- 天文图像闪烁检查说明。
- 赤经修正说明。
- 重置加法和乘法因子说明。
- 高斯模糊半径说明。
- 背景值标签。
- 浏览到其他位置说明。
- NINA/外部程序会显示的 ASTAP 命令行 .ini 错误和警告说明。

## 后续建议

后续继续优化时，建议先处理明显坏翻译和长提示语，再处理专业术语一致性。不要优先把短缩写、FITS 标准字段、滤镜名和通道名翻成中文。

如果要进一步增强安装体验，建议在 Windows 虚拟机里验证：

- 未安装 ASTAP 时完整安装是否可启动。
- 已安装官方 ASTAP 时是否只更新主程序和语言文件。
- 官方卸载项和 ASTAP-zh 卸载项是否互不覆盖。
- NINA、APT、Voyager 等外部程序是否仍可通过原路径调用 astap.exe。

## 本机验证记录

Mac 侧已完成：

- GitHub Actions workflow 的 YAML 解析检查。
- git diff --check 空白和补丁格式检查。
- languages\zh_CN\astap.po 翻译统计检查。
- 明显异常前缀检查，B平衡...、R获取... 这类问题已清零。

Windows 虚拟机侧已完成：

- 使用 Parallels 的 Windows 11 mini 执行命令验证。
- 现有云端 release 安装包可静默安装到 C:\ASTAP_ZH_TEST。
- 当前旧 release 会在安装目录生成 unins000.exe 和 unins000.dat，证明原发布包确实存在覆盖卸载状态文件的风险。
- 旧 release 的卸载注册表项出现在 HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall，并包含 InstallLocation。因此 workflow 已补充查找 HKLM32 和 HKLM64 两个注册表视图。
- 语言资源安装后位于 C:\ASTAP_ZH_TEST\languages\zh_CN\astap.po。

暂未完成：

- 本地 Windows VM 没有安装 Inno Setup、Lazarus、Chocolatey 或 winget，无法在本机直接重建新的 astap_zh_setup.exe。
- 新安装器的最终实装行为仍需在 GitHub Actions 或装好 Inno/Lazarus 的 Windows 环境中重建后验证。
