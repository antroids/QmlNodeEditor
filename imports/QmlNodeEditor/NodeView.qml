import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15
import QtQml.Models

import QmlNodeEditor 1.0
import "private" as Private

Item {
    id: nodeView
    anchors.fill: parent

    required property var model

    property int deleteKey: Qt.Key_Delete

    property QtObject style: NodeViewStyle {}

    property Component connectionShape: Private.ConnectionShape {}

    property Component connectionComponent: Private.ConnectionComponent {}

    property Component nodeDeleteConfirmationDialog: Private.NodeDeleteConfirmationDialog {}

    property Component connectionDeleteConfirmationDialog: Private.ConnectionDeleteConfirmationDialog {}

    property Component nodeHeaderComponent: Private.NodeHeader {}

    property Component nodeTopContentComponent: Private.NodeTopContent {}

    property Component nodeCenterContentComponent: Private.NodeCenterContent {}

    property Component nodeLeftPortComponent: Private.NodeLeftPort {}

    property Component nodeRightPortComponent: Private.NodeRightPort {}

    property Component nodePortConnectorComponent: Private.NodePortConnector {}

    property Component nodePortConnectorMouseArea: Private.NodePortConnectorMouseArea {}

    property Component snapGridComponent: Private.SnapGrid {}

    property ObjectModel connectionsModel: ObjectModel {}

    signal connectionAdded(int fromNodeId, int fromPortId, int toNodeId, int toPortId)
    signal connectionRemoved(int fromNodeId, int fromPortId, int toNodeId, int toPortId)

    signal nodeRemoved(int nodeId)
    signal nodePositionChanged(int nodeId, real x, real y)

    Loader {
        id: snapGrid
        anchors.fill: parent
        sourceComponent: nodeView.snapGridComponent

        function snapPosition(point) {
            return item ? item.snapPosition(point) : point;
        }
    }

    Item {
        id: nodesContainer
        anchors.fill: parent

        Repeater {
            id: nodesRepeater
            model: nodeView.model

            delegate: Private.Node {
                id: nodeRoot
            }

            onItemAdded: (index, node) => updateAllConnectionComponentsByNodeId(node.nodeId);
            onItemRemoved: (index, node) => removeAllConnectionComponentsByNodeId(node.nodeId);
        }
    }

    Item {
        id: nodePortConnectorDragTarget
        Drag.active: false
    }

    Private.ShapeContainer {
        id: shapeContainer
    }

    function findConnectorRow(nodeId, portId) {
        for(var nodeIndex = 0; nodeIndex < nodesRepeater.count; nodeIndex++) {
            var nodeElement = nodesRepeater.itemAt(nodeIndex);
            if (nodeElement && nodeElement.nodeId === nodeId) {
                var leftPortDockRepeater = nodeElement.leftPortDockRepeater;
                if (leftPortDockRepeater) {
                    for(var leftPortIndex = 0; leftPortIndex < leftPortDockRepeater.count; leftPortIndex++) {
                        var leftPortElement = leftPortDockRepeater.itemAt(leftPortIndex);
                        if (leftPortElement && leftPortElement.portId === portId) {
                            return leftPortElement;
                        }
                    }
                }
                var rightPortDockRepeater = nodeElement.rightPortDockRepeater
                if (leftPortDockRepeater) {
                    for(var rightPortIndex = 0; rightPortIndex < rightPortDockRepeater.count; rightPortIndex++) {
                        var rightPortElement = rightPortDockRepeater.itemAt(rightPortIndex);
                        if (rightPortElement && rightPortElement.portId === portId) {
                            return rightPortElement;
                        }
                    }
                }
            }
        }

        return undefined;
    }

    function updateAllConnectionComponents() {
        var model = nodeView.model;
        removeAllConnectionComponents();
        for(var nodeIndex = 0; nodeIndex < model.count; nodeIndex++) {
            var nodeModel = model.get(nodeIndex);
            if (nodeModel) {
                var nodeConnections = nodeModel.connections;
                if (nodeConnections) {
                    for (var i = 0; i < nodeConnections.count; i++) {
                        var connection = nodeConnections.get(i);
                        if (connection) {
                            var fromComponent = findConnectorRow(connection.fromNodeId, connection.fromPortId);
                            var toComponent = findConnectorRow(connection.toNodeId, connection.toPortId);
                            if (fromComponent && toComponent) {
                                addConnectionComponent(fromComponent, toComponent, connection.removable);
                            }
                        }
                    }
                }
            }
        }
    }

    function updateAllConnectionComponentsByNodeId(nodeId) {
        var model = nodeView.model;
        removeAllConnectionComponentsByNodeId(nodeId);
        for(var nodeIndex = 0; nodeIndex < model.count; nodeIndex++) {
            var nodeModel = model.get(nodeIndex);
            if (nodeModel && nodeModel.nodeId === nodeId) {
                var nodeConnections = nodeModel.connections;
                if (nodeConnections) {
                    for (var i = 0; i < nodeConnections.count; i++) {
                        var connection = nodeConnections.get(i);
                        if (connection) {
                            var fromComponent = findConnectorRow(connection.fromNodeId, connection.fromPortId);
                            var toComponent = findConnectorRow(connection.toNodeId, connection.toPortId);
                            if (fromComponent && toComponent) {
                                addConnectionComponent(fromComponent, toComponent, connection.removable);
                            }
                        }
                    }
                }
            }
        }
    }

    function addConnectionComponent(from, to, removable) {
        var connection = {to: to, from: from, connectionShape: connectionShape, style: nodeView.style, removable: removable || false};
        connectionsModel.append(connectionComponent.createObject(from, connection));
    }

    function removeAllConnectionComponents() {
        for (var connectionIndex = 0; connectionIndex < connectionsModel.count;) {
            var connectionComponent = connectionsModel.get(connectionIndex);
            if (connectionComponent) {
                connectionsModel.remove(connectionIndex);
                connectionComponent.destroy();
            }
        }
    }

    function removeAllConnectionComponentsByNodeId(nodeId) {
        for (var connectionIndex = 0; connectionIndex < connectionsModel.count;) {
            var connectionComponent = connectionsModel.get(connectionIndex);
            if (connectionComponent && (connectionComponent.from.nodeId === nodeId || connectionComponent.to.nodeId === nodeId)) {
                connectionsModel.remove(connectionIndex);
                connectionComponent.destroy();
            } else {
                connectionIndex++;
            }
        }
    }

    function removeConnectionComponent(from, to) {
        for (var connectionIndex = 0; connectionIndex < connectionsModel.count; connectionIndex++) {
            var connectionComponent = connectionsModel.get(connectionIndex);
            if (connectionComponent && connectionComponent.from === from && connectionComponent.to === to) {
                connectionsModel.remove(connectionIndex);
                connectionComponent.destroy();
                console.debug("Connection destroyed");
                return true;
            }
        }
        console.warn("Connection not found!");
        return false;
    }

    function setPortsState(state, filter) {
        for(var nodeIndex = 0; nodeIndex < nodesRepeater.count; nodeIndex++) {
            var nodeElement = nodesRepeater.itemAt(nodeIndex);
            if (nodeElement) {
                var leftPortDockRepeater = nodeElement.leftPortDockRepeater;
                if (leftPortDockRepeater) {
                    for(var leftPortIndex = 0; leftPortIndex < leftPortDockRepeater.count; leftPortIndex++) {
                        var leftPortElement = leftPortDockRepeater.itemAt(leftPortIndex);
                        if (leftPortElement && checkFilterOnTags(leftPortElement.tags, filter)) {
                            leftPortElement.state = state;
                        }
                    }
                }
                var rightPortDockRepeater = nodeElement.rightPortDockRepeater
                if (leftPortDockRepeater) {
                    for(var rightPortIndex = 0; rightPortIndex < rightPortDockRepeater.count; rightPortIndex++) {
                        var rightPortElement = rightPortDockRepeater.itemAt(rightPortIndex);
                        if (rightPortElement && checkFilterOnTags(rightPortElement.tags, filter)) {
                            rightPortElement.state = state;
                        }
                    }
                }
            }
        }
    }

    function checkFilterOnTags(tags, filter) {
        if (!filter) {
            return true;
        } else if (!tags) {
            return false;
        }

        var tagsList = tags.split(",");
        for (var tagIndex = 0; tagIndex < tagsList.length; tagIndex++) {
            var filterList = filter.split(",");
            var tagValue = tagsList[tagIndex].trim();
            for (var filterIndex = 0; filterIndex < filterList.length; filterIndex++) {
                var filterValue = filterList[filterIndex].trim();
                if (tagValue === filterValue) {
                    return true;
                }
            }
        }
        return false;
    }
}
