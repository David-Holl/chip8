struct Display:
  var pixels : List[Bool]
  var len : UInt16
  var res_x : UInt8
  var res_y : UInt8

  def __init__(out self):
    self.res_x = 64
    self.res_y = 32
    self.len = UInt16(self.res_x) * UInt16(self.res_y)
    self.pixels = List[Bool](length=Int(self.len), fill=False)

  def draw(mut self, x:UInt8, y:UInt8)->Bool:
    debug_assert(x < self.res_x, "display overflow @ x:", x)
    debug_assert(y < self.res_y, "display overflow @ y:", y)
    var index = UInt16(y) * UInt16(self.res_x) + UInt16(x)
    var collision = self.pixels[index]
    self.pixels[index] = not collision
    return collision

  def clear(mut self):
    for index in range(self.len):
      self.pixels[index] = False
  def debug_print(self):
      for y in range(32):
          var row = String("")
          for x in range(64):
              var index = y * 64 + x
              if self.pixels[index]:
                  row += "*"
              else:
                  row += " "
          print(row)

