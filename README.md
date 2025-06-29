### 📚 项目概述

基于 **Lean、ImmortalWrt** 等主流分支，打造了一套 **自动化固件编译方案**，通过 GitHub Actions 实现全流程云端构建，聚焦高效且可持续的 OpenWrt 自动编译实践。本项目整合多个优秀开源仓库与自动化脚本，兼顾稳定性、灵活性与可维护性，致力于构建一套**开箱即用、长期演进**的现代化 OpenWrt 编译体系。

### 🏗️ 项目特性

- 多平台、多分支构建支持（Lean、ImmortalWrt 等）
- GitHub Actions 云端编译，本地零负担
- 构建结果自动发布，可对接 Telegram/企业微信 通知
- 支持灵活定制构建流程与配置（缓存、插件、配置文件等）

### 🛠 编译状态

[![构建状态](https://img.shields.io/github/actions/workflow/status/xcz-ns/OpenWrt-Build/OpenWrt-Actions.yml?label=构建状态&style=for-the-badge&logo=github-actions)](https://github.com/xcz-ns/OpenWrt-Build/actions)

### 📦 固件下载

[![固件下载](https://img.shields.io/github/v/release/xcz-ns/OpenWrt-Build?style=for-the-badge&label=固件下载&logo=github)](https://github.com/xcz-ns/OpenWrt-Build/releases)


### 🔧 集成源码

- **固件基础源码**

[![Lede](https://img.shields.io/badge/Lede-coolsnowwolf-ff69b4.svg?style=flat&logo=appveyor)](https://github.com/coolsnowwolf/lede)
 [![ImmortalWrt](https://img.shields.io/badge/ImmortalWrt-immortalwrt-ff69b4.svg?style=flat&logo=appveyor)](https://github.com/immortalwrt/immortalwrt)


- 核心插件与功能包

[![Passwall](https://img.shields.io/badge/openwrt_passwall-xiaorouji-8a2be2.svg?style=flat&logo=appveyor)](https://github.com/xiaorouji/openwrt-passwall)
 [![281677160](https://img.shields.io/badge/openwrt_package-281677160-8a2be2.svg?style=flat&logo=appveyor)](https://github.com/281677160/openwrt-package)


- 自动化脚本与流程

[![P3TERX](https://img.shields.io/badge/OpenWrt-P3TERX-blueviolet.svg?style=flat&logo=appveyor)](https://github.com/P3TERX/Actions-OpenWrt)
 [![db-one](https://img.shields.io/badge/OpenWrt_AutoBuild-db--one-orange.svg?style=flat&logo=appveyor)](https://github.com/db-one/OpenWrt-AutoBuild)
