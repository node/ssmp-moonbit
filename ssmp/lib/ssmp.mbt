use core::result::{Result, Ok, Err}
use core::int::U32
use buf::{Buffer, BufferReader, BufferWriter}

/// SSMP 协议解析器，用于处理流式数据。
///
/// 它可以接收任意大小的数据块，并在内部缓冲，
/// 当一个或多个完整的SSMP消息被解析出来时，将它们返回。
///
/// # Example
/// ```
/// let mut parser = ssmp::Parser::new()
/// // 模拟接收到的网络数据
/// let chunk1 = ssmp::serialize("hello".to_bytes()) 
/// let chunk2 = ssmp::serialize("world".to_bytes())
/// let messages = parser.feed(Bytes::concat(chunk1, chunk2))
/// assert(messages.length() == 2)
/// ```
pub struct Parser {
  mut buffer: Buffer
  mut state: State
}

// ...（内部 `enum State` 定义保持不变）...

impl Parser {
  /// 创建一个新的、状态为空的解析器实例。
  pub fn new() -> Self {
    {
      buffer: Buffer::new(),
      state: State::ReadingLen,
    }
  }

  /// 向解析器提供新的数据块 (`data`)，并尝试解析出零个或多个完整的消息。
  ///
  /// ## Parameters
  /// - `data`: 从网络流中读取到的原始字节数据。
  ///
  /// ## Returns
  /// 一个包含所有已成功解析出的消息载荷（`Bytes`）的数组。
  /// 如果没有解析出完整的消息，则返回空数组。
  pub fn feed(&mut self, data: Bytes) -> Array[Bytes] {
    // ... (函数实现保持不变) ...
    self.buffer.write_bytes(data)

    let mut messages = Array::new()
    loop {
      match self.state {
        State::ReadingLen => {
          if self.buffer.readable_bytes() >= 4 {
            let body_len = self.buffer.read_u32_be().unwrap()
            self.state = State::ReadingBody(body_len)
          } else {
            break
          }
        }
        State::ReadingBody(body_len) => {
          if self.buffer.readable_bytes() >= (body_len as Int) {
            let payload = self.buffer.read_bytes(body_len as Int).unwrap()
            messages.push(payload)
            self.state = State::ReadingLen
          } else {
            break
          }
        }
      }
    }
    messages
  }
}

/// 将载荷（`Bytes`）序列化为一个完整的 SSMP 消息包（头部 + 载荷）。
///
/// ## Parameters
/// - `payload`: 需要被打包发送的原始字节数据。
///
/// ## Returns
/// 一个包含了4字节大端序长度前缀和载荷的完整 SSMP 消息包。
pub fn serialize(payload: Bytes) -> Bytes {
  // ... (函数实现保持不变) ...
  let len = payload.length()
  let mut buf = Buffer::with_capacity(4 + len)
  buf.write_u32_be(len as U32)
  buf.write_bytes(payload)
  buf.to_bytes()
}