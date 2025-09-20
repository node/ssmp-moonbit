//use moonbit/tcp::TcpStream
//use moonbit/io::{Reader, Writer, close}
//use moonbit/sync::WaitGroup
//use core::result::{Result, Ok, Err}

/// 启动一个客户端实例
pub fn start(id: Int, addr: String, wg: WaitGroup) {
  // `finally` 确保无论函数如何退出（正常结束或出错），`wg.done()` 都会被调用
  finally {
    wg.done()
  }

  println("[Client \(id)] Connecting to \(addr)...")
  match TcpStream::connect(addr) {
    Ok(mut stream) => {
      println("[Client \(id)] Connected.")

      let messages_to_send = [
        "message 1 from client \(id)",
        "message 2 from client \(id)",
      ]

      for msg_str in messages_to_send.iter() {
        let packet = ssmp::serialize(msg_str.to_bytes())
        stream.write(packet).unwrap()
        println("[Client \(id)] Sent: '\(msg_str)'")
        os::sleep(0.2) // 短暂休眠，让输出不至于完全混乱
      }

      let mut parser = ssmp::Parser::new()
      let mut read_buf = Bytes::make(1024)
      let mut replies_received = 0
      let total_replies_expected = messages_to_send.length()

      // 设置一个简单的超时逻辑
      for _ = 0..10 { // 最多尝试读取10次
        if replies_received >= total_replies_expected { break }
        
        match stream.read(read_buf) {
          Ok(0) => break,
          Ok(n) => {
            let replies = parser.feed(read_buf.slice(0, n))
            for reply in replies.iter() {
              println("[Client \(id)] Received: '\(reply.to_string_lossy())'")
              replies_received += 1
            }
          }
          Err(_) => break
        }
        os::sleep(0.2)
      }
      println("[Client \(id)] Finished.")
      close(stream).unwrap()
    }
    Err(e) => {
      println("[Client \(id)] Failed to connect: \(e.to_string())")
    }
  }
}