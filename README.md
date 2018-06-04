# sng-batmon
Battery monitoring with sound alert

## Table of Content

1. [Description](#description)
   - [Notification levels](#notification-levels)
   - [Alert levels](#alert-levels)
   - [Halt level](#halt-level)
   - [Audio notification](#audio-notification)
2. [Installation](#installation)
3. [Configuration](#configuration)
   - [Default configuration](#default-configuration)
4. [Sources](#sources)
4. [Changelog](#changelog)

## Description

*sng-batmon* is yet another battery monitoring script, written in **bash** scripting language.

Its difference from other similar scripts is that it provides visible **and audible** notification depending on battery charging level.

The mentality behind this behavior is not to keep the system running as long as possible; it's rather to keep the user notified about the situation and eventaully halt the system before data loss occurs (due to an unexpected shutdown).

The need for this script emerged after having my laptop (running i3 window manager) powering off on me, while listening to music and dealing with other staff...

In this respect, the script uses 5 levels (2 notification, 2 low level alert and a halt level).

All level data (messages, icons, sounds) are configurable (see [Configuration](#configuration)).

### Notification levels

The purpose of these notification levels is to try and keep the battery between 40%-80% of its maximum charging level at all times, in an attempt to extend its life.

1. **THRESHOLD_NOTIFY_HIGH**

   High notification level. Default value: **80%**.

2. **THRESHOLD_NOTIFY_LOW**

   Low notification level. Default value: **40%**.

### Alert levels

These levels will produce a visible warning and an "annoying" audible notification.

1. **THRESHOLD_HIGH**

   High alert level. Notification will be active once every minute. Default value: **20%**.

2. **THRESHOLD_LOW**

   Low alert level. Notification will be displayed repeatedly. Default value: **15%**.

### Halt level

1. **THRESHOLD_HALT**

   System halt level. Ths is actuall not a notification level, since when reached, the system will be halted. Default value: **7%**.
   
   The command to halt the system is configurable (see [Configuration](#configuration)).
   
   Default command: **systemctl poweroff**.

### Audio notification

Audio playback will occur in the background (i.e. no program window of any kind will be visible). Playback volume will be the one set at the system mixer, so some precaution should take place on this respect. That means, what is the point in using audio notification if audio volume is low enough to make them inaudible?

*sng-batmon* by default uses **mpg123** as an audio player, because it is light-weight enough and gets installed by default on most systems.

If for any reason one prefers not to install it, or not to use it, one should follow the [relevant installation instructions](#installation).

## Installation

Download *sng-batmon*

```ruby
git clone https://github.com/s-n-g/sng-batmon.git
```

Run make

```ruby
make
```

if *make* fails because of *mpg123* not being installed, and one does not want to install it, one can use the *no-mpg123* make argument.

```ruby
$ make
** Checking for head ... found
** Checking for notify-send ... found
** Checking for bc ... found
** Checking for mpg123 ... not found
  *** You must install mpg123 (package mpg123)
make: *** [Makefile:15: check_dependencies] Error 1
$
$ make no-mpg123
** Checking for head ... found
** Checking for notify-send ... found
** Checking for bc ... found
$
```

In this case, a valid **PLAYER_COMMAND** has to be provided for audio notification to work (see [Configuration](#configuration)).

Finally, go on and install it

```ruby
sudo make install
```

## Configuration

The pacakge's system wide configuration is located in **/etc/sng-batmon.conf**.

To customize it, one has to create a user writable config file and edit it.

```ruby
mkdir ~/.config/sng-batmon
cp /etc/sng-batmon.conf ~/.config/sng-batmon/config
```

After editing this file, one should source it in order to check its validity.

On a **bash** terminal:

```ruby
. ~/.config/sng-batmon/config
```
  
If no error is occurs, you are good to go.

<dl>
  <dt>Note</dt>
  <dd>Any changes made to the configuration file will take effect within the next minute.</dd>
   <dd>If an error occurs, <i>sng-batmon</i> will terminate, so be aware.</dd>
</dl>

### Default configuration

The default configuration is the following:

```ruby
# ALERT THRESHOLDS DEFINITION
# Thresholds are defined in arrays
# Items are:
#  0  battery limit
#  1  message title to display
#  2  message to display
#  3  icon to display
#  4  sound to play
#  5  time to display notification (in milliseconds)
#     it should be the same as the duration
#     of the sound file

#  - THRESHOLD_HIGH
#    If battery percentage is lower than this, a notification
#    will be displayed and a sound will be played once
THRESHOLD_HIGH[0]=20
THRESHOLD_HIGH[1]="Low battery"
THRESHOLD_HIGH[2]="Battery running critically low at $charge_percent%!"
THRESHOLD_HIGH[3]=warning-high.png
THRESHOLD_HIGH[4]=warning-low-battery.mp3
THRESHOLD_HIGH[5]=7000

#  - THRESHOLD_LOW
#    If battery percentage is lower than this, both the
#    notification and the sund will be on indefinatelly
THRESHOLD_LOW[0]=15
THRESHOLD_LOW[1]="Low battery"
THRESHOLD_LOW[2]="Battery running critically low at $charge_percent%!"
THRESHOLD_LOW[3]=warning-low.png
THRESHOLD_LOW[4]=warning-low-battery.mp3
THRESHOLD_LOW[5]=7000

#  - THRESHOLD_HALT
#    If a HALT_COMMAND is defined, the PC will be halted /
#    powered off, when battery status is bellow this
#    threshold
THRESHOLD_HALT[0]=7
THRESHOLD_HALT[1]=""
THRESHOLD_HALT[2]=""
THRESHOLD_HALT[3]=""
THRESHOLD_HALT[4]=""
THRESHOLD_HALT[5]=0

#  - THRESHOLD_NOTIFY_HIGH
#    Notify that user can now disconnect the power supply
THRESHOLD_NOTIFY_HIGH[0]=80
THRESHOLD_NOTIFY_HIGH[1]="Battery notification"
THRESHOLD_NOTIFY_HIGH[2]="You can now disconnect the power supply"
THRESHOLD_NOTIFY_HIGH[3]=notify-high.png
THRESHOLD_NOTIFY_HIGH[4]=notify-high.mp3
THRESHOLD_NOTIFY_HIGH[5]=5000

#  - THRESHOLD_NOTIFY_LOW
#    Notify that user should now connect the power supply
THRESHOLD_NOTIFY_LOW[0]=40
THRESHOLD_NOTIFY_LOW[1]="Battery notification"
THRESHOLD_NOTIFY_LOW[2]="You should now connect the power supply"
THRESHOLD_NOTIFY_LOW[3]=notify-low.png
THRESHOLD_NOTIFY_LOW[4]=notify-low.mp3
THRESHOLD_NOTIFY_LOW[5]=5000

# END OF THRESHOLDS DEFINITION

# This is the command what will play the warning message.
# default is mpg123, since it's very light on resources
# If empty, no sound will be played
#
# Examples:
#PLAYER_COMMAND="cvlc -q"
#PLAYER_COMMAND="ffplay -volume 100 --autoexit -nodisp -v 0 -i"
#PLAYER_COMMAND="mplayer -msglevel all=-1"
#PLAYER_COMMAND="play -q"
PLAYER_COMMAND="mpg123 -q"

# HALT COMMAND DEFINITION
# Define here the command to be used to power off your PC
# It's up to you to make sure the command can be executed
# (has the right permission etc.)
#
# Examples:
#HALT_COMMAND="xfce4-session-logout -h"
#HALT_COMMAND="xfce4-session-logout -s"
#HALT_COMMAND="xfce4-session-logout --hibernate"
#HALT_COMMAND="systemctl suspend"
#HALT_COMMAND="systemctl hibernate"
#HALT_COMMAND="systemctl hybrid-sleep"
HALT_COMMAND="systemctl poweroff"
```

## Sources

### (and resources)

- The script is based on the [batmon](https://agorf.gr/2016/06/29/low-battery-notification-in-i3wm/) script by **Angelos Orfanakos**, published under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/).

- The icons are derived from [maateen/battery-monitor](https://github.com/maateen/battery-monitor).

- The sounds come from the Public Domain and [www.fromtexttospeech.com](http://www.fromtexttospeech.com).

## Changelog

- 4/6/18

  First public release
