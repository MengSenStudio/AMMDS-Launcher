# Windows 原生运行库（v2）

AMMDS v2 的 Windows 发行版是 **GraalVM Native Image + AWT/Java2D**，`ammds.exe`
运行时还需要同目录的 JDK 动态库和 `lib/fontconfig.bfc`。这些文件与构建所用
GraalVM/JDK 版本绑定，属于固定运行库，因此随启动器仓库一起分发，避免每次
发布安装包时再从构建机拷贝。

## 文件

| 文件 | 说明 |
| :-- | :-- |
| `awt.dll`、`fontmanager.dll`、`freetype.dll`、`javajpeg.dll`、`jawt.dll`、`lcms.dll`、`mlib_image.dll` | AWT / Java2D / 图片编解码依赖 |
| `javaaccessbridge.dll` | JDK 可访问性库 |
| `java.dll`、`jvm.dll`、`management_ext.dll` | Native Image 运行期 JDK shim |
| `lib/fontconfig.bfc` | Windows 字体配置；`AwtSupport` 会把 `java.home` 指向 exe 目录 |

## 来源与升级

- 来源：AMMDS v2 仓库执行 `mvn -Pnative package` 后 `target/` 下的同名文件；
- 版本：Oracle GraalVM / JDK **25.0.1**（与 AMMDS v2 构建环境一致）；
- 升级 AMMDS 的 GraalVM/JDK 版本时，用新构建产物整体替换本目录，并重新执行
  `build.ps1` 生成安装包；
- 这些文件必须与 `ammds.exe` 位于同一目录（`lib/fontconfig.bfc` 位于 `lib/` 子目录），
  安装器已按该布局写入 `{app}`。
