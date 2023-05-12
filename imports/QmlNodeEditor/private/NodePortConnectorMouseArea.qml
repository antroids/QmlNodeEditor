import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    DropArea {
        id: nodePortConnectorDropArea

        anchors.fill: parent
        property int portId: portModel.portId
        property int nodeId

        property string tags: portModel.tags || ""

        Binding on nodeId {
            value: if (nodeModel) nodeModel.nodeId
            when: nodeModel
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.DragLinkCursor
        preventStealing: true
        acceptedButtons: Qt.LeftButton
        drag.target: nodePortConnectorDragTarget
        drag.smoothed: false
        onPressed: (mouseEvent) => {
                       var globalConnectorCoordinates = mapToGlobal(x + width / 2, y + height / 2);
                       var globalMouseCoordinates = mapToGlobal(mouseX, mouseY);
                       shapeContainer.dragNewConnection(globalConnectorCoordinates, globalMouseCoordinates, portModel.filter);
                   }
        onReleased: {
            var dropTarget = shapeContainer.dropNewConnection();
            if (dropTarget) {
                console.info("connectionAdded " + nodeModel.nodeId);
                nodeView.connectionAdded(nodeModel.nodeId, portModel.portId, dropTarget.nodeId, dropTarget.portId);
            }
        }
    }
}
