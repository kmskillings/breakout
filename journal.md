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
