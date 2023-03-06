import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.4

Page {
    id: allTrainsPage
    property real marginVal: units.gu(1)

    Settings {
        id: watchedItems
        category: "watched_trains"

        property var watched_train_numbers: []
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
                }
            }
        }
    }
}
