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
        property string typerjx_train
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
            if (settings.value("typeMn_train", "") === ""){
                settings.typeR_train = "yes";
                settings.typeOs_train = "yes";
                settings.typeREX_train = "yes";
                settings.typerjx_train = "yes";
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

    function filterAddItem(type){ // check if value should be added according to settings
        var settingsVal = settings.value("type" + type + "_train", "not_set")
        if (settingsVal === "yes"){
            return true;
        } else if (settingsVal === "no"){
            return false;
        } else {
            return true; // return also types not defined in settings
        }
        //return ((settings.value("type" + type + "_train", "not_set") === "yes") ? true : false);
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
                        if (filterAddItem(obj.DruhVlakuKom.trim())){
                            trainList.append({name: trainName, destinationFrom: trainDestFrom, destinationTo: trainDestTo, position:position, delay: delay, provider:provider});
                        }
                    }
                }
                if (trainList.rowCount() === 0) { // if no items satisfy the set filters
                    progressLabel.text = "No trains found for given filter selection. Change filters and try again.";
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
        width: units.gu(32)  //250
        height: units.gu(63) //500
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
                model: ListModel{
                    id: trainFilterList
                    ListElement {
                        settingsID: "typeIC_train"
                        shortID: "IC"
                        caption: "IC (intercity train)"
                    }
                    ListElement {
                        settingsID: "typeEC_train"
                        shortID: "EC"
                        caption: "EC (eurocity train)"
                    }
                    ListElement {
                        settingsID: "typeRJ_train"
                        shortID: "RJ"
                        caption: "RJ (RegioJet train)"
                    }
                    ListElement {
                        settingsID: "typeSC_train"
                        shortID: "SC"
                        caption: "SC (supercity train)"
                    }
                    ListElement {
                        settingsID: "typeEN_train"
                        shortID: "EN"
                        caption: "EN (euronight train)"
                    }
                    ListElement {
                        settingsID: "typeZr_train"
                        shortID: "Zr"
                        caption: "Zr (accelerated train)"
                    }
                    ListElement {
                        settingsID: "typerjx_train"
                        shortID: "rjx"
                        caption: "rjx (railjet express)"
                    }
                    ListElement {
                        settingsID: "typeEx_train"
                        shortID: "Ex"
                        caption: "Ex (express train)"
                    }
                    ListElement {
                        settingsID: "typeR_train"
                        shortID: "R"
                        caption: "R (fast train)"
                    }
                    ListElement {
                        settingsID: "typeREX_train"
                        shortID: "REX"
                        caption: "REX (regional express)"
                    }
                    ListElement {
                        settingsID: "typeOs_train"
                        shortID: "Os"
                        caption: "Os (passenger train)"
                    }

                    ListElement {
                        settingsID: "typeMn_train"
                        shortID: "Mn"
                        caption: "Mn (maniputaion train)"
                    }
                    ListElement {
                        settingsID: "typeNex_train"
                        shortID: "Nex"
                        caption: "Nex (freight express)"
                    }
                    ListElement {
                        settingsID: "typePn_train"
                        shortID: "Pn"
                        caption: "Pn (intermediate freight train)"
                    }
                    ListElement {
                        settingsID: "typeRv_train"
                        shortID: "Rv"
                        caption: "Rv (locomotive train)"
                    }
                    ListElement {
                        settingsID: "typeSv_train"
                        shortID: "Sv"
                        caption: "Sv (set of trains)"
                    }
                    ListElement {
                        settingsID: "typeVlec_train"
                        shortID: "Vlec"
                        caption: "Vlec (siding train)"
                    }
                    ListElement {
                        settingsID: "typeSluz_train"
                        shortID: "Sluz"
                        caption: "Sluz (service train)"
                    }
                }

                delegate: Item {
                    width: parent.width
                    height: filterColumn.height
                    ColumnLayout {
                        id: filterColumn
                        CheckBox{
                            id: filterCheckbox
                            text: caption
                            onCheckStateChanged: settings.setValue(settingsID, ((filterCheckbox.checkState == Qt.Checked) ? "yes" : "no"))
                            checked: ((settings.value(settingsID) === "yes") ? true : false)
                        }
                    }
                }
            }
        }
    }
}
