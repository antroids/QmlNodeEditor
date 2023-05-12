import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15

Item {
    id: shapeContainer
    anchors.fill: parent

    Repeater {
        model: connectionsModel
    }

    Shape {
        id: newConnection
        anchors.fill: parent
        visible: false

        property string filter: ""

        property alias startX: newConnectionShapePath.startX
        property alias startY: newConnectionShapePath.startY

        function drag(globalConnector, globalMouse) {
            var connectorCoordinates = shapeContainer.mapFromGlobal(globalConnector.x, globalConnector.y);
            var mouseCoordinates = shapeContainer.mapFromGlobal(globalMouse.x, globalMouse.y);
            startX = connectorCoordinates.x;
            startY = connectorCoordinates.y;
            nodePortConnectorDragTarget.x = mouseCoordinates.x;
            nodePortConnectorDragTarget.y = mouseCoordinates.y;
            nodePortConnectorDragTarget.Drag.active = true;
            visible = true;
            setPortsState("highlighted", filter);
        }

        function drop() {
            visible = false;
            var target = nodePortConnectorDragTarget.Drag.target;
            nodePortConnectorDragTarget.Drag.active = false;
            setPortsState("");
            return target && checkFilterOnTags(target.tags, filter) ? target : undefined;
        }

        ShapePath {
            id: newConnectionShapePath
            startX: 0
            startY: 0

            strokeWidth: nodeView.style.connectionStrokeWidth
            strokeColor: nodeView.style.connectionStrokeColor
            fillColor: "transparent"

            PathLine {
                id: newConnectionPath
                x: nodePortConnectorDragTarget.x
                y: nodePortConnectorDragTarget.y
            }
        }
    }

    function dragNewConnection(globalConnector, globalMouse, filter) {
        newConnection.filter = filter || "";
        newConnection.drag(globalConnector, globalMouse);
    }

    function dropNewConnection() {
        return newConnection.drop();
    }
}
