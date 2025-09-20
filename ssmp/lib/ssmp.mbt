// lib/ssmp.mbt

// 导入所需的基础库
use core::result::{Result, Ok, Err}
use core::int::U32
use buf::{Buffer, BufferReader, BufferWriter}

// 定义解析器可能遇到的错误
pub enum ParseError {
  Incomplete // 数据不完整
}

// 解析器的状态机
enum State {
  // 正在等待读取4字节的长度头部
  ReadingLen
  // 正在等待读取指定长度的消息体
  ReadingBody(U32)
}

/// SSMP 协议解析器，用于处理流式数据
pub struct Parser {
  mut buffer: Buffer // 内部缓冲区，用于存储不完整的数据
  mut state: State   // 当前解析状态
}

impl Parser {
  // 创建一个新的解析器实例
  pub fn new() -> Self {
    {
      buffer: Buffer::new(),
      state: State::ReadingLen,
    }
  }

  /// 喂给解析器新的数据块，并尝试解析出零个或多个完整的消息。
  /// 返回一个包含所有已解析消息的数组。
  pub fn feed(&mut self, data: Bytes) -> Array[Bytes] {
    // 将新数据写入内部缓冲区
    self.buffer.write_bytes(data)

    let mut messages = Array::new()
    loop {
      match self.state {
        State::ReadingLen => {
          // 检查缓冲区数据是否足够读取一个完整的头部（4字节）
          if self.buffer.readable_bytes() >= 4 {
            // 读取大端序的U32作为消息体长度
            let body_len = self.buffer.read_u32_be().unwrap()
            // 转换状态，准备读取消息体
            self.state = State::ReadingBody(body_len)
          } else {
            // 数据不够，跳出循环，等待更多数据
            break
          }
        }
        State::ReadingBody(body_len) => {
          // 检查缓冲区数据是否足够读取一个完整的消息体
          if self.buffer.readable_bytes() >= (body_len as Int) {
            // 读取指定长度的消息体
            let payload = self.buffer.read_bytes(body_len as Int).unwrap()
            // 将完整的消息添加到结果数组中
            messages.push(payload)
            // 重置状态，准备解析下一个消息
            self.state = State::ReadingLen
          } else {
            // 数据不够，跳出循环，等待更多数据
            break
          }
        }
      }
    }
    messages
  }
}

/// 将载荷（Bytes）序列化为 SSMP 消息包
pub fn serialize(payload: Bytes) -> Bytes {
  let len = payload.length()
  // 创建一个足够大的缓冲区来存放头部和载荷
  let mut buf = Buffer::with_capacity(4 + len)
  // 写入大端序的长度
  buf.write_u32_be(len as U32)
  // 写入载荷
  buf.write_bytes(payload)
  // 返回完整的消息包
  buf.to_bytes()
}