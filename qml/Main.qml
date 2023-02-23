/*
 * Copyright (C) 2023  Jakub Krsko
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * traininfo is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import QtQuick.Window 2.3
import Ubuntu.Components 1.3
import QtQuick.Controls.Suru 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.4

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'traininfo.jakub'
    automaticOrientation: true
    width: units.gu(45)
    height: units.gu(75)
    property real marginVal: units.gu(1)

    function clearFields(){
        nameLabel.text = "";
        trainDestLabel.text = "";
        positionLabel.text = "";
        providerLabel.text = "";
    }

    Component.onCompleted: clearFields() // remove placeholder text

    Page {
        id: page
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: i18n.tr('Train info')
        }
        Label {
            anchors.top: PageHeader.bottom
            id: infoLabel
            anchors.leftMargin: marginVal
            anchors.left: parent.left
            text: "This app is using API provided by ZSSK. Enter train number into field below:"
            wrapMode: Text.WordWrap
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Row {
            anchors.leftMargin: marginVal
            anchors.top: infoLabel.bottom
            anchors.left: parent.left
            spacing: marginVal
            id: inputRow

            TextField {
                id: numberField
                text: qsTr("")
                placeholderText: "Enter train number..."
                validator: IntValidator{bottom: 0; top: 10000}
            }
            Button {
                id: button
                text: qsTr("Search")
                onClicked: python.call("example.getData", [numberField.text], function(returnVal) {
                        const json_obj = JSON.parse(returnVal);
                        //console.log(returnVal)
                        if (json_obj["CisloVlaku"]){ // train found
                            if (json_obj["NazovVlaku"]){
                                nameLabel.text = json_obj.DruhVlakuKom.trim() + ' ' + json_obj.CisloVlaku + " " + json_obj.NazovVlaku;
                            } else {
                                nameLabel.text = json_obj.DruhVlakuKom.trim() + ' ' + json_obj.CisloVlaku;
                            }
                            trainDestLabel.text = json_obj.StanicaVychodzia + " (" + json_obj.CasVychodzia + ") -> " + json_obj.StanicaCielova + " (" + json_obj.CasCielova + ")";
                            positionLabel.text = "Position: " + json_obj.StanicaUdalosti + " " + json_obj.CasUdalosti + " Delay: " + json_obj.Meskanie + " min";
                            providerLabel.text = "Provider: " + json_obj.Dopravca;
                        } else { // train not found
                            nameLabel.text = "Train not found";
                            trainDestLabel.text = "";
                            positionLabel.text = "";
                            providerLabel.text = "";
                        }
                    }
             );
            }
        }

        Column {
            anchors.rightMargin: 0
            anchors.leftMargin: 0
            anchors.topMargin: marginVal
            anchors.top: inputRow.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            Label {
                id: nameLabel
                color: "#247cd7"
                anchors.top: parent.top
                anchors.left: parent.left                
                anchors.leftMargin: marginVal
                text: qsTr("Train info placeholder")
                font.bold: true

            }

            Label {
                id: trainDestLabel
                text: qsTr("Destination placeholder")
                wrapMode: Text.WordWrap
                anchors.top: nameLabel.bottom
                anchors.left: parent.left
                anchors.leftMargin: marginVal
                anchors.right: parent.right
            }

            Label {
                id: positionLabel
                text: qsTr("Position placeholder")
                wrapMode: Text.WordWrap
                anchors.top: trainDestLabel.bottom
                anchors.left: parent.left
                anchors.leftMargin: marginVal
                anchors.right: parent.right
                font.bold: true
            }

            Label {
                id: providerLabel
                text: qsTr("Provider placeholder")
                wrapMode: Text.WordWrap
                anchors.top: positionLabel.bottom
                anchors.left: parent.left
                anchors.leftMargin: marginVal
                anchors.right: parent.right
            }
            Button {
                anchors.top: providerLabel.bottom
                anchors.topMargin: marginVal
                anchors.right: parent.right
                anchors.rightMargin: marginVal
                text: qsTr("Clear")
                onClicked: clearFields()
            }
        }
    }


    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));
            importModule('example', function() {
            });
        }      
        onError: {
            console.log('python error: ' + traceback);
        }
    }
}
