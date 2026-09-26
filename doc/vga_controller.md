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

## Performance

### Reset Behavior

#### Reset State

All outputs of the VGA controller shall immediately go low on assertion of the
reset signal and remain low for as long as the reset signal is asserted.

#### Wake-up From Reset

The VGA controller shall show activity on one or more of the output signals, consistent with the other requirements of this specification, no longer than one millisecond after deassertion of the reset signal.

### Sequencing

#### Horizontal Sync

The duration of the horizontal sync phase shall be 3.79 to 3.83 us. During this period, the horizontal sync output shall be low. At all other times, the horizontal sync output shall be high. During the horizontal sync period, the color output shall be all low.

#### Horizontal Back Porch

Following the horizontal sync period, the color output shall be all low for no shorter than 1.585 us.

#### Horizontal Front Porch

Prior to the horizontal sync period, the color output shall be all low for no shorter than 316 ns.

#### Horizontal Scan Period

The duration of the horizontal scan, defined as the period between one rising edge of the horizontal sync output and the following rising edge of the horizontal sync output, shall be 31.6 to 31.9 us.

#### Vertical Sync

During the vertical sync period, the vertical sync period shall be low. At all other times, the vertical sync output shall be high. During the vertical sync period, the color output shall be all low. The vertical sync output shall go low on the same clock edge that the horizontal sync output goes low. The vertical sync output shall remain low for two horizontal scan periods, then go high on the same clock edge that the horizontal sync output goes low.

#### Vertical Back Porch

Following the vertical sync period, the color ouputs shall remain all-low for no fewer than 25 horizontal scan periods.

#### Vertical Front Porch

Prior to the vertical sync period, the color outputs shall remain all-low for no fewer than 2 horizontal scan periods.

### Visible Image

No requirements apply to the color ouputs other than those specified in the Sequencing sections.
