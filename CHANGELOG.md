## 2.5.0

## Enhancements
* Autoselect chip driver
* Add command/response to read pump's standard basal schedule
* Add rolling history data and full command/response set to PumpFake

## v2.4.0

### Enhancements
* Support subg_rfspy and rfm69 via SPI by making the communication driver a configuration option

## v2.3.0

### Enhancements
* Extract `subg_rfspy` client code into separate hex package

### Bug Fixes
* Fix credo warnings that cause a non-zero exit status
* While fixing `@moduledocs` in those modules, also document their types and functions, so that most undocumented functions are now documented too with `@doc` and `@spec`
* Fix lines > 120 characters
* Remove `()` from function definitions

## v2.2.0

This release contains the following changes:

* Removes reliance on local system timezone and makes timezone application explicit
* Fixes BolusWizardSetup decoding on older x22 pumps (Use 124 bytes instead of longer format)

## v2.1.7

Use tuple for read_time response

## v2.1.6

Remove additional :ok tuples from Pump response

## v2.1.5

Bugfix:

* Fixes Pummpcomm.Monitor.BloodGlucoseMonitor to expect a tuple for `get_current_cgm_page`

## v2.1.4

This release:

* Adds get_model_number to Pummpcomm.Session.Pump
* Unifies the response from all Pump genserver calls to return a tuple

## v2.1.3

Move project to github.com/infinity-aps/pummpcomm

## v2.1.2

Add read_settings convenience function to `Pummpcomm.Session.Pump`

## v2.1.1

Minor bugfixes and stability improvement in tuning functionality.

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
