<img src="https://git.pupes.org/repo-avatars/e4ede9d30f070c9e191eace5a88dcaa40434b9cadf60204122fab5a83aec9a9f" alt="logo of ParaDocs" width="196"></img>
[![build test](https://git.pupes.org/PoliEcho/asm-game-of-life/actions/workflows/build_test.yaml/badge.svg)](https://git.pupes.org/PoliEcho/asm-game-of-life/actions?workflow=build_test.yaml)
# AMD64 Assembly Game of life


## Dependencies  
> AMD64 Linux Kernel  
### Build only  
> nasm  
> ld  
> make  

## Download
[releases](https://git.pupes.org/PoliEcho/asm-game-of-life/releases)

## Build  
```shell
make
```

## Controls
| key    | action                  |
|--------|-------------------------|
| arrows | move cursor             |
| ENTER  | invert cell             |
| j/k    | change simulation speed |
| p      | start/stop simulation   |
| q      | quit                    |


## Warning  
delays in TTY may be diferent depending on cpu clockspeed use j/k to adjust

## Notes  
if screen does not clear properly after loading just move the cursor around a bit