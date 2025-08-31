# Documentation

The purpose of this file is to document the overall and detailed design of the
Breakout project. This is a living document, and will be updated as the design
progresses.

## Overall

The following paragraphs describe the Breakout project considered as a whole.

### Requirements

The requirements for the Breakout project are originally sourced from Dr.
Phillips's requirements for the final project of his Reconfigurable Computing
course at Utah State University, with notable additions and changes. Dr.
Phillips's original requirements can be found in original_requirements.pdf.

#### Target

- 1.1 The design shall target the DE10-Lite FPGA board.
- 1.1.1 The design code shall be synthesizeable for the 10M50DAF484C7G FPGA.
- 1.1.2 The design shall make use only of interfaces and peripherals available
on the DE10-Lite FPGA board.

Requirement 1.1.1 is verified by successfully synthesizing and programming the
design onto a DE10-Lite board.

Requirement 1.1.2 is verified by inspection of the VHDL code.

Requirement 1.1 is verified when both requirements of 1.1.1 and 1.1.2 are both
successfully verified.

#### Interface

- 2.1 The VHDL design shall present the following interfaces to on-board
devices.
    - A a digital color signal, consisting of 3 channels, each 4 bits wide, to
    the onboard VGA DAC.
    - VSYNC and HSYNC signals, each one bit wide, to the VGA connector.
    - A SOUND signal, one bit wide, to a general-use I/O pin.
    - A DROPBALL signal, one bit wide, to an onboard user button.
    - A RESET signal, one bit wide, to an onboard user button.
    - An interface to the onboard ADXL345 accelerometer, consisting of the
following signals:
        - SCLK, SPI clock (FPGA out, ADXL in)
        - SDI, input SPI data to the ADXL (FPGA out, ADXL in)
        - SDO, output SPI data from the ADXL (FPGA in, ADXL out)
        - CSn, active-low SPI slave select (FPGA out, ADXL in)
        - INT1 and INT2, interrupt flag pins whose behavior is configured by
the ADXL control registers (FPGA in, ADXL out)

#### Functional

- 3.1 The design shall produce a VGA video signal on its VGA connector with the
following timing characteristics.
    - Vertical timing
        - VSYNC: 2 lines
        - Back porch: 33 lines
        - Visible area: 480 lines
        - Front porch: 10 lines
    - Horizontal timing
        - VSYNC: 96 pixels
        - Back porch: 48 pixels
        - Visible area: 640 pixels
        - Front porch: 16 pixels
    - Framerate: about 60 Hz

- 3.2 The image displayed by the VGA video signal shall consist of the
elements.
    - The entire upper half of the screen shall be divided into cells 16 pixels
wide and 8 pixels high. Every other row shall be aligned to the left side of
screen, while each other row shall be offset by half a cell-width, so the first
and last cells in such a row are "cut off" to only eight pixels wide. In each
cell shall be drawn either a brick or a blank space, depending on the game
state.
    - Zero or one balls, each ten pixels tall and ten pixels high, shall appear
on the screen at a location depending on the game state. The ball shall be
capable of appearing at any wholly on-screen location. The ball may be either
a solid block or other shape, as long as the shape is wholly within the ten-by-
ten bounding box. The quantity of balls appearing shall depend on the game
state.
    - One paddle, 40 pixels wide and ten pixels high, shall appear at the
bottom of the screen at a horizontal position depending on the game state. The
paddle shall be capable of appearing at any wholly on-screen horizontal
location.
    - Any areas of the screen on which no brick, ball, or paddle appears shall
be uniformly filled with a color contrasting the bricks, ball, and paddle.

- 3.3 The game state shall evolve over time according to the following
rules.
    - When the design is reset (either from startup or the RESET button being
pressed), all bricks shall appear, and no ball shall appear.
    - The position of the paddle shall be determined by the roll angle of the
DE10-LITE board, as measured by the onboard accelerometer.
    - When the DROPBALL button is pressed and no ball appears on the screen, 
a ball shall appear on the screen at an unpredictable position and move
directly down at a fixed speed.
    - When the DROPBALL button is pressed and a ball is already present on the
screen, there shall be no effect.
    - When a ball contacts the bottom edge of the screen, the ball shall
disappear. Once three balls have contacted the bottom of the screen since the
system has been reset, the DROPBALL button shall cease to have any effect until
the device is reset.
    - Whenever the ball contacts the left or right edges of the screen, the
ball's horizontal velocity shall invert. The ball's horizontal speed shall
remain the same. The ball's vertical velocity shall also remain the same.
    - Whenever the ball contacts the top edge of the screen, the ball's
vertical velocity shall invert. The ball's vertical speed shal remain the
same. The ball's horizontal velocity shall also remain the same.
    - Whenever the ball contacts upper surface of the paddle, the ball's
