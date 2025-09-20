# ssmp-moonbit
SSMP implementation in MoonBit

这是一个使用 [MoonBit 语言](https://www.moonbitlang.com/) 实现的 [SSMP (Simple Simple Messaging Protocol) ](https://github.com/node/ssmp) 协议库及示例程序。

本项目包含一个健壮的协议库，用于序列化和反序列化 SSMP 消息，以及一个演示其用法的高性能 TCP 客户端/服务器应用。

## ✨ 功能特性
### 协议库 (lib/ssmp.mbt):

提供一个 serialize 函数，可将任意字节载荷（Bytes）打包成符合 SSMP 规范的消息。

提供一个带状态的 Parser 结构体，能够处理任意大小和分片的 TCP 数据流，并准确解析出完整的 SSMP 消息。

### 并发 TCP 服务器 (main/server.mbt):

一个多任务 TCP 服务器，为每一个客户端连接创建一个独立的协程（task）进行处理。

能够同时高效地处理多个客户端的并发请求。

### 并发 TCP 客户端 (main/client.mbt):

一个可以实例化多个的客户端模块。

主程序 (main/main.mbt) 演示了如何并发启动多个客户端实例，以测试服务器的并发处理能力。


## 📁 项目结构
```
ssmp-moonbit/
├── LICENSE             
├── README.md             
├── ssmp
  ├── lib/
  │   └── ssmp.mbt          # SSMP 协议库核心实现
  ├── moon.mod.json         # 项目模块定义
  ├── moon.pkg.json         # 项目包定义
├── ssmp-example
  └── main/
    ├── main.mbt          # 主程序入口，负责启动服务器和客户端
    ├── server.mbt        # TCP 服务器逻辑
    └── client.mbt        # TCP 客户端逻辑
  ├── moon.mod.json  
  ├── moon.pkg.json
```

## 🚀 开始使用

**前提准备**

您需要先安装 MoonBit 开发工具链。请参照 [MoonBit 官方网站](https://www.moonbitlang.com/) 的指引进行安装。

### 运行 Demo

将本项目克隆或下载到本地后，在项目根目录 ssmp-moonbit/ 下打开终端，执行以下命令：

``` Bash
moon run
```

程序将会启动一个服务器，然后启动3个客户端并发地向服务器发送消息并接收回复。整个过程在几秒钟内完成。

### 更多尝试

您可以基于此项目，开发满足你自己个性化需求的基于SSMP协议的网络应用程序，比如一个简单的物联网数据采集服务、一个手机WiFi热点信息收集服务等。

