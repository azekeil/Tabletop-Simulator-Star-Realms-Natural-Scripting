# Tabletop-Simulator-Star-Realms-Natural-Scripting

This is a scripted version of Star Realms with support for up to 4 players currently, built heavily on the existing Star Realms workshop releases - credit to steam users Aabra and Rari.

Version 1.1
History:
- v1.0: First public release!
- v1.1: Handle in_play cards that are removed by grouping

This is in development! Currently only trade and combat pools have been scripted, and only the base game has been annotated (although the other cards are available and can be used, these won't be scripted)

Upcoming improvements:
- Support for cards that offer a choice; currently cards with choices are all ignored :(
- Tracking most non-trade, non-combat variables e.g. discards, draws, scraps etc
- Annotating the rest of the card sets
- Support for 6 (8?) players


The premise was to make the user experience as much like the physical game as possible, automating the adding of pools and triggering of allies, without forcing the user to do things differently than they might do in the real world.

As such there are several concepts used here:

- 'UnPlaying a card', which allows a user to make most trivial corrections should they change their mind. In the more extreme cases a user may need to restart their turn - but this is no different to the real world.

- Turns are triggered by the next player playing a card. This triggers resets of pools.


Feedback to the steam workshop page is welcome!
http://steamcommunity.com/sharedfiles/filedetails/?id=772422344
You can also raise an issue or pull request on github:
https://github.com/azekeil/Tabletop-Simulator-Star-Realms-Natural-Scripting


As always, please support White Wizard Games who created the original game:

http://www.starrealms.com/buy/
