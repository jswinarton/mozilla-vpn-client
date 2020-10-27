/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

namespace Constants {

// Let's refresh the IP address any 10 seconds.
#ifndef UNIT_TEST
constexpr int IPADDRESS_TIMER_MSEC = 10000;
#else
constexpr int IPADDRESS_TIMER_MSEC = 0;
#endif

// Let's check the connection status any second.
constexpr int CHECKSTATUS_TIMER_MSEC = 1000;

// Number of points for the charts.
constexpr int CHARTS_MAX_POINTS = 30;

};
