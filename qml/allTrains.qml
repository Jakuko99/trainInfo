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
            Label {
                //text: qsTr("⋮")
                text: qsTr(" ")
                //onClicked: optionsMenu.open()
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
                        var trainDest = obj.StanicaVychodzia + " (" + obj.CasVychodzia + ") -> " + obj.StanicaCielova + " (" + obj.CasCielova + ")";
                        var position = "Position: " + obj.StanicaUdalosti + " " + obj.CasUdalosti + " Delay: " + obj.Meskanie + " min";
                        var delayVal = obj.Meskanie;
                        var provider = "Provider: " + obj.Dopravca;
                        trainList.append({name: trainName, destination: trainDest, position:position, provider:provider})
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
        //contentHeight: contentColumn.height
        ScrollBar.vertical: ScrollBar {
            width: 10
            anchors.right: parent.right // adjust the anchor as suggested by derM
            policy: ScrollBar.AlwaysOn
        }

        ListView{
            id: contentTrainList
            anchors.fill: parent
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds
            model: ListModel{
                id: trainList
            }

            delegate: Item {
                width: parent.width
                Frame {
                    width: parent.width
                    ColumnLayout {
                        id: frameColumn
                        Layout.fillWidth: true
                        anchors.right: parent.right
                        anchors.left: parent.left
                        spacing: 0
                        Text {
                            id: trainName
                            text: name
                            wrapMode: Text.WordWrap
                            color: "#247cd7"
                            font.bold: true
                        }
                        Text {
                            id: trainDestInfo
                            text: destination
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            id: positionInfo
                            text: position
                            wrapMode: Text.WordWrap
                            font.bold: true
                        }
                        Text {
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
}
