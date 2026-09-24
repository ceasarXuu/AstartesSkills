---
name: macos-window-screenshot
description: 在 macOS 上需要对指定 App 的指定窗口截图时使用；通过窗口清单、身份核对和单窗口截图避免误截全屏或其他窗口。
---

# macOS 指定窗口截图

使用本 skill 的 `scripts/window-shot.swift`。脚本只列出当前可见的普通窗口，按窗口 ID 截图，并在截图前核对所属 App 的 bundle ID。它不会自行切换前台 App。

## 流程

1. 运行 `swift scripts/window-shot.swift list`。知道 bundle ID 时加 `--bundle-id com.example.app` 缩小清单。清单含窗口 ID、App、标题、坐标和尺寸；不要根据前台 App、坐标或列表第一项推测目标。
2. 用用户指定的 App 和窗口信息选定唯一候选。多个窗口难以区分时，利用标题、尺寸等已有线索；仍不能确定时请用户指明，不要试截其他窗口来猜测内容。窗口 ID 可能变化，截图前重新列出清单。
3. 运行 `swift scripts/window-shot.swift capture --window-id 123 --bundle-id com.example.app --output /absolute/path.png`。需要严格匹配标题时加 `--title '准确标题'`。目标文件须不存在；脚本会拒绝覆盖，并输出图片路径、实际窗口身份和像素尺寸。
4. 用可用的图像查看工具检查生成图片确实是目标窗口且内容可读，再交付给用户。元数据和成功退出码不能代替视觉核对。不要将全屏截图静默当成窗口截图。

## 失败处理

- 找不到窗口：检查它是否在当前桌面空间可见，重新列出清单；不自行激活、移动或调整用户窗口。
- 标题为空或变化：标题仅作辅助线索；依赖 bundle ID、窗口 ID 和其他可见信息确认。无法区分时询问用户。
- 截图失败或图像为空：检查 macOS“隐私与安全性 → 屏幕与系统音频录制”权限。权限变更后可能需要重启执行脚本的终端或代理宿主进程。不要用截全屏或裁剪坐标绕过失败。

脚本依赖 macOS 自带的 Swift、CoreGraphics 和 `screencapture`。截图文件应保存到用户指定位置，或任务明确可用的临时目录。
