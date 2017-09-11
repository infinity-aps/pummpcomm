# Pummpcomm

Pummpcomm is an Elixir library to handle communication with a Medtronic insulin pump. It is inspired by the work of Ben West's [decocare](https://github.com/openaps/decocare). It can run commands, receive responses, and decode multipacket history and cgm data. Development discussion and questions are answered in the [Type 1 Diabetes + Elixir Discord server](https://discord.gg/XfJ78mA).

[![Build Status](https://travis-ci.org/infinity-aps/pummpcomm.svg?branch=master)](https://travis-ci.org/infinity-aps/pummpcomm)

## Project structure

### High Level

The Monitor modules Pummpcomm.Monitor.BloodGlucoseMonitor and Pummpcomm.Monitor.HistoryMonitor provide a friendly interface into the CGM and Pump History fetch commands. Since data for blood glucose and general pump history come in chunks of binary events, this layer handles pulling the correct number of pages back to fetch x minutes of recent history in the respective pages. For example, if you want the last 20 minutes of CGM readings, calling Pummpcomm.Monitor.BloodGlucoseMonitor.get_sensor_values(20) will result in pulling as many pages of cgm history as needed to fulfill the request, and only entries from the requested timeframe will be returned.

### Mid Level

The pump session Pummpcomm.Session.Pump sits under the Monitor layer and provides a logical structure to model the packets, commands and responses needed to communicate with the insulin pump. Here you will find the functions to retrieve the model number, pull a single 1024 byte page of history or cgm data, or retrieve the date and time from the pump.

This is also the layer where page decoding happens. CGM and pump history comes in chunks of 1024 bytes, storing all the events that can be packed into that space. Pummpcomm.Cgm and Pummpcomm.History are the entry points for decoding those pages of data.

### Low Level

At the lowest level, Pummpcomm has a driver layer to talk to the pump. Currently the only supported chip/serial combination is a cc111x chip running the subg_rfspy firmware. The hex package to talk to that chip can be found at [elixir_subg_rfspy](https://github.com/infinity-aps/elixir_subg_rfspy).

### Tests

Pummpcomm aims to be comprehensively tested at the feature and at the unit level. It is critical that functions within the project are tested well. As a result, you'll see multiple layers of testing and all PRs should contain tests that describe for others the reason that the change is being implemented.
