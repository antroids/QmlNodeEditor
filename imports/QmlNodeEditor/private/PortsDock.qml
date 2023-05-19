import QtQuick 2.15
import QtQuick.Controls 2.15

Column {
    required property Component nodePortComponent
    required property var model

    property real relativeX: parent.relativeX + x
    property real relativeY: parent.relativeY + y

    property alias repeater: portDockRepeater
    property int layoutDirection: Qt.LeftToRight

    width: nodeView.style.rightPortDockWidth + nodeView.style.nodePortConnectorMargin

    id: nodePortDock

    Repeater {
        id: portDockRepeater
        model: nodePortDock.model
        anchors.left: parent.left
        anchors.right: parent.right

        delegate: PortsDockRow {}
    }

    Item {
        id: filler
        width: nodePortDock.width
        height: 1
    }
}
