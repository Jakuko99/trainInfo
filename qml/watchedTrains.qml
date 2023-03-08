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
                        text: "Add new train"
                        onTriggered: addDialog.open()
                    }
                    MenuItem {
                        text: "Manage watched trains"
                        onTriggered: manageDialog.open()
                    }
                    MenuItem {
                        text: "Remove all trains"
                        onTriggered: confirmDialog.open()
                    }
                }
            }
        }
    }
    ListView {
        id: favoriteTrainView
        clip: true
        anchors.fill: parent
        anchors.topMargin: marginVal
        anchors.bottomMargin: marginVal
        anchors.leftMargin: marginVal
        anchors.rightMargin: marginVal
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar {
            width: units.gu(1)
            anchors.right: parent.right
            policy: ScrollBar.AsNeeded
        }
        model: dataModel

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
                        text: number
                        wrapMode: Text.WordWrap
                        color: "#247cd7"
                        font.bold: true
                    }
                    Label {
                        id: trainDestInfo
                        //text: destinationFrom
                        wrapMode: Text.WordWrap
                    }
                    Label {
                        id: trainDestInfoCont
                        //text: destinationTo
                        wrapMode: Text.WordWrap
                    }
                    Label {
                        id: positionInfo
                        //text: position
                        wrapMode: Text.WordWrap
                        font.bold: true
                    }
                    Label{
                        id: delayInfo
                        //text: 'Delay: '+ delay + ' min'
                        wrapMode: Text.WordWrap
                        font.bold: true
                    }
                    Label {
                        id: providerInfo
                        //text: provider
                        wrapMode: Text.WordWrap
                    }
                    Button {
                        text: "Fetch data"
                        Layout.alignment: Qt.AlignRight
                        onClicked: function(){
                            trainName.text = "Fetching train info..." //show that something is happening
                            python.call("example.getData", [number], function(returnVal) {
                                const json_obj = JSON.parse(returnVal);
                                //console.log(returnVal)
                                if (json_obj["CisloVlaku"]){ // train found
                                    if (json_obj["NazovVlaku"]){
                                        trainName.text = json_obj.DruhVlakuKom.trim() + ' ' + json_obj.CisloVlaku + " " + json_obj.NazovVlaku;
                                    } else {
                                        trainName.text = json_obj.DruhVlakuKom.trim() + ' ' + json_obj.CisloVlaku;
                                    }
                                    trainDestInfo.text = json_obj.StanicaVychodzia + " (" + json_obj.CasVychodzia + ") -> ";
                                    trainDestInfoCont.text = json_obj.StanicaCielova + " (" + json_obj.CasCielova + ")";
                                    positionInfo.text = "Position: " + json_obj.StanicaUdalosti + " " + json_obj.CasUdalosti;
                                    delayInfo.text = "Delay: " + json_obj.Meskanie + " min";
                                    providerInfo.text = "Provider: " + json_obj.Dopravca;
                                    if (json_obj.Meskanie < 5){ // color code position based on delay
                                        delayInfo.color = "green";
                                    } else if ((json_obj.Meskanie >= 5) && (json_obj.Meskanie < 20)){
                                        delayInfo.color = "orange";
                                    } else {
                                        delayInfo.color = "red";
                                    }
                                } else { // train not found
                                    trainName.text = "Train not found";
                                    trainDestInfo.text = "";
                                    trainDestInfoCont.text = "";
                                    positionInfo.text = "";
                                    providerInfo.text = "";
                                }
                            }
                            );
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
            title: "Manage watched trains"
            standardButtons: Dialog.Ok
            onAccepted: {
                manageDialog.close()
            }
            contentItem: ColumnLayout {
                spacing: 0
                ListView {
                    id: trainList
                    clip: true
                    spacing: marginVal
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
                        id: watchItem
                        width: parent.width
                        height: itemColumn.height
                        ColumnLayout {
                            id: itemColumn
                            Layout.fillWidth: true
                            RowLayout{
                                id: manageRow
                                Layout.fillWidth: true
                                Label {
                                    id: numberLabel
                                    text: number
                                    Layout.alignment: Qt.AlignLeft                                    
                                } // figure out proper aligment for this list
                                Button{
                                    id: removeButton
                                    text: "Remove"
                                    Layout.alignment: Qt.AlignRight
                                    onClicked: dataModel.remove(index) // remove item from model
                                }
                            }
                        }
                    }
                }
            }
        }

        Dialog {
            id: addDialog
            x: Math.round((root.width - width) / 2)
            y: (root.height - height) / 2 - header.height
            width: units.gu(32)  //250
            height: units.gu(20) //500
            modal: true
            focus: true
            title: "Add new item"
            standardButtons: Dialog.Ok
            onAccepted: {
                if (trainNumb.text !== "") { // if there is not text, ignore input
                    dataModel.append({number: Number(trainNumb.text)})
                }
                trainNumb.text = "";
                manageDialog.close()
            }
            Component.onCompleted: {
                addDialog.standardButton(Dialog.Ok).text = qsTrId("Add"); // rename dialog button
            }

            contentItem: ColumnLayout {
                spacing: 0
                TextField {
                    id: trainNumb
                    Layout.fillWidth: true
                    placeholderText: "Enter train number..."
                    text: ""
                    validator: IntValidator{bottom: 0; top: 10000}
                }
            }
        }

        Dialog { //confirm before deleting all dialog
            id: confirmDialog
            x: Math.round((root.width - width) / 2)
            y: (root.height - height) / 2 - header.height
            width: units.gu(32)  //250
            height: units.gu(20) //500
            modal: true
            focus: true
            title: "Confirm action"
            standardButtons: Dialog.Yes | Dialog.No
            onAccepted: {
                dataModel.clear();
                confirmDialog.close();
            }

            contentItem: ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                Label {
                    text: "Are you sure to remove all trains from the list?"
                    font.bold: true
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }
    }
}
