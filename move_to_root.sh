#!/bin/bash

set -e

# 1. 检查 SystemMonitor 目录是否存在
if [ ! -d "SystemMonitor" ]; then
  echo "❌ 未找到 SystemMonitor 目录，已在根目录，无需迁移。"
  exit 1
fi

# 2. 检查根目录是否已有 Package.swift，避免覆盖
if [ -f "Package.swift" ]; then
  echo "⚠️ 根目录已有 Package.swift，已终止迁移，避免覆盖。"
  exit 1
fi

# 3. 移动文件和目录
mv SystemMonitor/Package.swift ./
mv SystemMonitor/Sources ./
mv SystemMonitor/Tests ./

# 4. 可选：移动其它自定义文件（如 .gitignore、README.md）
if [ -f SystemMonitor/.gitignore ]; then mv SystemMonitor/.gitignore ./; fi
if [ -f SystemMonitor/README.md ]; then mv SystemMonitor/README.md ./; fi

# 5. 删除空的 SystemMonitor 目录
rmdir SystemMonitor

echo "✅ 迁移完成！请在根目录下运行 swift build 和 swift test 进行验证。" 