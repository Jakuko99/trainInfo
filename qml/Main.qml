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
import Ubuntu.Components 1.3 as Ubuntu
import QtQuick.Controls.Suru 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.4


ApplicationWindow {
    id: root
    objectName: 'mainView'
    //applicationName: 'traininfo.jakub'
    //automaticOrientation: true
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

    StackView{
        id: stack
        initialItem: mainPage
        anchors.fill: parent
    }

    Page {
        id: mainPage
        //anchors.fill: parent //maybe StackView sets fill for all pages

        header: ToolBar {
            id: toolbar
            RowLayout {
                anchors.fill: parent
                Label {
                    //text: qsTr("‹")
                    text: qsTr(" ") // invisible for now
                    //onClicked: stack.pop()
                }
                Label {
                    text: "Train info"
                    elide: Label.ElideRight
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                }
                ToolButton {
                    text: qsTr("⋮")
                    onClicked: optionsMenu.open()

                    Menu {
                        id: optionsMenu
                        transformOrigin: Menu.TopRight
                        x: parent.width - width
                        y: parent.height

                        MenuItem {
                            text: "All trains"
                            onTriggered: stack.push(Qt.resolvedUrl("allTrains.qml"))
                        }
                        MenuItem {
                            text: "Settings"
                            onTriggered: settingsDialog.open()
                        }
                        MenuItem {
                            text: "About"
                            onTriggered: stack.push(Qt.resolvedUrl("aboutPage.qml"))
                        }
                    }
                }
            }
        }

        Label {
            anchors.top: parent.top
            id: infoLabel
            anchors.leftMargin: marginVal
            anchors.left: parent.left
            text: "This app is using API provided by ZSSK. Enter train number into field below:"
            wrapMode: Text.WordWrap
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Row {
            anchors.leftMargin: marginVal
            anchors.topMargin: marginVal
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
                onClicked: function(){
                    clearFields()
                    nameLabel.text = "Fetching train info..." //show that something is happening
                    python.call("example.getData", [numberField.text], function(returnVal) {
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
        }

        Column {
            anchors.rightMargin: 0
            anchors.leftMargin: 0
            anchors.topMargin: marginVal
            anchors.top: inputRow.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 1

            Label {
                id: nameLabel
                wrapMode: Text.WordWrap
                color: "#247cd7"
                anchors.leftMargin: marginVal
                anchors.right: parent.right
                anchors.left: parent.left
                text: qsTr("Train info placeholder")
                font.bold: true

            }

            Label {
                id: trainDestLabel
                text: qsTr("Destination placeholder")
                wrapMode: Text.WordWrap
                anchors.right: parent.right
                anchors.leftMargin: marginVal
                anchors.left: parent.left
            }

            Label {
                id: positionLabel
                anchors.right: parent.right
                anchors.leftMargin: marginVal
                anchors.left: parent.left
                text: qsTr("Position placeholder")
                wrapMode: Text.WordWrap
                font.bold: true
            }

            Label {
                id: providerLabel
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.leftMargin: marginVal
                anchors.bottomMargin: marginVal
                text: qsTr("Provider placeholder")
                wrapMode: Text.WordWrap
            }
            Button {
                text: qsTr("Clear")
                anchors.right: parent.right
                anchors.rightMargin: marginVal
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

    Dialog {
        id: settingsDialog
        x: Math.round((root.width - width) / 2)
        y: (root.height - height) / 2 - header.height
        width: Math.round(root.width / 3 * 2)
        modal: true
        focus: true
        title: "Settings"

        standardButtons: Dialog.Ok
        onAccepted: {
            settingsDialog.close()
        }

        contentItem: ColumnLayout {
            id: settingsColumn
            spacing: 5

            Label{
                id: helpLabel
                text: "Filter options for train visibility:"
            }
            CheckBox{
                id: passengerTrain
                checked: true
                text: "Os (passenger train)"
            }
            CheckBox{
                id: fastTrain
                checked: true
                text: "R (fast train)"
            }
            CheckBox{
                id: expressTrain
                checked: true
                text: "Ex (express train)"
            }
            CheckBox{
                id: regionalExpressTrain
                checked: true
                text: "REX (regional express train)"
            }
            CheckBox{
                id: manipulationTrain
                text: "Mn (manipulation train)"
            }
            CheckBox{
                id: freightExpressTrain
                text: "Nex (freight express)"
            }
            CheckBox{
                id: intermediateFreightTrain
                text: "Pn (intermediate freight train)"
            }
            CheckBox{
                id: locomotiveTrain
                text: "Rv (locomotive train)"
            }
            CheckBox{
                id: setTrain
                text: "Sv (set of trains)"
            }
            CheckBox{
                id: serviceTrain
                text: "Sluz (service train)"
            }
        }
    }
}
