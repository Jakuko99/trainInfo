import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.4

Page {
    id: allTrainsPage
    property real marginVal: units.gu(1)
    property string datastore: ""

    Settings {
        id: watchedItems
        category: "watched_items"
        property alias watched_trains: allTrainsPage.datastore
    }

    Component.onCompleted: { // load model from config file
        if (datastore) {
            dataModel.clear()
            var datamodel = JSON.parse(datastore)
            for (var i = 0; i < datamodel.length; ++i) dataModel.append(datamodel[i])
        }
    }
    Component.onDestruction: { //save model to config file
        var datamodel = []
        for (var i = 0; i < dataModel.count; ++i) datamodel.push(dataModel.get(i))
        datastore = JSON.stringify(datamodel)
    }

    ListModel {
        id: dataModel
    }

    header: ToolBar {
        id: toolbar
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: qsTr("‹")
                onClicked: stack.pop()
            }
            Label {
                text: "Favorite trains"
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
                        text: "Clear list"
                        onTriggered: contentTrainList.model.clear()
                    } // add method for addings trains and how to store them
                    MenuItem {
                        text: "Manage watched trains"
                        onTriggered: manageDialog.open()
                    }
                }
            }
        }
    }
    ColumnLayout {
        id: watchColumn
        anchors.top: parent.top
        anchors.topMargin: marginVal
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: marginVal
        anchors.leftMargin: marginVal
        Button {
            text: "Fetch data"
            Layout.fillWidth: true
        }
        ListView {
            id: favoriteTrainView
            ListView{
                id: contentTrainList
                clip: true
                anchors.fill: parent
                flickableDirection: Flickable.VerticalFlick
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {
                    width: units.gu(1)
                    anchors.right: parent.right
                    policy: ScrollBar.AlwaysOn
                }
                model: ListModel{
                    id: trainList
                }

                delegate: Item {
                    width: parent.width
                    height: contentFrame.height + marginVal
                    Frame {
                        id: contentFrame
                        width: parent.width
                        ColumnLayout {
                            id: frameColumn
                            Layout.fillWidth: true
                            anchors.right: parent.right
                            anchors.left: parent.left
                            spacing: 0
                            Label {
                                id: trainName
                                text: name
                                wrapMode: Text.WordWrap
                                color: "#247cd7"
                                font.bold: true
                            }
                            Label {
                                id: trainDestInfo
                                text: destinationFrom
                                wrapMode: Text.WordWrap
                            }
                            Label {
                                id: trainDestInfoCont
                                text: destinationTo
                                wrapMode: Text.WordWrap
                            }
                            Label {
                                id: positionInfo
                                text: position
                                wrapMode: Text.WordWrap
                                font.bold: true
                            }
                            Label{
                                id: delayInfo
                                text: 'Delay: '+ delay + ' min'
                                Component.onCompleted: function(){ //adjust color based on delay value
                                    if (delay < 5){
                                        delayInfo.color = "green";
                                    } else if ((delay >= 5) && (delay < 20)){
                                        delayInfo.color = "orange";
                                    } else {
                                        delayInfo.color = "red";
                                    }
                                }
                                wrapMode: Text.WordWrap
                                font.bold: true
                            }
                            Label {
                                id: providerInfo
                                text: provider
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
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
            id: manageDialog
            x: Math.round((root.width - width) / 2)
            y: (root.height - height) / 2 - header.height
            width: units.gu(32)  //250
            height: units.gu(63) //500
            modal: true
            focus: true
            title: "Settings"
            standardButtons: Dialog.Ok
            onAccepted: {
                manageDialog.close()
            }
            contentItem: ColumnLayout {
                id: settingsColumn
                spacing: 0

                Label{
                    id: helpLabel
                    text: "Filter options for train visibility:"
                }

                ListView {
                    id: filterList
                    clip: true
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    flickableDirection: Flickable.VerticalFlick
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar {
                        width: units.gu(1)
                        anchors.right: parent.right
                        policy: ScrollBar.AsNeeded // hide scrollbar after some time
                    }
                    model: dataModel

                    delegate: Item {
                        width: parent.width
                        height: filterColumn.height
                        ColumnLayout {
                            id: filterColumn
                            RowLayout{
                                id: manageRow
                                Label {
                                    text: "Train number: " + number
                                }
                                Button{
                                    text: "Delete"
                                }
                            }
                            Label{
                                text: "Comment: " + text
                            }
                        }
                    }
                }
            }
        }
    }
}
