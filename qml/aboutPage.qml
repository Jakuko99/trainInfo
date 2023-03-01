import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import io.thp.pyotherside 1.4

Page {
    id: aboutPage

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

    Flickable {
        id: aboutFlickable
        anchors.fill: parent
        anchors.topMargin: units.gu(2)
        contentHeight: aboutCloumn.height

        Column {
            id: aboutCloumn
            anchors.centerIn: parent
            spacing: units.gu(2)
            width: parent.width

            Image {
                id: appLogo
                property bool rounded: true
                property bool adapt: true
                source: Qt.resolvedUrl("../assets/logo.jpg")
                width: Suru.units.gu(15)
                height: Suru.units.gu(15)
                anchors.horizontalCenter: parent.horizontalCenter

                layer.enabled: rounded
                layer.effect: OpacityMask {
                    maskSource: Item {
                        width: appLogo.width
                        height: appLogo.height
                        Rectangle {
                            anchors.centerIn: parent
                            width: appLogo.adapt ? appLogo.width : Math.min(appLogo.width, appLogo.height)
                            height: appLogo.adapt ? appLogo.height : width
                            //radius: Math.min(width, height)
                            radius: 15
                        }
                    }
                }
            }

            Item {
                height: nameAndVersionLayout.height
                width: nameAndVersionLayout.width
                anchors.horizontalCenter: parent.horizontalCenter

                ColumnLayout {
                    id: nameAndVersionLayout
                    anchors.centerIn: parent
                    Label{
                        text: i18n.tr("Train info")
                        font.pixelSize: units.gu(3)
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Label {
                        id: versionLabel
                        text: "version placeholder"
                        Component.onCompleted: function(){
                            var versionString = i18n.tr("Version %1").arg(Qt.application.version);
                            versionLabel.text = versionString;
                        }
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: units.gu(1.75)
                    }
                    ColumnLayout {
                        width: parent.width
                        Button {
                            text: "Get the source"
                            onClicked: Qt.openUrlExternally("https://github.com/Jakuko99/traininfo")
                        }
                        Button {
                            text: " Report issues  "
                            onClicked: Qt.openUrlExternally("https://github.com/Jakuko99/traininfo/issues")
                        }
                    }
                }
            }
        }
    }
}
