# battery-alert
Battery monitoring with visible and audible notification

## Table of Contents

1. [Description](#description)
   - [Notification levels](#notification-levels)
   - [Alert levels](#alert-levels)
   - [Halt level](#halt-level)
   - [Audio notification](#audio-notification)
2. [Installation](#installation)
   - [Requirements](#requirements)
   - [Procedure](#procedure)
      * [Using git](#using-git)
      * [Zip file](#zip-file)
   - [make options](#make-options)
      * [Variables](#variables)
      * [Command line parameters](#command-line-parameters)
3. [Configuration](#configuration)
   - [Default configuration](#default-configuration)
3. [Execution](#execution)
   - [systemd](#systemd)
   - [openrc](#openrc)
   - [runit](#runit)
   - [Manual execution](#manual-execution)
4. [Controlling battery-alert](#controlling-battery-alert)
5. [Sources](#sources)
6. [Changelog](#changelog)

## Description

*battery-alert* is yet another battery monitoring script, written in **bash** scripting language.

Its difference from other similar scripts is that it provides visible **and audible** notification depending on battery charging level.

The mentality behind this behavior is not to keep the system running as long as possible; it's rather to keep the user notified about the situation and eventually halt the system before data loss occurs (due to an unexpected shutdown).

The need for this script emerged after having my laptop (running i3 window manager) powering off on me on various occasions, like while listening to music and dealing with other staff, etc.

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

   High alert level. Notification will be active once every 60 seconds (default value). Default value: **20%**.

2. **THRESHOLD_LOW**

   Low alert level. Notification will be displayed repeatedly. Default value: **15%**.

### Halt level

1. **THRESHOLD_HALT**

   System halt level. This is actually not a notification level, since when reached, the system will be halted. Default value: **7%**.
   
   The command to halt the system is configurable (see [Configuration](#configuration)).
   
   Default command: **systemctl poweroff**.

### Audio notification

Audio playback will occur in the background (i.e. no program window of any kind will be visible). Playback volume will be the one set at the system mixer, so some precaution should take place on this respect. After all, what is the point in using audio notification if audio volume is low enough to make it inaudible?

*battery-alert* by default uses **mpg123** as an audio player, because it is light-weight enough and gets installed by default on most systems, but any mp3 player can be used, provided that it is a terminal application (or it can hide its window) and will print no diagnostic or other messages in *stdout* (or it can suppress them).

If for any reason one prefers not to install it, or use a different player, or even not to use one at all, one should follow the [relevant installation instructions](#make-options).

## Installation

### Requirements

*battery-alert* depends on **GNU make** for its configuration.

The following programs are also used:

1. **coreutils** - The basic file, shell and text manipulation
2. **ps** - Report a snapshot of the current processes
3. **grep** - A string search utility
4. **sed** - GNU stream editor
5. **gzip** - GNU compression utility

*battery-alert* depends on the follwoing programs for its execution:

1. **bash** - Well, it is a **bash** script, after all
2. **bc** - An arbitrary precision calculator language
3. **su** - Run a command with substitute user and group ID (if run as a service; refer to: [Execution](#execution))
4. **libnotify** - Library for sending desktop notifications (not required if **console** or **console-no-mpg123** make arguments are used; refer to [make options](#make-options))
5. **mpg123** - A console based real time MPEG Audio Player for Layer 1, 2 and 3 (optional)

### Procedure

Download *battery-alert* either using **git** or by a **zip file**.

#### Using git

```ruby
git clone https://github.com/s-n-g/battery-alert.git
cd battery-alert
```

#### Zip file

```ruby
wget https://github.com/s-n-g/battery-alert/archive/master.zip
unzip master.zip
cd battery-alert-master
```

Run make (refer to [make options](#make-options) for installation customization)

```ruby
make
```


Finally, go on and install it

```ruby
sudo make install
```

### make options

#### Variables

The **Makefile** that comes with the package provides a couple of variables which control the installation process:

<dl>
<dt>SHELL</dt>
<dd>The shell to be used by <b>make</b> for its execution.</dd>
<dd>Default value: <b>/bin/bash</b></dd>
<dt>PREFIX</dt>
<dd>Script installation prefix. The script will actually be installed in **$PREFIX/bin**.</dd> 
<dd>Default value: <b>/usr/local</b></dd>
<dt>SYSTEMD_SERVICES_DIRECTORY</dt>
<dd>Systemd installation directory. This is where the service file will be copied.</dd>
<dd>Default value: <b>/lib/systemd/system</b></dd>
</dl>

If necessary, the **Makefile** should be edited so that these two variables match the system at hand.

<dl>
<dt>Note</dt>
<dd>If the system is a <b>non-systemd</b> one, no file editing is needed; <b>make</b> will detect the situation and will not install a systemd service.</dd>
</dl>

#### Command line parameters

In addition to those, the following targets (command line augments to **make**):

<dl>
    <dt>default</dt>
    <dd>Contains the default options for <i>battery-alert</i>.</dd>
    <dd>These are the options used when <b>make</b> is executed without any arguments.</dd>
    <dd>Options description:<dd>

<ol>
<li>make sure essential packages are already installed</li>
<li>make sure <i>notify-send</i> executable is already installed</li>
<li>make sure <i>mpg123</i> executable is already installed</li>
<li>make sure <i>systemd service</i> is up to date</li>
</ol>

</dl>
<dl>
    <dt>no-mpg123</dt>
    <dd>Do not require <b>mpg123</b> to be installed.</dd>
    <dt>console</dt>
    <dd>This option will disable visual notification. In other words, one would use this option to have <i>battery-alert</i> running on a non-graphical environment.</dd>
    <dt>console-no-mpg123</dt>
    <dd>Same as above, but <b>mpg123</b> would not be required.</dd>
    <dt>help</dt>
    <dd>print help screen and exit</dd>
</dl>


Example:

```ruby
$ make
** Checking for essential packages ... done 
** Checking for notify-send ... found
** Checking for mpg123 ... not found
  *** You must install mpg123 (package mpg123)
make: *** [Makefile:42: with_mpg123] Error 1
$
$ make no-mpg123
** Checking for essential packages ... done 
** Checking for notify-send ... found
Creating systemd service ... done
```

<dl>
  <dt>Note</dt>
    <dd>In this case, a valid <b>PLAYER_COMMAND</b> has to be provided for audio notification to work (see <a href="#configuration">Configuration</a>).
  <dd>If <b>PLAYER_COMMAND</b> is empty or invalid, audio notification will be inhibited.</dd>
</dl>


## Configuration

The package's system wide configuration is located in **/etc/battery-alert.conf**.

To customize it, one has to create a user writable configuration file and edit it.

```ruby
mkdir ~/.config/battery-alert
cp /etc/battery-alert.conf ~/.config/battery-alert/config
```

Before editing the file, one should suspend *battery-alert*, if it is running.

```ruby
battery-alert suspend
```

After editing this file, one should source it in order to check its validity.

On a **bash** terminal:

```ruby
. ~/.config/battery-alert/config
```
  
If no error occurs, you are good to go.

If *battery-alert* has been suspended, resume its execution.

```ruby
battery-alert resume
```

<dl>
  <dt>Note</dt>
   <dd>If an error occurs, <i>battery-alert</i> will terminate, so be aware.</dd>
</dl>


### Default configuration

The default configuration is the following:

- if battery goes over 80%, issue notification "**Disconnect power supply**"
- if battery drops below 40%, issue notification "**Connect power supply**"
- if battery drops below 20%, issue notification "**Low battery**" every 30 seconds
- if battery drops below 15%, issue notification "**Low battery**" repeatedly
- if battery drops below 7%, **halt** the system

```ruby
# USER
# This will be the user that visual notification will
# be executed for. Default value is the user name of
# whoever executes make
USER=spiros

# THRESHOLDS DEFINITION
# Thresholds are defined in arrays
# Items are:
#  0  battery limit
#  1  message title to display
#  2  message to display
#  3  icon to display
#     either absolute or relative path to file
#     if relative, it should be in /usr/share/battery-alert
#  4  sound to play
#     path works the same as with icon
#  5  time to display notification (in milliseconds)
#     it should be the same as the duration
#     of the sound file
#  6  check interval (in seconds)
#     time to wait between battery status check
#     if it is 0, do not wait
#     effectively displaying notification repeatedly
#  7  Enable / Disable
#     Applies on notification alerts only
#     Value: [yes] / no

#  - THRESHOLD_HIGH
#    If battery percentage is lower than this, a notification
#    will be displayed and a sound will be played once
THRESHOLD_HIGH[0]=20
THRESHOLD_HIGH[1]="Low battery"
THRESHOLD_HIGH[2]="Battery running critically low at $charge_percent%!"
THRESHOLD_HIGH[3]=warning-high.png
THRESHOLD_HIGH[4]=warning-low.mp3
THRESHOLD_HIGH[5]=7000
THRESHOLD_HIGH[6]=30

#  - THRESHOLD_LOW
#    If battery percentage is lower than this, both the
#    notification and the sund will be on indefinatelly
THRESHOLD_LOW[0]=15
THRESHOLD_LOW[1]="Low battery"
THRESHOLD_LOW[2]="Battery running critically low at $charge_percent%!"
THRESHOLD_LOW[3]=warning-low.png
THRESHOLD_LOW[4]=warning-low.mp3
THRESHOLD_LOW[5]=7000
THRESHOLD_LOW[6]=0

#  - THRESHOLD_HALT
#    If a HALT_COMMAND is defined, the PC will be halted /
#    powered off, when battery status is bellow this
#    threshold
#
#    only item 0 has any meaning here
THRESHOLD_HALT[0]=7

#  - THRESHOLD_NOTIFY_HIGH
#    Notify that user can now disconnect the power supply
THRESHOLD_NOTIFY_HIGH[0]=80
THRESHOLD_NOTIFY_HIGH[1]="Battery notification"
THRESHOLD_NOTIFY_HIGH[2]="You can now disconnect the power supply"
THRESHOLD_NOTIFY_HIGH[3]=notify-high.png
THRESHOLD_NOTIFY_HIGH[4]=notify-high.mp3
THRESHOLD_NOTIFY_HIGH[5]=5300
THRESHOLD_NOTIFY_HIGH[6]=60
THRESHOLD_NOTIFY_HIGH[7]=yes

#  - THRESHOLD_NOTIFY_LOW
#    Notify that user should now connect the power supply
THRESHOLD_NOTIFY_LOW[0]=40
THRESHOLD_NOTIFY_LOW[1]="Battery notification"
THRESHOLD_NOTIFY_LOW[2]="You should now connect the power supply"
THRESHOLD_NOTIFY_LOW[3]=notify-low.png
THRESHOLD_NOTIFY_LOW[4]=notify-low.mp3
THRESHOLD_NOTIFY_LOW[5]=5300
THRESHOLD_NOTIFY_LOW[6]=60
THRESHOLD_NOTIFY_LOW[7]=yes

# END OF THRESHOLDS DEFINITION

# This is the command what will play the warning message.
# Default is mpg123, since it's very light on resources.
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

## Execution

Once *battery-alert* is installed, one can test it using the following command:

```ruby
battery-alert test
```

This will display (and play) all available alerts and notifications that will be used in normal operation.

### systemd

To execute *battery-alert*, run the command:

```ruby
sudo systemctl start battery-alert
```

To have *battery-alert* run on system start up, run the command:

```ruby
sudo systemctl enable battery-alert
```

### openrc

To execute *battery-alert*, run the command:

```ruby
sudo /etc/init.d/battery-alert start
```

To have *battery-alert* run on system start up, run the command:

```ruby
sudo rc-update add battery-alert
```
### runit

To have *battery-alert* run on system start up and execute it, run the command:

```ruby
sudo ln -s /etc/sv/battery-alert /var/service
```

### Manual execution

If one prefers to manually execute *battery-alert*, he has to do that through the auto start feature provided by the DE or WM.

For example, if using i3, one would add the following line to **~/.config/i3/config**:

```ruby
exec --no-startup-id /usr/loca/bin/battery-alert
```

## Controlling battery-alert

Communication with *battery-alert* is done from command line.

*battery-alert* listens for input on a named pipe (FIFO), **/tmp/battery-alert**.

Available commands:

<dl>
<dt>suspend</dt>
<dd>suspend execution - the script stops checking and reporting battery status</dd>
<dt>resume</dt>
<dd>resume execution - the script resumes checking and reporting battery status</dd>
<dt>status</dt>
<dd>report status - returns a string, either "<b>running</b>", "<b>suspended</b>" or "<b>not running</b>"</dd>
<dt>vstatus</dt>
<dd>report status visually - displays a notification reporting its current status</dd>
<dt>test</dt>
<dd>display (and play) all notification that would occur under normal operation</dd>
<dt>exit | quit</dt>
<dd>terminate execution</dd>
</dl>

Example:

```ruby
battery-alert status
```

## Sources

### (and resources)

- The script is based on the [batmon](https://agorf.gr/2016/06/29/low-battery-notification-in-i3wm/) script by **Angelos Orfanakos**, published under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/).

- The icons are derived from [maateen/battery-monitor](https://github.com/maateen/battery-monitor).

- The sounds come from the Public Domain and [www.fromtexttospeech.com](http://www.fromtexttospeech.com).

- Numerous web pages on **bash** scripting, **make** and **github markup**.

## Changelog

- 4/6/18

  First public release

