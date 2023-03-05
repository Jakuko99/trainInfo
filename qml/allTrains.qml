import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.4

Page {
    id: allTrainsPage
    property real marginVal: units.gu(1)

    Settings {
        id: settings
        category: "train_filters"
        property string typeR_train // passengerTrain types
        property string typeOs_train
        property string typeREX_train
        property string typeEx_train
        property string typeZr_train
        property string typeEN_train
        property string typeSC_train
        property string typeRJ_train
        property string typeEC_train
        property string typeIC_train

        property string typeMn_train    // freightTrain types
        property string typeNex_train
        property string typePn_train
        property string typeRv_train
        property string typeSv_train
        property string typeVlec_train
        property string typeSluz_train

        Component.onCompleted: function(){ // set default values
            if (settings.typeMn_train == ""){
                settings.typeR_train = "yes";
                settings.typeOs_train = "yes";
                settings.typeREX_train = "yes";
                settings.typeEx_train = "yes";
                settings.typeZr_train = "yes";
                settings.typeEN_train = "yes";
                settings.typeSC_train = "yes";
                settings.typeRJ_train = "yes";
                settings.typeEC_train = "yes";
                settings.typeIC_train = "yes";

                settings.typeMn_train = "no";
                settings.typeNex_train = "no";
                settings.typePn_train = "no";
                settings.typeRv_train = "no";
                settings.typeSv_train = "no";
                settings.typeVlec_train = "no";
                settings.typeSluz_train = "no";
                progressLabel.font.bold = true;
                progressLabel.text = "Default config created, restart app for changes to take effect.";
            }
        }
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
        wrapMode: Text.WordWrap
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
        id: settingsDialog
        x: Math.round((root.width - width) / 2)
        y: (root.height - height) / 2 - header.height
        width: 250
        height: 500
        modal: true
        focus: true
        title: "Settings"
        standardButtons: Dialog.Ok
        onAccepted: {
            settingsDialog.close()
        }
        contentItem: ColumnLayout {
            id: settingsColumn
            spacing: 0

            Label{
                id: helpLabel
                text: "Filter options for train visibility:"
            }

            Flickable { //replace with list view and custom getter and setter functions for settings
                id:filterFlickable
                flickableDirection: Flickable.VerticalFlick
                contentHeight: filterColumn.height
                ScrollBar.vertical: ScrollBar {
                    width: units.gu(1)
                    anchors.right: parent.right
                    policy: ScrollBar.AlwaysOn
                }

                ColumnLayout {
                    id: filterColumn
                    spacing: 5
                    CheckBox{
                        id: passengerTrain
                        checked: true
                        text: "Os (passenger train)"
                        onCheckStateChanged: settings.typeOs_train = ((passengerTrain.checkState == Qt.Checked) ? "yes" : "no")
                        Component.onCompleted: passengerTrain.checkState = ((settings.typeOs_train == "yes") ? Qt.Checked : Qt.Unchecked)
                    }
                    CheckBox{
                        id: fastTrain
                        checked: true
                        text: "R (fast train)"
                        onCheckStateChanged: settings.typeR_train = ((fastTrain.checkState == Qt.Checked) ? "yes" : "no")
                        Component.onCompleted: fastTrain.checkState = ((settings.typeR_train == "yes") ? Qt.Checked : Qt.Unchecked)
                    }
                    CheckBox{
                        id: expressTrain
                        checked: true
                        text: "Ex (express train)"
                        onCheckStateChanged: settings.typeEx_train = ((expressTrain.checkState == Qt.Checked) ? "yes" : "no")
                        Component.onCompleted: expressTrain.checkState = ((settings.typeEx_train == "yes") ? Qt.Checked : Qt.Unchecked)
                    }
                    CheckBox{
                        id: regionalExpressTrain
                        checked: true
                        text: "REX (regional express train)"
                        onCheckStateChanged: settings.typeREX_train = ((regionalExpressTrain.checkState == Qt.Checked) ? "yes" : "no")
                        Component.onCompleted: regionalExpressTrain.checkState = ((settings.typeREX_train == "yes") ? Qt.Checked : Qt.Unchecked)
                    }
                    CheckBox{
                        id: manipulationTrain
                        text: "Mn (manipulation train)"
                        onCheckStateChanged: settings.typeMn_train = ((manipulationTrain.checkState == Qt.Checked) ? "yes" : "no")
                        Component.onCompleted: manipulationTrain.checkState = ((settings.typeMn_train == "yes") ? Qt.Checked : Qt.Unchecked)
                    }
                    CheckBox{
                        id: freightExpressTrain
                        text: "Nex (freight express)"
                        onCheckStateChanged: settings.typeNex_train = ((freightExpressTrain.checkState == Qt.Checked) ? "yes" : "no")
                        Component.onCompleted: freightExpressTrain.checkState = ((settings.typeNex_train == "yes") ? Qt.Checked : Qt.Unchecked)
                    }
                    CheckBox{
                        id: intermediateFreightTrain
                        text: "Pn (intermediate freight train)"
                        onCheckStateChanged: settings.typePn_train = ((intermediateFreightTrain.checkState == Qt.Checked) ? "yes" : "no")
                        Component.onCompleted: intermediateFreightTrain.checkState = ((settings.typePn_train == "yes") ? Qt.Checked : Qt.Unchecked)
                    }
                    CheckBox{
                        id: locomotiveTrain
                        text: "Rv (locomotive train)"
                        onCheckStateChanged: settings.typeRv_train = ((locomotiveTrain.checkState == Qt.Checked) ? "yes" : "no")
                        Component.onCompleted: locomotiveTrain.checkState = ((settings.typeRv_train == "yes") ? Qt.Checked : Qt.Unchecked)
                    }
                    CheckBox{
                        id: setTrain
                        text: "Sv (set of trains)"
                        onCheckStateChanged: settings.typeSv_train = ((setTrain.checkState == Qt.Checked) ? "yes" : "no")
                        Component.onCompleted: setTrain.checkState = ((settings.typeSv_train == "yes") ? Qt.Checked : Qt.Unchecked)
                    }
                    CheckBox{
                        id: serviceTrain
                        text: "Sluz (service train)"
                        onCheckStateChanged: settings.typeSluz_train = ((serviceTrain.checkState == Qt.Checked) ? "yes" : "no")
                        Component.onCompleted: serviceTrain.checkState = ((settings.typeSluz_train == "yes") ? Qt.Checked : Qt.Unchecked)
                    }
                }
            }
        }
    }
}
