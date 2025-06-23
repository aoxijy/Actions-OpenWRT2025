# OpenWrt-Build

基于 **Lean、ImmortalWrt** 等主流分支构建的 **自动化固件编译方案**，通过 GitHub Actions 实现全流程云端构建，聚焦高效、可持续的 OpenWrt 自动编译实践。

## 🛠 编译状态

[![构建状态](https://img.shields.io/github/actions/workflow/status/xcz-ns/OpenWrt-Build/OpenWrt-Actions.yml?label=构建状态&style=for-the-badge&logo=github-actions)](https://github.com/xcz-ns/OpenWrt-Build/actions)

## 📦 固件下载

[![固件下载](https://img.shields.io/github/v/release/xcz-ns/OpenWrt-Build?style=for-the-badge&label=固件下载&logo=github)](https://github.com/xcz-ns/OpenWrt-Build/releases)

## 📚 项目概述

本项目整合多个优秀的开源仓库与自动化脚本，在稳定性、灵活性与可维护性之间实现平衡，旨在打造一套**开箱即用、长期演进**的 OpenWrt 编译体系。

### 🔧 集成源码与脚本来源

- [Lean's OpenWrt](https://github.com/coolsnowwolf/lede)
- [ImmortalWrt](https://github.com/immortalwrt/immortalwrt)
- [xiaorouji's Package](https://github.com/xiaorouji/openwrt-passwall)
- [P3TERX](https://github.com/P3TERX/Actions-OpenWrt)
- [281677160](https://github.com/281677160/openwrt-package)
- [db-one](https://github.com/db-one/OpenWrt-AutoBuild)

## 🛠 项目特性

- ✅ 多平台、多分支构建支持（Lean、ImmortalWrt 等）
- ☁️ GitHub Actions 云端编译，**本地零负担**
- 📦 构建结果自动发布，可对接 Telegram 通知/机器人
- ⚙️ 支持灵活定制构建流程与配置（缓存、插件、配置文件等）

