Temperature Monitor
===================

This monitors the temperature in my living room using a Photon board with a
thermometer, and talks to a TP-Link Wifi plug to turn on and off my window
A/C unit.

To try and complicate things as much as possible, it uses a K-Nearest Neighbors
algorithm to figure out whether it should be on/off, the two axis being indoor
temperature vs. outdoor temperature, so on hot days we get some lead time.

I have a AWS IOT button that will toggle manually and learn a new point, or
respond to feedback that it made a good decision.

It's flat because it's not a gem. It's just some code running on a raspberry pi.

One of a new series of projects that I can work on if I could get a proof of concept
running in a day. In this case, I had to be able to use [Charles](https://www.charlesproxy.com/)
to sniff the API that the Wifi Plug was using, as well as build the thermometer
bit (I'm new to hardware). If I was better at Wiring all this would be running on
the device, but I'm bad at it, so it's here instead.

License
=======

In legal text, searcher is dedicated to the public domain using Creative Commons -- CC0 1.0 Universal.

http://creativecommons.org/publicdomain/zero/1.0

