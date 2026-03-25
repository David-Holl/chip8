struct Register:
  var general: List[UInt8]
  var i : UInt16
  var pc: UInt16
  var st : UInt8
  var dt : UInt8
  var sp : UInt8
  var stack : List[UInt16]

  def __init__(out self):
    self.general = List[UInt8](length=16, fill=0)
    self.i = UInt16(0)
    self.pc = UInt16(0x200)
    self.st = UInt8(0)
    self.dt = UInt8(0)
    self.sp = UInt8(0)
    self.stack = List[UInt16](length=16, fill=0)

  def read(self, v: UInt8)-> UInt8:
    debug_assert(v < 16, "register access violation @ register: ", v)
    return self.general[v]
  
  def write(mut self, v:UInt8, byte:UInt8)->None:
    debug_assert(v < 16, "register access violation @ register: ", v)
    self.general[v] = byte


  def tick(mut self):
    if self.st != 0:
      self.st -= 1
    if self.dt != 0:
      self.dt -= 1
    
    
    
