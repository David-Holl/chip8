struct Keyboard:
  var keys: List[Bool]

  def __init__(out self):
    self.keys = List[Bool](length=16, fill= False)

  def key_down(mut self, key: UInt8):
    debug_assert(key < 16, "key not found @ ", key)
    self.keys[key]= True
  
  def key_up(mut self, key: UInt8):
    debug_assert(key < 16, "key not found @ ", key)
    self.keys[key]= False
    
