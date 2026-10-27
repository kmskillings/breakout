# VGA Controller

This file documents the requirements for the VGA controller.

## Interface

The VGA controller shall present the following interface.

### Inputs

#### Clock

The VGA controller shall accept a single-ended clock input.

The VGA controller shall behave as specified where the clock meets the
following requirements:

##### Frequency

The clock shall have a period of 39.6 to 39.9 ns.

##### Duty Cycle

The clock shall have a duty cycle of 45% to 55%.

#### Reset

The VGA controller shall accept a single-ended, active-low,
asynchronous-assert, synchronous-deassert reset signal.

The VGA controller shall behave as specified where the reset signal meets
the following requirements:

##### Minimum Assertion Time

The reset signal shall have a minimum assertion time equal to one full cycle
of the clock.

##### Synchronous Deassert

The reset signal shall be de-asserted synchronously with the rising edge of the
clock.

### Outputs

#### Vertical Sync

The VGA controller shall expose a single-ended vertical sync output. The vertical sync output shall be registered on the rising edge of the clock.

#### Horizontal Sync

The VGA controller shall expose a single-ended horizontal sync output. THe horizontal sync output shall be registered on the rising edge of the clock.

#### Color

The VGA controller shall expose an array of twelve single-ended color outputs,
organized into three sets of four:
- Red Intensity
- Green Intensity
- Blue Intensity
All color outputs shall be registered on the rising edge of the clock.

#### Output States

Each individual output signal shall have a state of either '0' or '1' at all times after the first delta cycle of the simulation.

> The outputs are not required to have a '0' or '1' value during the first delta cycle. They are allowed one delta cycle to settle from 'U' (or similar) to either '0' or '1'.

#### Output Registration

Each transition of an individual output signal shall occur either:
- Exactly one delta cycle after a rising edge of the clock input.
- Exactly one delta cycle after a falling edge of the reset input.
This requirement shall not apply during the first two delta cycles of the simulation.

> This requirement captures the concept that the outputs are registered on the rising edge of the clock. If the outputs change on the same delta cycle as the rising edge of the clock, it means the DUT somehow guessed when the clock would go high, rather than reacting to it. More than one delta cycle is not acceptable because this would indicate a cascade of combinational logic between the register and the output. The exception for the first two cycles of the simulation is to prevent false failures from resulting when the outputs change from their undefined value to their reset-state value.

## Performance

### Reset Behavior

#### Reset State

All outputs of the VGA controller shall go low exactly one delta cycle following each falling edge of the reset input. All outputs shall remain low for as long as the reset input is held low. All outputs shall also remain low for no fewer than one delta cycles following the subsequent rising ege of the reset input.

> The exactly-one-delta-cycle aspect of this requirement captures the idea that the outputs react "immediately" to the reset signal. If the outputs go low on the same delta cycle that the reset does, it means the DUT somehow guessed when the reset signal would go low, rather than reacting to it. More than one delta cycle is not acceptable because this would indicate a cascade of combinational logic between the reset and the outputs.

All outputs of the VGA controller shall immediately go low on assertion of the
reset signal and remain low for as long as the reset signal is asserted.

### Horizontal VGA Waveform

> The horizontal waveform consists of four distinct phases:
> - Sync period
> - Back porch
> - Visible image area
> - Front porch
>
> During the sync period, the sync output and the color outputs are held low.
> During the back porch, the sync output is high and the color outputs are held low.
> During the visible image area, the sync output is high and no requirements apply to the color outputs.
> During the front porch, the sync output is high and the color outputs are held low.
> 
> Conceptually, the first phase of the cycle is the sync period. However, because the sync
> outputs are low during reset, the first full phase after the device comes out of reset is the back porch.
>
> The requirements of this specification define the waveform in terms of the edges of the sync output and activity on the color outputs. This provides a complete description of the VGA waveform in a way that is easy to test in a VHDL testbench.

#### Wake-Up From Reset

The elapsed time from the rising edge of the reset input to the subsequent falling edge of the horizontal sync output shall be no greater than 100 ms.

> This requirement requires a falling edge, not a rising one. Since the sync output is held low during reset, this implies that a rising edge must occur sometime in this 100 ms as well. The behavior of the color output during this 100-ms period is not specified. This is because VGA monitors, and therefore this specification, are only interested in the steady-state waveform behavior. Any "blips" or irregular behavior following reset are irrelevant, as long as the waveform is correct beginning with the first sync period.

#### Horizontal Cycle Period

The elapsed time from each falling edge of the horizontal sync output to the subsequent falling edge of the horizontal sync output shall be no less than 31.7 us and no greater than 31.9 us, unless the reset input is driven low within 31.7 us of the first falling edge. In this case, the Reset State requirement shall apply.

> This requirement defines the total period of the horizontal cycle because each cycle begins with a falling edge of the sync output.

#### Sync Period

The elapsed time from each falling edge of the horizontal sync output to the subsequent rising edge of the horizontal sync output shall no less than 3.80 us and no greater than 3.83 us, unless the reset input is driven low within 3.80 us of the falling edge. In this case, the Reset State requirement shall apply.

#### Behavior of Color Outputs During Sync Phase

Whenever the horizontal sync output is low, the color outputs shall be all-low.

#### Horizontal Back Porch

Following each rising edge of the horizontal sync output, the color outputs shall be all-low for no shorter than 1.585 us. This requirement does not apply during the period between the rising edge of the reset input and the subsequent falling edge of the horizontal sync output.

#### Horizontal Front Porch

Prior to each falling edge of the horizontal sync output, the color outputs shall be all-low for no shorter than 317 ns. This requirement does not apply during the period between the rising edge of the reset input and the subsequent falling edge of the horizontal sync output. 

#### Vertical Sync

During the vertical sync period, the vertical sync period shall be low. At all other times, the vertical sync output shall be high. During the vertical sync period, the color output shall be all low. The vertical sync output shall go low on the same clock edge that the horizontal sync output goes low. The vertical sync output shall remain low for two horizontal scan periods, then go high on the same clock edge that the horizontal sync output goes low.

#### Vertical Back Porch

Following the vertical sync period, the color ouputs shall remain all-low for no fewer than 25 horizontal scan periods.

#### Vertical Front Porch

Prior to the vertical sync period, the color outputs shall remain all-low for no fewer than 2 horizontal scan periods.

### Visible Image

No requirements apply to the color ouputs other than those specified in the Sequencing sections.
