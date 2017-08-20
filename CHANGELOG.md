## v2.1.1

Minor bugfixes and stability improvement in tuning funcationality.

## v2.1.0

Key changes:
* Improvements to the frequency of wait_for_silence calls. Pummcomm.Session.Pump will not wait for silence unless separate calls requiring communication are separated by more than 4 seconds.
* The Pummpcomm.Session.Pump genserver automatically performs frequency tuning during first communication with the insulin pump.

## v2.0.0

This release introduces the complete set of pump commands needed to support oref0 looping in NervesAPS. This is not the full complement of pump commands, but it is a large step forward toward stabilization of pummpcomm and its APIs.

Key changes:
* Support for set_temp_basal on compatible pumps
* Support for pulling settings, battery status, insulin remaining, and profile information
* Cleanup of Pummpcomm.Session.Pump for readability
* Integration (serial) tests of all command/response exchanges with playback-from-file support when serial hardware is not available. This allows people without pump hardware to improve the code without fear of breaking pump interactions
* Improved module and function API documentation
