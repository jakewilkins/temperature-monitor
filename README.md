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

License
=======

In legal text, searcher is dedicated to the public domain using Creative Commons -- CC0 1.0 Universal.

http://creativecommons.org/publicdomain/zero/1.0

