# Journal

The purpose of this journal is to document the planning and progress of the
Breakout project.

## Pre-Journal

### Genesis

This project was conceived in January of 2024, shortly after I had turned in my final project for my Reconfigurable Computing class. I was overall unhappy with
my final product, and consulted with my instructor, Dr. Phillips, about how to
continue to develop my FPGA skills. He recommended revisiting the project at a
later date, with more careful planning and less deadline pressure. I made plans
to do so.

Some time later, in early August of 2025, I decided to finally revisit the
Breakout project. I wanted to do the project primarily for fun, as a hobby, but
I also realized that this project would look good in a portolio when I applied
for an FPGA job someday.

I knew I wanted to do this project "right," that is, to use the most modern and
relevant tooling I could, use good project planning, and practice any other
skills relevant to "real" FPGA programming.

### Installing Linux

I decided that doing this project "right" would mean using a Linux environment. I wanted the chance to learn tools like Vim and Quartus Prime's command line
interface. I had been wanting to start transitioning to Linux anyway,
considering the upcoming end-of-support for Windows 10 and my absolute refusal
to put up with Microsoft's shenanigans. I selected Linux Mint for my new system
because it was frequently recommended as a good Linux distro for beginners. I
successfully installed it onto a new 250-GB partition on my hard drive. Getting
Mint to work with my wifi adapter was a challenge, but eventually I got it
working.

## August 8, 2025

The next step was to create a Github repo for this project and connect it to my new Linux system. It had been some time since I had used git or Github in any
serious capacity, but I followed the instructions and got everything working.

### Requirements

The requirements for the original final project can be found in 
original_requirements.pdf. However, I made a few notable changes to the 
requirements for this project.

- VHDL is not a requirement. I will consider a variety of HDLs for use in this
project.
- The bricks, ball, and paddle will not be simple blocks. Instead, they will
be textured. The ball will also be "round" and have pixel-perfect collision with
the bricks and paddle.
- The on-board accelerometer will be used for moving the paddle.
- The background may have a color other than black, or even a scrolling
background image.
- The number of balls remaining and the player's score shall be represented
on-screen.

These requirements represent a significant increase in difficulty, relative to
the original requirements.

### Target

I own two FPGA development boards:
- A Digilent Basys3, featuring a Xilinx Artix-7 FPGA.
- A Terasic DE10-Lite, featuring an Altera MAX-10 FPGA.

I compared the major specifications of the two FPGAs:
Artix-7 (XC7A35T-1CPG236C)			MAX-10 (10M50DAF484C7G)
33,280 Logic Cells				50,000 Logic Elements
90 DSP Slices					144 18x18 Multipliers
1,800 kb of memory				1,638 kb of memory

Both FPGAs are more than sufficient for this project.

Because either FPGA will suffice, I next compared their development boards.
Only the DE10-Lite includes an accelerometer, which I would like to use to
control the paddle. As a result, this project will target the 10DE-Lite board.
This also means that this project will use Intel's Quartus Prime design
software.

### Tooling

The next step is to get my tooling set up.

Because I am using the DE10-Lite board, I'm locked into using Intel's Quartus
software suite. I downloaded and installed the latest version, which went
surprisingly smoothly.

I want to validate my tooling, to make sure I have everything I need and I know
how to use it. To acheive this, I will do a simple "blinky" project. Everything
for this project will be located in a separate test/blinky branch of the repo.

First, I will create the VHDL code for the blinky project. I will use VHDL
becuase it is the HDL I am most familiar with, and the emphasis of this first
test is not learning a new HDL.

### Blinky

The code is very simple. The design consists of a single file that counts clock
cycles. When the clock reaches a certain value, the LED is turned on. When the
clock reaches another value, the LED is turned off. The values are tuned to
blink the LED at a rate of 500 mHz and a duty cycle of 50% (On for one second,
off for one second).

### Licensing, Questa, and Compilation

After I drafted the code for Blinky, I had to compile it. I am most accustomed
to Modelsim, but it appears that Modelsim has been replaced with Questa.

I downloaded and ran the Quartus Prime 24.1 installed, which also installed
Questa. When I tried running Questa from the command line (via the vsim
executable), it informed me that I would need a license.

After going through the whole rigamarole to get a free Questa license, I
downloaded it, added in to my ENV, and was able to launch Questa in GUI mode.
It looks identical to the Modelsim I remember. I used the GUI to compile my
Blinky code and correct a few syntax errors.

Next, I want to use the command line to compile and simulate my designs, but it
looks like this will have to be a topic for another time.

## August 9, 2025

### Asynchronous Reset with Synchrounous De-Assert

After a bit of time to think, I realized I should update my Blinky code to have
asynchronous reset with synchronous de-assert. I made the appropriate change to
the code. I compiled the code using vcom from the command line and corrected
the syntax errors.

