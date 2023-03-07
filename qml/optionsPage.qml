import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0

Page {
    id: aboutPage
    property real marginVal: units.gu(1)

    Settings {
        id: filter_options
        category: "train_filters" // access settings group defined in different page
    }
    Dialog {
        id: infoDialog
        x: Math.round((root.width - width) / 2)
        y: (root.height - height) / 2 - header.height
        width: units.gu(32)  //250
        modal: true
        focus: true
        title: "Info"
        standardButtons: Dialog.Ok
        onAccepted: {
            infoDialog.close()
        }
        contentItem: ColumnLayout {
            id: dialogColumn
            spacing: 0
            Label {
                id: dialogLabel
                text: ""
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
                text: "Options"
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }
            ToolButton {
                //text: qsTr("⋮")
                text: qsTr(" ")
                //onClicked: optionsMenu.open()
            }
        }
    }
    ColumnLayout {
        id: settingsColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: marginVal
        anchors.rightMargin: marginVal
        anchors.leftMargin: marginVal
        Label {
            text: "All trains configuration:"
            font.bold: true
        }

        Button {
            text: "Restore default filter settings"
            onClicked: {
                filter_options.setValue("typeR_train", "yes");
                filter_options.setValue("typeOs_train","yes");
                filter_options.setValue("typeREX_train", "yes");
                filter_options.setValue("typerjx_train", "yes");
                filter_options.setValue("typeEx_train", "yes");
                filter_options.setValue("typeZr_train", "yes");
                filter_options.setValue("typeEN_train", "yes");
                filter_options.setValue("typeSC_train", "yes");
                filter_options.setValue("typeRJ_train", "yes");
                filter_options.setValue("typeEC_train", "yes");
                filter_options.setValue("typeIC_train", "yes");

                filter_options.setValue("typeMn_train", "no");
                filter_options.setValue("typeNex_train", "no");
                filter_options.setValue("typePn_train", "no");
                filter_options.setValue("typeRv_train", "no");
                filter_options.setValue("typeSv_train", "no");
                filter_options.setValue("typeVlec_train", "no");
                filter_options.setValue("typeSluz_train", "no");
                dialogLabel.text = "Filter values successfully reset!"
                infoDialog.open();
            }
        }
        Button {
            text: "Select all filters"
            onClicked: {
                filter_options.setValue("typeR_train", "yes");
                filter_options.setValue("typeOs_train","yes");
                filter_options.setValue("typeREX_train", "yes");
                filter_options.setValue("typerjx_train", "yes");
                filter_options.setValue("typeEx_train", "yes");
                filter_options.setValue("typeZr_train", "yes");
                filter_options.setValue("typeEN_train", "yes");
                filter_options.setValue("typeSC_train", "yes");
                filter_options.setValue("typeRJ_train", "yes");
                filter_options.setValue("typeEC_train", "yes");
                filter_options.setValue("typeIC_train", "yes");

                filter_options.setValue("typeMn_train", "yes");
                filter_options.setValue("typeNex_train", "yes");
                filter_options.setValue("typePn_train", "yes");
                filter_options.setValue("typeRv_train", "yes");
                filter_options.setValue("typeSv_train", "yes");
                filter_options.setValue("typeVlec_train", "yes");
                filter_options.setValue("typeSluz_train", "yes");
                dialogLabel.text = "All filter values were selected!"
                infoDialog.open();
            }
        }
    }
}
