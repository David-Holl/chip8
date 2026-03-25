# Chip-8 Interpreter

A Chip-8 interpreter written in [Mojo](https://www.modular.com/mojo), using SDL2 for graphical output.

Chip-8 is a virtual machine from the late 1970s, originally designed to make game development easier on early home computers. It features 4KB RAM, 16 general-purpose 8-bit registers, a 64x32 monochrome display and a 16-key hexadecimal keypad.

- Specifications: <http://devernay.free.fr/hacks/chip8/C8TECH10.HTML>

## Implementation

| Module          | Description                                                                                          |
| --------------- | ---------------------------------------------------------------------------------------------------- |
| `main.mojo`     | Entry point. ROM loading, main loop, SDL + Chip8 orchestration                                       |
| `chip8.mojo`    | Main emulator struct. Fetch-Decode-Execute cycle, all 35 opcodes, font loading                       |
| `ram.mojo`      | 4KB RAM with read/write access and address validation                                                |
| `register.mojo` | 16 general-purpose registers (V0-VF), index register (I), program counter, stack, delay/sound timers |
| `display.mojo`  | 64x32 monochrome display with XOR drawing and collision detection                                    |
| `keyboard.mojo` | 16-key input with key_down/key_up                                                                    |
| `sdl.mojo`      | SDL2 bindings via C-FFI (OwnedDLHandle), window management, rendering, input polling                 |

Sound is not implemented yet.

## Requirements

- Linux x86_64
- Mojo `>=0.26.3, <0.27` (nightly)
- SDL2 (`sdl2` or `sdl2-compat`)
- [pixi](https://pixi.sh) package manager

## Usage

```sh
pixi shell
mojo build main.mojo
pixi run ./main "/path/to/game.ch8"
```

## Key Mapping

```
Chip-8         Keyboard
+-+-+-+-+      +-+-+-+-+
|1|2|3|C|      |1|2|3|4|
+-+-+-+-+      +-+-+-+-+
|4|5|6|D|      |Q|W|E|R|
+-+-+-+-+      +-+-+-+-+
|7|8|9|E|      |A|S|D|F|
+-+-+-+-+      +-+-+-+-+
|A|0|B|F|      |Z|X|C|V|
+-+-+-+-+      +-+-+-+-+
```

## Disclaimer

`sdl.mojo` is the only file created and modified with AI assistance. All other code was written by hand as a learning project.
