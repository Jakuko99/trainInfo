import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import io.thp.pyotherside 1.4

Page {
    id: allTrainsPage
    property real marginVal: units.gu(1)

    header: ToolBar {
        id: toolbar
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: qsTr("‹")
                onClicked: stack.pop()
            }
            Label {
                text: "All trains"
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
                    }
                    MenuItem{
                        text: 'Settings'
                        onTriggered: settingsDialog.open()
                    }
                }
            }
        }
    }

    Label {
        id: infoLabel
        text: "Fetch information about all trains according to filter settings:"
        wrapMode: Text.WordWrap
        anchors.left: parent.left
        anchors.leftMargin: marginVal
        anchors.right: parent.right
        anchors.top: parent.top
    }

    Button {
        id: fetchButton
        text: "Fetch train info"
        anchors.left: parent.left
        anchors.top: infoLabel.bottom
        anchors.leftMargin: marginVal
        anchors.rightMargin: marginVal
        anchors.topMargin: marginVal
        anchors.right: parent.right
        onClicked: function(){
            contentTrainList.model.clear() //remove old items
            progressLabel.text = "Fetching train info..." //show that something is happening
            python.call("example.getAllData", [], function(returnVal) {
                const json_obj = JSON.parse(returnVal);
                progressLabel.text = "";
                for(let i = 0; i < json_obj.length; i++) {
                    let obj = json_obj[i];
                    var trainName = "";
                    if (obj["CisloVlaku"]){ // train found
                        if (obj["NazovVlaku"]){
                            trainName = obj.DruhVlakuKom.trim() + ' ' + obj.CisloVlaku + " " + obj.NazovVlaku;
                        } else {
                            trainName = obj.DruhVlakuKom.trim() + ' ' + obj.CisloVlaku;
                        }
                        var trainDestFrom = obj.StanicaVychodzia + " (" + obj.CasVychodzia + ") -> ";
                        var trainDestTo = obj.StanicaCielova + " (" + obj.CasCielova + ")";
                        var position = obj.StanicaUdalosti + " " + obj.CasUdalosti;
                        var delay = obj.Meskanie;
                        var delayVal = obj.Meskanie;
                        var provider = "Provider: " + obj.Dopravca;
                        trainList.append({name: trainName, destinationFrom: trainDestFrom, destinationTo: trainDestTo, position:position, delay: delay, provider:provider})
                    }
                }

            }
            );
        }
    }

    Label{
        id: progressLabel
        text: ""
        anchors.top: fetchButton.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.leftMargin: marginVal
        anchors.rightMargin: marginVal
    }

    Flickable {
        id: contentFlickable
        flickableDirection: Flickable.VerticalFlick
        anchors.top: fetchButton.bottom
        anchors.topMargin: marginVal
        anchors.rightMargin: marginVal
        anchors.leftMargin: marginVal
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        ListView{
            id: contentTrainList
            clip: true
            anchors.fill: parent
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar {
                width: 15
                anchors.right: parent.right
                policy: ScrollBar.AlwaysOn
            }
            model: ListModel{
                id: trainList
            }

            delegate: Item {
                width: parent.width
                height: contentFrame.height + 10
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
