// main 
fn main {
  let addr = "127.0.0.1:8088"
  let num_clients = 3 // 在这里设置要启动的客户端数量

  // 1. 在后台任务中启动服务器
  spawn server::start(addr)

  // 2. 短暂等待，确保服务器已开始监听
  os::sleep(1.0)

  // 3. 准备并启动多个客户端
  println("[Main] Starting \(num_clients) clients...")
  let wg = WaitGroup::new()
  for i = 0..num_clients {
    wg.add(1) // 为即将启动的客户端任务增加计数
    // `wg.clone()` 是必要的，因为它会被移动到新的任务中
    spawn client::start(i, addr, wg.clone())
  }

  // 4. 等待所有客户端任务完成
  // `wg.wait()` 会阻塞当前任务，直到WaitGroup的计数器降为0
  wg.wait()

  println("[Main] All client tasks have completed. Exiting.")
  // 主程序在这里结束
}