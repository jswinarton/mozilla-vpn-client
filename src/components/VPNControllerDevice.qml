/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.5
import QtQuick.Layouts 1.15

import Mozilla.VPN 1.0

import "../themes/themes.js" as Theme

VPNClickableRow {
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 0

        VPNIconAndLabel {
            icon: "../resources/devices.svg"
            title: qsTr("My devices")
        }

        Item {
            Layout.fillWidth: true
        }

        VPNLightLabel {
            id: label
            Layout.rightMargin: 8
        }

        VPNChevron {
            id: icon
        }
        state: VPNController.state !== VPNController.StateDeviceLimit ? "active": "deviceLimit"
        states: [
            State {
                name: "active" // normal mode
                PropertyChanges {
                    target: label
                    text: qsTr("%1 of %2").arg(VPNDeviceModel.activeDevices).arg(
                              VPNUser.maxDevices)
                }
            },
            State {
                name: "deviceLimit" // device limit mode
                PropertyChanges {
                    target: label
                    text: qsTr("%1 of %2").arg(VPNDeviceModel.activeDevices + 1).arg(
                              VPNUser.maxDevices)
                }
                PropertyChanges {
                    target: icon
                    source: "../resources/warning.svg"
                    sourceSize.height: 14
                    sourceSize.width: 14
                    Layout.rightMargin: 6
                    Layout.leftMargin: 6
                }
            }
        ]
    }
}
