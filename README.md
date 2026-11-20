# AMMDS Launcher

AMMDS Launcher 是 AMMDS v2 的 Windows 系统托盘启动器，用于启动、停止、重启
AMMDS 原生镜像后端，并打开 Web 管理界面。

## v2 变化

AMMDS v2 使用 GraalVM Native Image + AWT/Java2D，`ammds.exe` 不再是单文件：

- 同目录需要 `awt.dll`、`fontmanager.dll`、`freetype.dll`、`javajpeg.dll`、
  `jawt.dll`、`lcms.dll`、`mlib_image.dll`、`javaaccessbridge.dll`、`java.dll`、
  `jvm.dll`、`management_ext.dll`；
- 还需要 `lib/fontconfig.bfc`（启动器/服务会把 `java.home` 指向 exe 目录）。

这些运行库与构建所用 GraalVM/JDK 版本绑定，已固定在 [runtime](runtime) 目录随仓库分发；
安装器和 zip 包会把它们与 `ammds.exe` 一起放置。

## 目录结构

```text
launcher.go         托盘程序（Go / systray）
runtime/            v2 Windows 原生运行库与 lib/fontconfig.bfc
Languages/          Inno Setup 语言文件（简中/繁中/英/日/韩）
installer.iss       Inno Setup 安装脚本
build.ps1           本地构建与打包脚本
.github/workflows/  发布构建（下载 v2 核心 + 构建安装包）
```

## 构建要求

- Go 1.25+
- MinGW-w64 或 TDM-GCC（systray 的 CGO 依赖），`go env CGO_ENABLED` 应为 `1`
- Inno Setup 6 / 7（仅生成安装包需要）
- AMMDS v2 的 `ammds.exe`（从 AMMDS release 下载，或从本机构建产物 `target\ammds.exe` 获取）

## 构建

```powershell
# ammds.exe 放在仓库根目录时
.\build.ps1 -Version 2.0.0

# 指定核心路径
.\build.ps1 -Version 2.0.0 -CoreExe "C:\path\to\ammds.exe"

# 只构建启动器，不生成安装包
.\build.ps1 -NoInstaller

# 复用已构建的启动器，只重新打包
.\build.ps1 -NoBuild
```

脚本会：

1. 构建 `dist\AMMDS-Launcher.exe`（Go + goversioninfo 资源）；
2. 复制 `ammds.exe`；
3. 从 `runtime\` 复制全部 DLL 与 `lib\fontconfig.bfc` 到 `dist\`；
4. 调用 Inno Setup 生成 `dist\ammds-setup.exe`。

`dist` 中最终应包含：

```text
AMMDS-Launcher.exe
ammds.exe
*.dll
lib\fontconfig.bfc
icon.ico / logo.ico
ammds-setup.exe
```

## 安装流程

安装器支持 5 种语言（安装时自动匹配系统 UI 语言，也可手动切换）：

- 简体中文 `chs`
- 繁体中文 `cht`
- English `en`
- 日本語 `ja`
- 한국어 `ko`

可选任务：

- **删除数据目录**：勾选后，在复制安装文件之前先结束 Launcher/ammds 进程，并删除
  `%LOCALAPPDATA%\AMMDS`（以及 `{app}\data`、`{app}\db`、`{app}\logs` 兜底）。
  v1 与 v2 数据结构不兼容，升级建议勾选；删除后不可恢复。
- 创建桌面图标
- 创建开始菜单项

安装器以管理员权限写入 `{autopf}\ammds`，并确保 `ammds.exe`、DLL 与
`lib\fontconfig.bfc` 的相对布局正确。

## 数据目录

Launcher 以 `%LOCALAPPDATA%\AMMDS` 作为工作目录启动 `ammds.exe`，v2 的
`data`、`db`、`logs` 均位于该目录下。托盘菜单「打开目录」可直接打开。

## 卸载

安装后的卸载程序为 `AMMDS-Uninstall.exe`（不再是 `unins000.exe`），控制面板
「应用和功能」中的卸载入口也已指向它。

- 交互式卸载会询问：**是否同时删除 AMMDS 数据目录**；选择「是」会删除
  `%LOCALAPPDATA%\AMMDS` 与安装目录下的 `data/db/logs`，不可恢复；
- 静默卸载默认保留数据；如需删除：

```powershell
AMMDS-Uninstall.exe /VERYSILENT /SUPPRESSMSGBOXES /DELETEUSERDATA
```

卸载收尾阶段会再次清理 `%LOCALAPPDATA%\AMMDS`，避免 `AMMDS-Launcher --uninstall`
重新创建 `logs` 目录后残留。

## 使用

1. 安装后运行 `AMMDS-Launcher.exe`；
2. 程序在系统托盘运行，自动选择端口并启动后端（优先 80，其次复用上次端口/随机端口）；
3. 托盘菜单提供启动/停止/重启、打开面板、打开数据目录、开机自启、官网/帮助/退出。

首次启动会打开 Web 初始化页面；v2 不再使用默认管理员环境变量，按页面创建管理员即可。

## 发布构建（GitHub Actions）

发布 `vX.Y.Z` 后，工作流会：

1. 从 AMMDS v2 release 下载核心包（默认尝试 `AMMDS` 仓库的
   `ammds.zip` / `ammds-windows.zip` / `ammds-windows-amd64.zip`，再回退旧仓库）；
2. 用 `runtime/` 中的固定运行库构建启动器与安装包；
3. 上传 `ammds-setup.exe` 与 `ammds.zip`（zip 内包含 DLL 与 `lib/fontconfig.bfc`）。

若核心包地址不同，在仓库变量中设置：

```text
AMMDS_CORE_ZIP_URL = https://.../ammds.zip
```

## 升级运行库

AMMDS 切换 GraalVM/JDK 版本后：

1. 从 AMMDS 构建产物 `target\` 复制新的 DLL，从 `target\lib\` 复制 `fontconfig.bfc`；
2. 整体替换 [runtime](runtime)；
3. 重新执行 `build.ps1` 生成安装包。

## 故障排除

- 封面不可用：确认 `{app}` 下 DLL 与 `lib\fontconfig.bfc` 存在（安装包应已包含）；
- 服务无法启动：查看 `%LOCALAPPDATA%\AMMDS\logs\launcher.log`，并确认 `{app}\ammds.exe` 存在；
- 端口冲突：设置 `AMMDS_SERVER_PORT` 环境变量后重启 Launcher；
- 升级后数据异常：卸载/重装时勾选「删除数据目录」，v1/v2 数据不要混用。

## 许可证

本项目由 [新疆萌森软件开发工作室](https://blog.lifebus.top/) 开发，遵循 [MIT 许可证](LICENSE)。
