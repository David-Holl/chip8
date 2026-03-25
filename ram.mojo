struct RAM:
  var storage : List[UInt8]

  def __init__(out self):
    self.storage = List[UInt8](length=4096, fill=0)

  def read(self, address: UInt16) -> UInt8:
    debug_assert(address < 4096, "ram access violation @ address: ", address)
    return self.storage[address]
  
  def write(mut self, address: UInt16, byte: UInt8)->None:
    debug_assert(address < 4096, "ram access violation @ address: ", address)
    self.storage[address] = byte
    
