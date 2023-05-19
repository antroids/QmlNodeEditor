import QtQuick 2.15
import QtQuick.Controls 2.15

Row {
    id: portDockRow
    layoutDirection: nodePortDock.layoutDirection

    property var portModel: model.portId ? model : modelData

    property int portId: portModel.portId
    property int nodeId: nodeRoot.nodeModel.nodeId

    property string tags: portModel.tags || ""

    property real relativeConnectorX: nodePortDock.relativeX +
                            portDockRepeater.x +
                            x +
                            portConnectorItem.x +
                            portConnectorLoader.x +
                            portConnectorLoader.width / 2

    property real relativeConnectorY: nodePortDock.relativeY +
                            portDockRepeater.y +
                            y +
                            portConnectorItem.y +
                            portConnectorLoader.y +
                            portConnectorLoader.height / 2

    function getNodeRoot() {
        return nodeRoot;
    }

    states: [
        State {
            name: "highlighted"
        },
        State {
            when: hoverHandler.hovered
            name: "hovered"
        }
    ]
    HoverHandler {
        id: hoverHandler
    }

    Item {
        id: portConnectorItem
        width: nodeView.style.nodePortConnectorMargin
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        Loader {
            id: portConnectorLoader
            property var portModel: portDockRow.portModel
            property var nodeModel: nodeRoot.nodeModel
            property string state: portDockRow.state
            property QtObject style: nodeView.style
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            sourceComponent: nodeView.nodePortConnectorComponent
        }
        Loader {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: portConnectorLoader.left
            anchors.right: portConnectorLoader.right
            property var portModel: portDockRow.portModel
            property var nodeModel: nodeRoot.nodeModel
            property string state: portDockRow.state
            property QtObject style: nodeView.style
            sourceComponent: nodeView.nodePortConnectorMouseArea
        }
    }
    Loader {
        property var portModel: portDockRow.portModel
        property var nodeModel: nodeRoot.nodeModel
        property string state: portDockRow.state
        property QtObject style: nodeView.style
        width: nodePortDock.width - portConnectorItem.width
        sourceComponent: nodePortDock.nodePortComponent
    }
}