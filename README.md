Built for modern versions of the linux mint cinnamon distribution to take advantage of its ease, but also add back some privacy elements.

can be run with -
curl -fsSL mint.faelan.org | bash

This is a set of work in progress linux mint cinnamon bash scripts which are des+igned to make it a more privacy focused experience.

This is not for everyone and is not intended to be a full setup.  This is solely intended as a starting point to build off of with the tedious parts reduced as much as possible.

Currently included

- Proton VPN
  auto start
  private but fast preloaded settings

- Brave Browser
  -  policy regulation
 -   near max privacy settings with bonus lockdown settings
  -  telemetry and google remnants removed and or disabled
  -  full data wiping on site close and browser close
  -  includes all standard brave protections
  -  also comes with proton pass to minimize cookie loss annoyance

- Xsecurelock
  -  light locker sucks as a lockscreen so xsecurelock fully replaces it
  -  enables whenever screen idles out
  -  (can cause conflicts if you re-enable cinnamons screensaver)
  -  no info leak + computer is fully hidden (includng apps/background)
  -  fully replacing default also means the screen reveal flicker is solved

- Cinnamon visuals
  -  not required but default cinnamon is ugly
  -  uses preinstalled packages to just modernise in a few places

- Common Dependencies added
  includes extra common dependencies which are now auto installed
  includes but not limited to
  java, node, ffmpeg, xdotool, x11, and all required dependencies of added software
