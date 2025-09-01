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

The VGA Controller only raises the game_state_ack signal once it has placed all
collisions into the FIFO. The Game Controller only raises the game_state_ready
signal once it has considered (and therefore read) all collisions from the
FIFO.

#### Game - Sound

The Game Controller issues commands to the Sound Controller when certain events
occur. The Sound Controller then produces square waveforms which drive a piezo-
electric speaker to produce gameplay sounds.

The interface between the Game Controller and the Sound Controller consists of
a series of one-bit signals. Each signal corresponds to one sound that the
Sound Controller can play. Additionall, a "sound_ready" signal indicates that
the sounds are ready to be played. Because the Sound Controller and Game
Controller are in the same clock domain, there is no need for synchronizer
chains. Additionally, the Sound Controller is required to respond immediately
to a high level on the sound_ready signal, so there is no need for an
acknowledge signal.

When the sound_ready signal goes high, the Sound Controller determines the
highest-priority sound from among the sounds whose signals are high. The Sound
Controller then cancels any already-playing sounds and begins playing that
sound. If no sound signals are high, the currently-playing sound, if any, 
continues playing.

#### Game - Accelerometer

The interface between the Game Controller and ADXL Controller consists solely
of the numeric readout of the accelerometer. The ADXL constantly samples the
accelerometer reading and outputs the value on its output signal. The Game
Controller shifts in the reading as necessary. There is no handshaking between
the ADXL Controller and Game Controller.

## VGA Controller

### Requirements

The following requirements apply to the VGA Controller.

- The VGA image shall include the following features

    - Bricks

        - The upper half of the screen shall be capable of displaying bricks.

        - The odd-numbered rows (Starting from zero, counting down from the
top) of bricks shall be aligned to the edges of the screen. Each brick shall
be 16 pixels wide and eight pixels high.

        - The even-numbered rows shall be offset by eight pixels horizontally.
Each brick shall be 16 pixels wide and eight pixels high, except for the right-
most and left-most pixels in the row, which shall be 8 pixels wide and eight
pixels high.

        - The image of each brick shall allow easy visual identification of
each individual brick.

        - Each brick shall correspond to exactly one entry in the brick memory
block. Each brick shall appear and disapper according to the binary value
stored at the appropriate location in the brick memory block.

    - Ball

        - If the game state field ball_active is high, a ball shall appear in
the image at the location specified by ball_position.

        - The ball shall fit within a bounding box ten pixels wide and ten
pixels high.

        - The image of the ball shall fit entirely within the bounding box.

        - If the game state field ball_active is low, no ball shall appear in
the image.

    - Paddle

        - A paddle shall appear at the bottom of the screen at the horizontal
location specified by paddle_position.

        - The paddle shall be forty pixels wide and ten pixels high.

    - Background

        - Pixels not occupied by bricks, the paddle, or the ball shall be a
uniform color.

- The VGA Controller shall detect pixel-perfect collisions between the ball
and the walls, the paddle, or any bricks.

    - A collision shall be considered to occur between the ball and a brick
when any pixel occupied by a (non-destroyed) brick is in the neighborhood
(eight orthogonally or diagonally adjacent cells) of any pixel occupied by
the ball.

Engineer's note: The requirement requires that a collision is detected anytime
the ball "touches" a brick. A much simpler approach would be to detect a
collision whenever the ball "overlaps" a brick. However, I favor this approach
because of its greater challenge and "technical accuracy."

    - A collision shall be considered to occur between the ball and the paddle
whenever any pixel occupied by the top surface of the paddle is directly below
any pixel occupied by the ball.

Engineer's note: The requirement means that the ball collides only with the top
surface of the paddle; the ball does not collide with the sides or any other
pixel of the paddle.

    - A collision shall be considered to occur between the ball and each wall
whenever a pixel on the extreme left, right, top, or bottom of the screen is
occupied by the ball.

    - Whenever a collision is detected, an element containing the following
fields shall be added to a FIFO.

        - The type of object the ball collided with.

        - The "direction" of the collision, i.e, which of the eight pixels
