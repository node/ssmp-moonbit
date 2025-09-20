// main/server.mbt

use ssmp
use moonbit/tcp::{TcpListener, TcpStream}
use moonbit/io::{Reader, Writer, close}
use core::result::{Result, Ok, Err}
use core::string::String

// 处理单个客户端连接的函数
fn handle_connection(mut stream: TcpStream) -> Result[Unit, String] {
  println("[Server] New connection received.")
  let mut parser = ssmp::Parser::new()
  let mut read_buf = Bytes::make(1024)

  loop {
    match stream.read(read_buf) {
      Ok(0) => {
        println("[Server] Connection closed by a client.")
        break
      }
      Ok(n) => {
        let data = read_buf.slice(0, n)
        let messages = parser.feed(data)

        for msg in messages.iter() {
          let content = msg.to_string_lossy()
          println("[Server] Parsed message: '\(content)'")

          let reply_payload = "Server ACK for: \(content)".to_bytes()
          let reply_packet = ssmp::serialize(reply_payload)
          stream.write(reply_packet)?
          println("[Server] Sent reply.")
        }
      }
      Err(e) => {
        println("[Server] Read error: \(e.to_string())")
        break
      }
    }
  }

  close(stream)
  Ok(())
}

/// 启动 TCP 服务器并开始监听连接
pub fn start(addr: String) {
  println("[Server] Starting on \(addr)...")
  match TcpListener::bind(addr) {
    Ok(listener) => {
      loop {
        match listener.accept() {
          Ok((stream, _)) => {
            // 为每个新连接创建一个独立的任务
            spawn handle_connection(stream)
          }
          Err(e) => {
            println("[Server] Accept error: \(e.to_string())")
            break
          }
        }
      }
    }
    Err(e) => {
      println("[Server] Failed to bind address: \(e.to_string())")
    }
  }
}