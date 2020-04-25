# Pic16F15376 LCD 16X2
Code to control and send data to an 16x2 LCD

## Prerequisites
To compile this code is only necessary to have gputils installed on machine.

## Hardware connections
Below is shown the connections between LCD and PIC

| PIN | Function | PIC PORT |
| --- | -------- | -------- |
| 1 | GND | |
| 2 | +5 V | |
| 3 | This pin is connected to a trimpot to adjust the display contrast |
| 4 | RS | RC0 |
| 5 | RW | RC1 |
| 6 | Enable | RC2 |
| 7 | NC | |
| 8 | NC | |
| 9 | NC | |
| 10 | NC | |
| 11 | Bit 4 | RA0 |
| 12 | Bit 5 | RA1 |
| 13 | Bit 6 | RA2 |
| 14 | Bit 7 | RA3 |
| 15 | Backlight LED | |
| 16 | GND |  |

## Compilation
To compile code only is needed run `make` command.