adjecent to the ball pixel was occupied by the colliding object.

        - The position of the colliding pixel on the screen.

    - The front element of the collision FIFO shall be presented.

    - Whenever the "collision_next" input signal goes high, the FIFO shall be
advanced. Once the new element is on the output wires, a "collision_ready"
signal shall go high. If there are no more elements in the FIFO, a
"collision_empty" signal shall go high and the collision data signals shall be
don't-care.

    - Whenever the "collision_next" signal goes low, the "collision_ready"
signal shall also go low.

    - Once the VGA Controller finishes rasterizing a frame, it shall raise the
"game_state_ack" signal and keep it raised until the "game_state_ready" input
signal goes low.

    - The video signal shall conform to the following VGA timing
specifications.

        - VSYNC: 2 lines

        - HSYNC: 96 pixels

        - Vertical back porch: 33 lines

        - Vertical visible area: 480 lines

        - Vertical front porch: 10 lines

        - Horizontal back porch: 48 pixels

        - Horizontal visible area: 640 pixels

        - Horizontal front porch: 16 pixels

        - Framerate: About 60 Hz

    - During the VSYNC period, the VSYNC output signal shall be low. At all
other times, the VSYNC output signal shall be high.

    - During the HSYNC period, the HSYNC otuput signal shall be low. At all
other times, the HSYNC output signal shall be high.

    - During the horizontal and vertical visible area, the VGA Controller shall
output the color of the current pixel on the three four-bit color outputs. At
all other times, all three color outputs shall be black (all low).

### Testing

The requirements levied on the VGA Controller are tested by a self-checking
testbench. All requirements are positively tested. Because the VGA raster
contains nearly half a million pixels, testing at full scale is impractical.
Instead, the VGA Controller is tested using a smaller, yet representative
image.

The following paragraphs describe the tests the self-checking testbench 
performs.

#### Brick Drawing

The brick-drawing test consists of enabling each brick, one at a time, and
analyzing the video signal to determine the size and position of the drawn
brick.

The following flow is performed for each brick:

1. Enable the brick.

2. Analyze the video signal to ensure brick pixels appear only where expected.

3. Disable the brick.

4. Analyze the video signal to ensure no brick pixels appear.

#### Ball Drawing

Overall, the ball-drawing test involves incrementally changing the position of
the ball and measuring the effect on the timing of the ball-colored pixels in
the video signal.

The ball coordinates are required to have the following properties:

- A vertical coordinate of zero corresponds to the ball in its extreme upward
position (touching the top of the screen).

- A vertical coordinate of a extreme positive value (470) corresponds to the
ball in its extreme downward position (touching the bottom of the screen).

- A change of positive one in the vertical coordinate corresponds to the ball
moving a single pixel downwards.

- A change of negative one in the vertical coordinate corresponds to the ball
moving a single pixel upwards.

- A horizontal coordinate of zero corresponds to the ball in its extreme
leftward position (touching the left side of the screen).

- A horizontal coordinate of an extreme positive value (630) corresponds to the
ball in its extreme rightward position (touching the right side of the screen).

- A change of positive one in the horizontal coordinate corresponds to the ball
moving a single pixel rightward.

- A change of negative one in the horizontal coordinate corresponds to the ball
moving a single pixel leftward.

The test consists of a vertical portion and a horizontal portion. In each
portion, the appropriate coordinate begins at zero, then is incremented until
it reaches its maximum value. The video signal is analyzed to determine whether
the ball moves appropriately. Then, the coordinate is incremented until it
returns to zero. Again, the video signal is analyzed.

The testbench uses the uppermost or leftmost pixel, as appropriate,
to measure the position of the ball. The
vertical position is measured by counting the number of hsync pulses since the
last vsync pulse. The horizontal positoin is measured by counting the number of
clock cycles since the last hsync pulse. The testbench accounts for the back
porch when calculating the position of the ball.

Also, the testbench measures that no pixel of the ball exceeds the ten-by-ten
bounding box.

#### Paddle Drawing

The paddle-drawing test follows the same overall flow as the ball drawing
tests, except that motion in one dimension only is required. The vertical
position of the paddle is measured and required to stay constant.

#### Collision Detection