vertical velocity shall reverse. The ball's vertical speed shall remain the
same. The ball's horizontal velocity shall change depending on where on the
paddle the ball contacted. If the ball contacted the paddle closer to paddle's
edge, the ball's horizontal velocity shall be greater in that direction.
    - Whenever the ball contacts any surface of a brick, that brick shall
disappear. The ball's vertical and horizontal velocity shall change is such a
manner as to model the ball "bouncing" off the brick.

- 3.3 The device shall produce sounds whenever any of the following events
occur.
    - The ball contacts the left, right, or upper edge of the screen.
    - The ball contacts the upper surface of the paddle.
    - The ball contacts the lower edge of the screen.
    - The ball contacts a brick.
    - A new ball appears on the screen.
Each sound shall consist of a series of one or more square-wave notes at
different, arbitrary frequencies. No two sounds shall be played simultaneously.
Each sound shall be recongizeable and distinct.
 
### Implementation

The design consists of the following four primary sections.

- The "VGA Controller" is responsible for producing the VGA signal output to an
attached (off-board) VGA display. The VGA controller produces the VGA signal to
reflect the game state, as provided by the Game Controller. The VGA Controller
also is responsible for detecting pixel-perfect collisions between the ball and
the walls, bricks, and paddle. Collisions are detected during the VGA raster
scan and relayed to the Game Controller.

- The "Game Controller" is responsible for calculating and updating the game
state. The Game Controller considers input recieved from the user buttons and
ADXL Controller when updating the game state. The Game Controller provides game
state information to the VGA controller. The Game Controller also issues
commands to the Sound Controller when certain events occur.

- The "ADXL Controller" is responsible for interfacing with the onboard ADXL345
accelerometer. The ADXL Controller configures the control registers of the ADXL
and regularly queries the output data. The ADXL Controller then performs any
necessary processing and presents the final angle data to the Game Controller.

- The "Sound Controller" is responsible for producing sound waveforms, which
are then played back via a piezo-electric speaker. The Sound Controller is
issued commands by the Game Controller.

The four primary sections communicate via the following interfaces.

#### Game - VGA

The Game Controller presents the VGA Controller with the game state via the
following signals.

- ball_active: A true/false signal representing whether a ball should appear on
the screen.

- ball_position: A set of coordinates representing the on-screen position of
the ball.

- paddle_position: The on-screen horizontal position of the paddle (The
vertical position of the paddle is fixed).

Because the VGA controller and Game Controller run at different clock speeds,
these signals cannot simply be passed between the two clock domains. The
signals are accompanied by a "game_state_ready" signal, which goes high to
signal that the Game Controller has finished its calculations. All
these signals are synchronized through a two-deep synchronizer chain. Once the
VGA Controller finishes drawing the current frame, it raises the
"game_state_ack" signal, causing the Game Controller to lower the
"game_state_ready" signal and begin its next round of calculations.

Because there are so many bricks on the screen, the states of the bricks are
not represented by individual signals. Instead, the states of the bricks are
stored in a dual-port memory. The Game Controller writes to the memory to 
add (on startup and reset) or remove (on collisions) bricks. The VGA Controller
reads the memory as necessary to draw bricks on the screen. The
game_state_ready signal is only raised if the Game Controller has made all
necessary writes to the memory.

Engineer's note: The way the valid and ack signals consider the memory is not
ideal. It could significantly slow the interfacing between the two halves.
We'll see how it goes.

The VGA Controller presents information about any collisions that occur between
the ball and the screen walls, bricks, or paddle. This information is presented
via a FIFO. Each element in the FIFO represents a single collision that was
detected while the frame was being rendered. Each element consists of several
fields.

- The collision type. This indicates what object the ball collided with.
Possible values include a wall, a brick, or each section of the paddle.

- The collision direction. This indicates whether the object was above, below,
to the right, or to the north of the ball when the collision was detected.

- The coordinate of the colliding pixel, that is, the pixel that the ball
collided with, NOT the pixel OF the ball.

The front element of the FIFO is always presented. If the FIFO is empty, a
collision_empty signal is high, and the collision fields are don't-care. To
request the next collision in the FIFO, the Game Controller raises the
collision_next signal. After a delay, the VGA Controller raises the
collision_ready signal, whereupon the Game Controller shifts in the collision
data and lowers the collision_next signal. The VGA controller then lowers the
collision_ready signal, at which point another collision may be read. All
signals crossing the clock domain pass through synchronizer chains.

## VGA Controller

### Requirements

### Implementation

## Game Controller

### Requirements

### Implementation

## Sound Controller

### Requirements

### Implementation

## Accelerometer Controller

### Requirements

### Implementation
