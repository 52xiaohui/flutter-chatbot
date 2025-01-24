# Flutter ChatBot

一个基于Flutter开发的跨平台聊天机器人应用，支持多种AI模型和文件上传功能。

## 功能特性

- 支持多种AI模型切换
- 支持文本聊天
- 支持图片上传和显示
- 支持PDF/DOC/TXT/MD等文档上传
- 多语言支持
- 跨平台支持（Android/iOS/Windows/Linux/macOS）

## 安装

1. 确保已安装Flutter SDK
2. 克隆本项目
3. 运行以下命令安装依赖：
```bash
flutter pub get
```
4. 运行应用：
```bash
flutter run
```

## 使用方法

1. 启动应用后，在输入框中输入消息
2. 点击左侧文件图标上传图片或文档
3. 点击发送按钮发送消息
4. 长按消息可进行复制、编辑、删除等操作

## 项目结构

```
lib/
├── chat/            # 聊天相关组件
├── config.dart      # 配置文件
├── gen/             # 自动生成的文件
├── image/           # 图片处理相关
├── l10n/            # 多语言支持
├── llm/             # 大语言模型相关
├── main.dart        # 应用入口
├── markdown/        # Markdown相关
├── settings/        # 设置相关
├── util.dart        # 工具函数
└── workspace/       # 工作区相关
```

## 依赖

- flutter_riverpod: 状态管理
- file_picker: 文件选择
- image_picker: 图片选择
- flutter_markdown: Markdown渲染

## 许可证

本项目采用GPL-3.0许可证，详情见COPYING文件。
