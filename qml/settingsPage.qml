import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Page {
    id: aboutPage
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
                text: "Settings"
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
    ColumnLayout{
        id: settingColumnLayout
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: marginVal
        anchors.right: parent.right
        anchors.rightMargin: marginVal

        Label{
            text: "Under construction"
            Layout.alignment: Qt.AlignHCenter
            font.bold: true
        }

        Button {
            id: restoreButton
            text: "Restore default config"
        }
    }
}
