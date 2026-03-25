from chip8 import Chip8
from std.sys import argv
from sdl import SDL



def main() raises:
  var sdl = SDL()
  print("SDL ready")
  var chip8 = Chip8()
  print("chip8 created")
  args = argv()
  with open(args[1], "r") as rom:
    var content = rom.read_bytes()
    for i in range(UInt16(len(content))):
        chip8.ram.write(address=512 + i, byte=content[i])

  print("game loaded")
  while True:
    sdl.poll_events(chip8.keyboard)
    var op_code = chip8.fetch()
    chip8.decode_and_execute(op_code)
    sdl.render(chip8.display.pixels)
    chip8.register.tick()