### Self-Checking Testbench for Blinky

Next, I need to write a testbench for my blinky program. Ideally, the testbench
will be completely self-checking, so I can (in the ideal case) test the module
completely from the command line.

The testbench will start by holding the DUT in reset for a certain number of
clock ticks, to make sure everything is correctly initialized. It will then
release the reset and provide the DUT with a clock signal. The testbench will
include the following checks:

- The period of the blinker is 2 seconds, as measured between one rising edge
of the output and the next rising edge of the output.
- The duty cycle of the blinker is 50%, as measured by the output being high
50% of the time and low the other 50%.
- Asserting the reset causes the output to immediately go low. The above tests
are then repeated.

I drew up an outline of the testbench and immediately noticed a problem: The
testbench takes way too long to run. I probably should have predicted this.
The issue is having to simulate all hundred million ticks per period. I'll
have to find a way to reduce the number of ticks that have to be simulated.

The obvious way to do this would be to pass in generics that determine the
period and clock frequency of the blinker. Then, in the testbench, I could pass
in a much shorter blinker period (or lower flock frequency). Then, in the
"real" version, I would either wrap blinky.vhdl in some kind of top-level
module to passin the "real" values, or set the defaults to the real values.

Overall, I like the second approach better.

## August 10, 2025

### Finishing Testbench

I decided that the overall structure of the testbench will be to have a single
process that conducts all the tests. Each test, in addition to any interface
signals it requires, also outputs two signals:

- A "Complete" signal.
- A "Passed" signal.

The "Complete" signal is set to 1 immediately after the test finishes its 
tasks. The "Passed" signal is either set or reset depending on the results of
the test.

Then, a separate process waits until every test is complete, then checks their
passed signals. If all the tests passed, the testbench reports that the design
is OK and finishes. Otherwise, the testbench reports a bad design and finishes.

I hope that this overall testbench structure will allow a variety of well-
organized, flexible testbenches throughout this project.

### Makefile

After finishing up the testbench and verifying it works in the Questa GUI,
I create a Makefile to automate the compilation and simulation of my design.
It is extremely basic, but still helps. I expect that my Makefiles will become
more sophisticated as the project grows.

## August 12, 2025

### Project Setup

The next step is to set up a Quartus project, will all the associated settings
and whatnot. Ideally, I'd like to keep my usage of the Quartus GUI to a
minimum and create the files manually, then run the flow steps from the command
line or a Makefile. I know this isn't super practical, but I want to understand
Quartus, rather than just memorizing the magic combination of button presses,
and going command-line-only seems like a good way to do that.

I couldn't find very good documentation on the setup of the QSF file and other
topics, so I will heavily reference a "test project" I made.

First comes the .qsf, which contains (most of?) the project settings.

Next is the .sdc, which contains the timing constraints. Both the button input
and output LED are unconstrained, so the only thing that needs to go in the
.sdc is the clock.

The next step was to make sure I could fully synthesize, place and route, and
assemble the design using the command line. I referenced the "Flow Log" of a
test project and added them to the Makefile.

### Programming the Device

The final step was to program my DE10-Lite. This was a massive headache.

When I plugged in my FPGA, it showed up in the programming menu as a USB
Blaster, just as it was supposed to. But I couldn't do anything with it. After
reading some sketchy-ass forums online, I determined that my problem was that
the JTAG programmer daemon needed root access, which I needed to add via a udev
rule. I'm sure I'll learn someday what a udev rule is, but in this case I had
no idea. But I copied and pasted a file from the Internet that seemed to work
fine.


`SUBSYSTEM=="usb", 

ENV{DEVTYPE}=="usb_device", 

ATTR{idVendor}=="09fb", 

ATTR{idProduct}=="6001", 

MODE="0666", 

NAME="bus/usb/$env{BUSNUM}/$env{DEVNUM}", 

RUN+="/bin/chmod 0666 %c" `

Finally, I studied the options for the quartus_pgm command and added two
versions to the Makefile: One for programming just the FPGA using a .sof, and
one for programming the configuration EEPROM using a .pof.

### Final Blinky project

After programming the FPGA, everything worked correctly, except that the logic
sense of the reset button was inverted. After fixing this in the code,
Blinky was complete, and my toolchain was validated and ready to begin the
actual project!

## August 30, 2025

### More Linux Troubles

My project stalled out since I started having trouble with my Linux install.
For some reason, it looks like the udev rule for the USB blaster was
iterfering with Cinnamon, and whenever I started my computer, after logging
in I only got a black screen and a cursor. Trying to diagnose the problem by
looking through journalctl and whatnot yielded no leads. Eventually, I decided
to just bite the bullet and reinstall Cinnamon.

After reinstalling, everything seems to be working correctly. Here's hoping
that it will be clear sailing from here.