Collision with the walls can be detected during the ball drawing tests. After
the frame where the ball is expected to be in the extreme positions, the
collision FIFO will be read and analyzed to ensure there is at least one
detected collision with a wall in the appropriate direction, and that there
are no other collisions.

To detect collisions with the paddle, the ball is placed at the appropriate
vertical position and wiped horizontally across the screen. The paddle is also
placed at a certain position. The FIFO is read after every frame. Each pixel is
required to be "collided with" at least once. Also, for every frame during
which there is at least one collision, the ball and paddle's positions are
compared to check whether a collision is feasible.

Engineer's note: Would it be better to do an AABB-collision type check instead?

#### Brick Collision

Collision with the bricks is checked during the brick-drawing tests. While each
brick is active, the ball is "wiped" along all four edges of the brick. The
detected collisions are analyzed to check whether all the pixels on each of the
brick's edges are respresented.

The fact that this has to be repeated for each brick has the potential to make
the testbench extremely time-consuming.

#### Number of Frame Required

If the testbench is run with a screen one tenth as high and wide as the actual
screen (64 by 48 pixels), only about 3000 pixels are required to be drawn per
frame, not counting "off-screen" pixels. The ball has a "rattle room" of 54
pixels horizontally and 38 pixels vertically. The paddle has a "rattle room"
of 8 pixels horizontally. There are three rows of bricks. The first and third
have 4 bricks and the second has 5, for a total of 13 bricks.

At the beginning of the testbench, the ball must be wiped up and down along
each dimension, requiring 2*54 + 2*38 = 184 frames. Additionally, each of the
thirteen bricks requires one frame to check for "blankness", one frame to
measure the brick position and size, and 184 frames to check for collisions.
Finally, the paddle requires 16 frames to check for motion and 38 frames to
checks for collisions, for a total of about 2,700 frames. If each frame is
about 3,000 pixels, this is a total of about 10,000,000 pixels, once off-frame
pixels and miscellaneous test are accounted for. This is at the upper limit
of what I would be comfortable testing. If it becomes necessary, the following
simplifications could be made to reduce the number of required tests:

- Only test collision with one brick, and take the results and representative.
- Instead of wiping the ball across all four edges of the brick, only test
three frames per edge: One with the brick's position less that the bricks and
not colliding, one colliding, and one with the brick's position greater than
the brick's and not colliding.
- Test the ball's motion by moving it only one pixel in each direction, rather
than wiping it across the whole screen.

### Implementation

The VGA controller starts with two counters. The first, the horizontal counter,
counts with each clock cycle. The second, the vertical counter, counts when the
vertical counter rolls over.

The next stage analyzes the counters to determine the current phase of the VGA
raster scan. If the raster scan is in the "visible area" phase, the two counts
become the coordinates of the current pixel.

Note that the above means that the raster scan starts with the visible area
phase, not the sync phases. This is acceptable; only the relative sequence of
the phases is important. Which phase is the first to appear on reset in not
important.

The different objects that can appear onscreen are represented by "masks." Each
mask is a 2d-array of binary values that "appear" in a certain area of the
visible image. There are two types of masks: Ones used to draw objects on the
screen and ones used to detect collisions. Some masks serve both functions.

The masks are:

- All appearing bricks are represented by a single mask that serves both
functions.

- The ball's image is represented by a drawing mask.

- The paddle's image is represented by a drawing mask.

- The ball's collision behavior is represented by eight separate collision
masks, each one offset by one pixel in a different (orthogonal or diagonal)
direction.

- The paddle's collision behavior is represented by a collision mask.

- Each wall has a collision mask, but these masks collide with the ball's image
mask, not its collision masks.

In the third stage, logic determines which masks are active for the current
pixel. In parallel, the color of the pixel corresponding to each image layer
is determined. Note that, at this point, it is not known which, if any, image
will be drawn.

In the fourth stage, the collision masks are compared to detect collisions,
and collision date is placed into the FIFO. In parallel, the final color of the
final pixel is calculated. The color is placed on the VGA output pins.

## Game Controller

### Requirements

### Implementation

## Sound Controller

### Requirements

### Implementation

## Accelerometer Controller

### Requirements

#mentation
