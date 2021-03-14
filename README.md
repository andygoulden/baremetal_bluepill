# Absolute minimum bare metal STM32F103C6 project

This project aims to be the absolute bare minimum of files required to get something to run on an STM32F103C6 board, known as the 'Blue Pill'. The 'bare metal' in the project name refers to the fact that there is no operating system being used, the binary is being run directly when the board boots up.

The reason I created this repository is that a lot of guides on getting started with STM32 boards recommend installing multiple applications, and have a large number of steps to follow before you have a binary which can be flashed onto a board. And then, you end up with a very complex and hard-to-follow directory full of libraries and drivers that a beginner couldn't hope to understand.

This project is aimed at people who are familiar with coding in general, but haven't worked with an STM32 before, and want to be able to fully understand (or at least read) all of the code they need to get started with an STM32. See the table under 'Files' below for a description of the files in this project.

This project does not include any facility to flash the project onto a board, though some instructions can be found below in this readme. It also only supports the unofficial 'Blue Pill' board. If you have a genuine STM32 board from ST, such as a Nucleo or Discovery, you may have a better experience by following other tutorials which make use of tools from ST such as the STM32CubeIDE. Otherwise, if you just replace any file here which refers to a chip or chip series with the equivalent for your chip, it may still work, though I won't be able to help you if it doesn't.

## Requirements

This project requires GNU Make, which is included in most Linux distributions. On Windows, you'll need something like Cygwin.

Other than that, the only thing you need is the GNU Arm Embedded Toolchain, which is available from here:

https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads

## Building

To build, you just need to set the `TOOLSPATH` variable in the Makefile to the location of the GNU Arm Embedded Toolchain on your machine.

Then, build by running `make` in this directory.

This runs the default goal, which is `app`. This builds the main executables, which are put in `build/`.

There is also a rule, `clean`, which deletes all build artefacts.

## Files

Here is a brief description of the files here.

Directory | Filename | Description
:-------- | :------- | :----------
.         | Makefile | The Makefile, which compiles the code and also flashes the unit. The goals are 'app' (the default), which compiles the application, and 'clean', which deletes the build artefacts.
cmsis     | *many*   | CMSIS files; Interface files for the Cortex-M3 ARM CPU core.
inc       | stm32f1xx.h | A header for all STM32F1xx series chips. It doesn't do much, apart from include the more specific header file (e.g. stm32f103x6.h).
inc       | stm32f103x6.h | A header for STM32F103x6 chips, such as the STM32F103C6. This provides a lot of interface details for user scripts, like registers and interrupts.
inc       | system_stm32f1xx.h | The header for the system file, system_stm32f1xx.c.
scripts   | STM32F103X6_FLASH.ld | The linkerscript, which describes the memory layout of the chip, and defines the entrypoint of the program.
src       | main.c | The user-created app. In this case, all it does is set up GPIO peripheral C, and enable/disable pin PC13 in a loop. Since the STM32F103C6 Blue Pill has a built-in LED on this pin, this causes the LED to blink.
src       | system_stm32f1xx.c | Provides system definitions and functions, such as setting up the clock.
startup   | startup_stm32f103x6.s | Startup code, such as initialising the data sections for a C program, and defining the interrupts.

## What happens in the Makefile?

The Makefile for this project is very straightforward.

First, it compiles each assembly and C source file into an object file (un-linked machine instructions, extension `.o`), using `arm-none-eabi-gcc` for the C files and `arm-none-eabi-as` for the assembly files.

Second, it uses `arm-none-eabi-gcc` to link the objects into an ELF executable file (`.elf`). (After doing this, it uses `objdump` and `size` to print out information about the executable. These lines can be removed if there's too much output for your liking.)

Third, it makes a raw binary (`.bin`) and an Intel hex (`.hex`) file from the linked executable. These are used by different programmers (for example, ST-LINK uses the raw binary, and J-Link uses the Intel hex), though some programmers or debuggers use the ELF file.

All of these build objects are put in the `build/` directory.

This all happens at the bottom of the Makefile. Everything else is just setting up paths and compiler/linker flags.

## What next?

### Programming the board

Once you've built the code here, you'll need to get it onto the chip. Since the Blue Pill doesn't have a built-in programmer (as some ST development boards do), you'll need a hardware programmer.

The least expensive hardware programmers are ST-Link clones (usually sold online with a name like 'ST-Link v2'), which are often available from the same places that sell Blue Pill boards. Software drivers for these ST-Link clones can be found here:

https://github.com/stlink-org/stlink

If using these drivers, the `st-flash` utility can be used to flash the built binary onto the board as follows:

```
st-flash write build/blinky.bin 0x8000000
```

Other programmers include ST-LINK V2 programmers from ST (the makers of the STM32F103C6 chip), and J-Link programmers from SEGGER, which can use the SWD interface (pins SWDIO and SWDCLK on the board).

### Starting your project

Technically, everything you need is in the reference manual, `RM0008 Reference manual STM32F101xx, STM32F102xx, STM32F103xx, STM32F105xx andSTM32F107xx advanced Arm®-based 32-bit MCUs`, which can be downloaded from the documentation section on the product page for the STM32F103C6:

https://www.st.com/en/microcontrollers-microprocessors/stm32f103c6.html#documentation

However, that document is over 1,000 pages long, and is very dense, especially for beginners. To make this (a little) easier, ST provide two good resources: the Cube, and the HAL.

#### The Cube

STM32CubeMX is a code generator with an easy-to-use graphical interface. It is available from ST here:

https://www.st.com/en/development-tools/stm32cubemx.html

It allows you to describe which pins you wish to use, and the mode you wish to use them in, and then generates an application which you can use as the basis of an application.

It's worth noting that ST have recently released an IDE, STM32CubeIDE, which is an Eclipse-based IDE which has the Cube built into it. However, I find it quite buggy and hard-to-use currently. Plus, I don't like Eclipse.

#### The HAL

The second resource provided by ST is the STM32 HAL (hardware abstraction layer). This is included in the code generated by the Cube.

It is a collection of functions and macros which are useful for STM32 devices. The functions are very bulky and convoluted, but are very functional.

If you require high performance or a small codebase, you may wish to use the HAL functions only as a reference, rather than adding the HAL as a full dependency for your project.

## Disclaimer

This project doesn't make any claims of functionality, so if you're unable to get it working for your set-up, I'm almost certainly not going to be able to help. As the 'Blue Pill' isn't an official ST product, ST probably can't help you either. If you're struggling to program a 'Blue Pill' board, my recommendation is to buy an official ST product, such as a Nucleo (the lower-end of which are very reasonably-priced). They have features like an on-board hardware programmer, and have some guarantee of quality, rather than 'Blue Pills' which have no official manufacturer, and occasionally have quality issues such as 'fake' chips (which identify themselves incorrectly to programmers).
