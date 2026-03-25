from ram import RAM
from register import Register
from display import Display
from keyboard import Keyboard

from std.random import random_ui64


struct Chip8:
    var ram: RAM
    var register: Register
    var display: Display
    var keyboard: Keyboard

    def __init__(out self):
        self.ram = RAM()
        self.register = Register()
        self.display = Display()
        self.keyboard = Keyboard()
        self._load_fonts()

    def _load_fonts(mut self):
        var fonts: List[UInt8] = [ 
            0xF0, 0x90, 0x90, 0x90, 0xF0,
            0x20, 0x60, 0x20, 0x20, 0x70,
            0xF0, 0x10, 0xF0, 0x80, 0xF0,
            0xF0, 0x10, 0xF0, 0x10, 0xF0,
            0x90, 0x90, 0xF0, 0x10, 0x10,
            0xF0, 0x80, 0xF0, 0x10, 0xF0,
            0xF0, 0x80, 0xF0, 0x90, 0xF0,
            0xF0, 0x10, 0x20, 0x40, 0x40,
            0xF0, 0x90, 0xF0, 0x90, 0xF0,
            0xF0, 0x90, 0xF0, 0x10, 0xF0,
            0xF0, 0x90, 0xF0, 0x90, 0x90,
            0xE0, 0x90, 0xE0, 0x90, 0xE0,
            0xF0, 0x80, 0x80, 0x80, 0xF0,
            0xE0, 0x90, 0x90, 0x90, 0xE0,
            0xF0, 0x80, 0xF0, 0x80, 0xF0,
            0xF0, 0x80, 0xF0, 0x80, 0x80
          ]
        for i in range(UInt16(len(fonts))):
            self.ram.write(address=i, byte=fonts[i])


    def fetch(mut self) -> UInt16:
        var address = self.register.pc
        var byte_l = self.ram.read(address)
        var byte_r = self.ram.read(address + 1)
        self.register.pc += 2
        var result = ((UInt16(byte_l) << 8) | UInt16(byte_r))
        return result


    def decode_and_execute(mut self, op_code: UInt16) -> None:
        var op = op_code
        var cat = op >> 12
        var x = UInt8((op & 0x0F00) >> 8)
        var y = UInt8((op & 0x00F0) >> 4)
        var nnn = op & 0x0FFF
        var kk = UInt8(op & 0x00FF)
        if cat == 0:
            self.cat_0(op=op)
        elif cat == 1:
            self.register.pc = nnn
        elif cat == 2:
            self.cat_2(nnn=nnn)
        elif cat == 3:
            self.cat_3(x=x, kk=kk)
        elif cat == 4:
            self.cat_4(x=x, kk=kk)
        elif cat == 5:
            self.cat_5(x=x, y=y)
        elif cat == 6:
            self.register.write(v=x, byte=kk)
        elif cat == 7:
            self.cat_7(x=x, kk=kk)
        elif cat == 8:
            self.cat_8(op=op, x=x, y=y)
        elif cat == 9:
            self.cat_9(x=x, y=y)
        elif cat == 0xA:
            self.register.i = nnn
        elif cat == 0xB:
            self.register.pc = nnn + UInt16(self.register.read(v=0x0))
        elif cat == 0xC:
            var anded = UInt8(random_ui64(0, 255)) & kk
            self.register.write(v=x, byte=anded)
        elif cat == 0xD:
            self.cat_0xD(op=op, x=x, y=y)
        elif cat == 0xE:
            self.cat_0xE(op=op, x=x)
        elif cat == 0xF:
            self.cat_0xF(op=op, x=x)

    def cat_0(mut self, op: UInt16):
        if op == 0x00E0:
            self.display.clear()
        elif op == 0x00EE:
            self.register.pc = self.register.stack[self.register.sp]
            self.register.sp -= 1

    def cat_2(mut self, nnn: UInt16):
        self.register.sp += 1
        self.register.stack[self.register.sp] = self.register.pc
        self.register.pc = nnn

    def cat_3(mut self, x: UInt8, kk: UInt8):
        var vx_byte = self.register.read(v=x)
        if vx_byte == kk:
            self.register.pc += 2

    def cat_4(mut self, x: UInt8, kk: UInt8):
        var vx_byte = self.register.read(v=x)
        if vx_byte != kk:
            self.register.pc += 2

    def cat_5(mut self, x: UInt8, y: UInt8):
        var vx_byte = self.register.read(v=x)
        var vy_byte = self.register.read(v=y)
        if vx_byte == vy_byte:
            self.register.pc += 2

    def cat_7(mut self, x: UInt8, kk: UInt8):
        var to_add = self.register.read(v=x)
        self.register.write(v=x, byte=kk + to_add)

    def cat_8(mut self, op: UInt16, x: UInt8, y: UInt8):
        var sub_op = UInt8(op & 0x000F)
        var vx_byte = self.register.read(v=x)
        var vy_byte = self.register.read(v=y)
        if sub_op == 0:
            self.register.write(v=x, byte=vy_byte)
        elif sub_op == 1:
            var byte_or = vx_byte | vy_byte
            self.register.write(v=x, byte=byte_or)
        elif sub_op == 2:
            var byte_and = vx_byte & vy_byte
            self.register.write(v=x, byte=byte_and)
        elif sub_op == 3:
            var byte_xor = vx_byte ^ vy_byte
            self.register.write(v=x, byte=byte_xor)
        elif sub_op == 4:
            var byte_add: UInt16 = UInt16(vx_byte) + UInt16(vy_byte)
            if byte_add > 255:
                self.register.write(v=0xF, byte=1)
            else:
                self.register.write(v=0xF, byte=0)
            self.register.write(v=x, byte=UInt8(byte_add))
        elif sub_op == 5:
            if vx_byte > vy_byte:
                self.register.write(v=0xF, byte=1)
            else:
                self.register.write(v=0xF, byte=0)
            var byte_sub = vx_byte - vy_byte
            self.register.write(v=x, byte=byte_sub)
        elif sub_op == 6:
            var right_most = vx_byte & 1
            if right_most == 1:
                self.register.write(v=0xF, byte=1)
            else:
                self.register.write(v=0xF, byte=0)
            self.register.write(v=x, byte=vx_byte >> 1)
        elif sub_op == 7:
            if vx_byte < vy_byte:
                self.register.write(v=0xF, byte=1)
            else:
                self.register.write(v=0xF, byte=0)
            var byte_sub = vy_byte - vx_byte
            self.register.write(v=x, byte=byte_sub)
        elif sub_op == 0xE:
            var left_most = (vx_byte & 0b1000_0000) >> 7
            if left_most == 1:
                self.register.write(v=0xF, byte=1)
            else:
                self.register.write(v=0xF, byte=0)
            self.register.write(v=x, byte=vx_byte << 1)

    def cat_9(mut self, x: UInt8, y: UInt8):
        var vx_byte = self.register.read(v=x)
        var vy_byte = self.register.read(v=y)
        if vx_byte != vy_byte:
            self.register.pc += 2

    def cat_0xD(mut self, op: UInt16, x: UInt8, y: UInt8):
        var n = op & 0x000F
        var start = self.register.i
        var vx_byte = self.register.read(v=x)
        var vy_byte = self.register.read(v=y)
        var collision: Bool = False

        for row in range(n):
            var address = start + row
            var sprite_byte = self.ram.read(address=address)
            for col in range(8):
                var bit = (sprite_byte >> (7 - UInt8(col))) & 1
                if bit == 1:
                    var px = (vx_byte + UInt8(col)) % 64
                    var py = (vy_byte + UInt8(row)) % 32
                    if self.display.draw(x=px, y=py):
                        collision = True

        if collision:
            self.register.write(v=0xF, byte=1)
        else:
            self.register.write(v=0xF, byte=0)

    def cat_0xE(mut self, op: UInt16, x: UInt8):
        var sub_cat = op & 0x00FF
        var key_index = self.register.read(v=x)
        if sub_cat == 0x9E:
            if self.keyboard.keys[key_index]:
                self.register.pc += 2
        elif sub_cat == 0xA1:
            if not self.keyboard.keys[key_index]:
                self.register.pc += 2

    def cat_0xF(mut self, op: UInt16, x: UInt8):
        var sub_cat = op & 0x00FF
        if sub_cat == 0x07:
            self.register.write(v=x, byte=self.register.dt)
        elif sub_cat == 0x0A:
            var pressed = False
            for i in range(16):
                if self.keyboard.keys[i]:
                    self.register.write(v=x, byte=UInt8(i))
                    pressed = True
                    break
            if not pressed:
                self.register.pc -= 2
        elif sub_cat == 0x15:
            self.register.dt = self.register.read(v=x)
        elif sub_cat == 0x18:
            self.register.st = self.register.read(v=x)
        elif sub_cat == 0x1E:
            self.register.i = self.register.i + UInt16(self.register.read(v=x))
        elif sub_cat == 0x29:
            self.register.i = UInt16(self.register.read(v=x)) * 5
        elif sub_cat == 0x33:
            var vx_dezcimal = Int(self.register.read(v=x))
            var hundrets = vx_dezcimal // 100
            var tens = (vx_dezcimal // 10) % 10
            var ones = vx_dezcimal % 10
            self.ram.write(address=self.register.i, byte=UInt8(hundrets))
            self.ram.write(address=self.register.i + 1, byte=UInt8(tens))
            self.ram.write(address=self.register.i + 2, byte=UInt8(ones))
        elif sub_cat == 0x55:
            for register in range(x + 1):
                var byte = self.register.read(v=register)
                self.ram.write(
                    address=self.register.i + UInt16(register), byte=byte
                )
        elif sub_cat == 0x65:
            for register in range(x + 1):
                var byte = self.ram.read(
                    address=self.register.i + UInt16(register)
                )
                self.register.write(v=register, byte=byte)
