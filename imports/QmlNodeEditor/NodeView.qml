import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15
import QtQml.Models

import QmlNodeEditor 1.0
import "private" as Private

/**
* The base view that manages and showing Nodes. The only required property is NodeView.model.
* 
* Node layout:
* 
*       _______________________________________________________
*       |            NodeView.nodeHeaderComponent             |
*       |-----------------------------------------------------|
*       |          NodeView.nodeTopContentComponent           |
*       |                                                     |
*       |-----------------------------------------------------|
*     o | left  |                                     | right | o <- NodeView.nodePortConnectorComponent
*     o | ports | NodeView.nodeCenterContentComponent | ports | o
*     o | dock  |                                     | dock  | o
*       |     ^ |                                     |       |
*       ------|------------------------------------------------
*           NodeView.nodeLeftPortComponent
* 
* Node.width = NodeView.nodeCenterContentComponent.width + NodeView.style.leftPortDockWidth + NodeView.style.rightPortDockWidth
*
* Node.height = NodeView.nodeHeaderComponent.height + NodeView.nodeTopContentComponent.height + max(left ports dock, NodeView.nodeCenterContentComponent, right ports dock)
* 
* 
*/
Item {
    id: nodeView

    /**
    * type:var Any row-based model should be supported, 
    * tested with a ListModel and a custom implementation of QAbstractListModel.
    * The following roles are used by the NodeView in the model:
    *   - Node 1:
    *       + **nodeId**: int Required. Used to identify the Node
    *       + **x**: int Required. Horizontal Node position relative to the NodeView
    *       + **y**: int Required. Vertical Node position relative to the NodeView
    *       + **removable**: bool. Whether this Node can be removed.
    *       + **leftPorts**: [map<string, var>] or [ListElement] Required. Connection Ports that will be displayed at the left side
    *           - **portId**: int Required. Used to identify the Port in the Node, must be unique for the Node
    *           - **filter**: string. Comma separated string with the Tags. If specified, the Port can be connected with the another 
    * Port only when any Tag from the filter property matches with any tag from the tags property of the another port. 
    *           - **tags**: string. Comma separated string with the Tags, see filter.
    *       + **rightPorts**: [map<string, var>] or [ListElement] Required. Connection Ports that will be displayed at the right side.
    *           - ...see leftPorts
    *       + **connections**: [map<string, var>] or [ListElement] Required. The list of connections between Ports.
    *           - **fromNodeId**: int Required. Connection from Node with nodeId.
    *           - **fromPortId**: int Required. Connection from Port width portId.
    *           - **toNodeId**: int Required. Connection to Node with nodeId.
    *           - **toPortId**: int Required. Connection to Port with portId.
    *           - **removable**: bool. Whether this Connection can be removed.
    *
    * Example model:
    * ~~~~~~~~~~~~~~~~~~~~~
    * ListModel {
    *     ListElement {
    *         nodeId: 1
    *         name: "Node 1"
    *         x: 100
    *         y: 100
    *         leftPorts: [
    *             ListElement {
    *                 portId: 1
    *                 name: "Port 1"
    *                 filter: "output"
    *                 tags: "input"
    *             },
    *             ListElement {
    *                 portId: 2
    *                 name: "Port 2"
    *                 filter: "output"
    *                 tags: "input"
    *             }
    *         ]
    *         rightPorts: [
    *             ListElement {
    *                 portId: 3
    *                 name: "Port 3"
    *             },
    *             ListElement {
    *                 portId: 4
    *                 name: "Port 4"
    *             }
    *         ]
    *         connections: []
    *     }
    *     ListElement {
    *         nodeId: 2
    *         x: 300
    *         y: 200
    *         name: "Node 2"
    *         removable: true
    *         leftPorts: [
    *             ListElement {
    *                 portId: 1
    *                 name: "Port 1"
    *             },
    *             ListElement {
    *                 portId: 2
    *                 name: "Port 2"
    *             }
    *         ]
    *         rightPorts: [
    *             ListElement {
    *                 portId: 3
    *                 name: "Port 3"
    *                 filter: "input"
    *                 tags: "output"
    *             }
    *         ]
    *         connections: [
    *             ListElement {
    *                 fromNodeId: 2
    *                 fromPortId: 1
    *                 toNodeId: 1
    *                 toPortId: 2
    *             },
    *             ListElement {
    *                 fromNodeId: 2
    *                 fromPortId: 1
    *                 toNodeId: 1
    *                 toPortId: 1
    *                 removable: true
    *             }
    *         ]
    *     }
    * }
    * ~~~~~~~~~~~~~~~~~~~~~
    */
    required property var model

    /**
     * Key that can be used to show Node or Connection Delete dialog on selected Node or Connection. Default Qt.Key_Delete.
     */
    property int deleteKey: Qt.Key_Delete

    /**
    * Style object, see NodeViewStyle
    */
    property QtObject style: NodeViewStyle {}

    /**
    * The Shape that renders Connection, see ConnectionShape.
    * Following properties can be bound to the parent component:
    * ~~~~~~~~~~~~~~~~~~
    * property real startX: parent.startX
    * property real startY: parent.startY
    * property real endX: parent.endX
    * property real endY: parent.endY
    * property string state: parent.state // "focused", "hovered"
    * property QtObject style: parent.style
    * 
    * property point fromPortPosition: parent.fromPortPosition // From Port side on the Node, fromPortPosition.x === -1 if port is on the left side, 1 on the right
    * property point toPortPosition: parent.toPortPosition // To Port side on the Node, toPortPosition.x === -1 if port is on the left side, 1 on the right
    * ~~~~~~~~~~~~~~~~~~
    */
    property Component connectionShape: Private.ConnectionShape {}

    /**
    * Underlaying component that manages the connectionShape position, state and events.
    *
    * Default: ConnectionComponent.
    */
    property Component connectionComponent: Private.ConnectionComponent {}

    /**
    * type:Dialog Node deletion comfirmation dialog. 
    *
    * Default: NodeDeleteConfirmationDialog.
    *
    * `var nodeModel` is available in the scope.
    */
    property Component nodeDeleteConfirmationDialog: Private.NodeDeleteConfirmationDialog {}

    /**
    * type:Dialog Connection deletion comfirmation dialog. 
    * 
    * Default: ConnectionDeleteConfirmationDialog.
    * 
    * `PortsDockRow from` and `PortsDockRow to` are available in the scope.
    */
    property Component connectionDeleteConfirmationDialog: Private.ConnectionDeleteConfirmationDialog {}

    /**
    * Renders the Node header. 
    * Component height must be defined, because it's used to calculate Node height.
    * 
    * Default: NodeHeader.
    *
    * `var nodeModel` is available in the scope.
    */
    property Component nodeHeaderComponent: Private.NodeHeader {}

    /**
    * Renders top content area in the Node.
    * Component height must be defined, because it's used to calculate Node height.
    *
    * Default: NodeTopContent.
    *
    * `var nodeModel` is available in the scope.
    */
    property Component nodeTopContentComponent: Private.NodeTopContent {}

    /**
    * Renders center content area in the Node, between left and right PortsDock.
    * Component height must be defined, because it's used to calculate Node height.
    *
    * Default: NodeCenterContent.
    *
    * `var nodeModel` is available in the scope.
    */
    property Component nodeCenterContentComponent: Private.NodeCenterContent {}

    /**
    * Renders left port description.
    *
    * Default: NodeLeftPort
    *
    * The following properties are available in the scope:
    * - `var portModel`
    * - `var nodeModel`
    * - `string state` // "highlighted", "hovered"
    * - `QtObject style`
    */
    property Component nodeLeftPortComponent: Private.NodeLeftPort {}

    /**
    * Renders right port description.
    *
    * Default: NodeRightPort
    *
    * The following properties are available in the scope:
    * - `var portModel`
    * - `var nodeModel`
    * - `string state` // "highlighted", "hovered"
    * - `QtObject style`
    */
    property Component nodeRightPortComponent: Private.NodeRightPort {}

    /**
    * Renders connection point near the PortsDockRow
    *
    * Default: NodePortConnector
    *
    * The following properties are available in the scope:
    * - `var portModel`
    * - `var nodeModel`
    * - `string state` // "highlighted", "hovered"
    * - `QtObject style`
    */
    property Component nodePortConnectorComponent: Private.NodePortConnector {}

    /**
    * Underlaying component that manages the NodePortConnector events.
    *
    * Default: NodePortConnectorMouseArea
    */
    property Component nodePortConnectorMouseArea: Private.NodePortConnectorMouseArea {}

    /**
    * The SnapGrid component.
    *
    * Default: SnapGrid
    *
    * An implementation should provide function `function snapPosition(point) => point`
    */
    property Component snapGridComponent: Private.SnapGrid {}

    /**
    * The underlaying model with the list of ConnectionComponent items.
    */
    property ObjectModel connectionsModel: ObjectModel {}

    /**
    * Connection between two ports added. 
    * @note connections list in the NodeView.model will not be updated by the NodeView, it should be updated explicitly.
    * @param fromNodeId connection added from Node id
    * @param fromPortId connection added from Port id
    * @param toNodeId connection added to Node id
    * @param toPortId connection added to Port id
    */
    signal connectionAdded(int fromNodeId, int fromPortId, int toNodeId, int toPortId)

    /**
    * Connection between two ports removed. 
    * @note connections list in the NodeView.model will not be updated by the NodeView, it should be updated explicitly.
    * @param fromNodeId connection removed from Node id
    * @param fromPortId connection removed from Port id
    * @param toNodeId connection removed to Node id
    * @param toPortId connection removed to Port id
    */
    signal connectionRemoved(int fromNodeId, int fromPortId, int toNodeId, int toPortId)

    /**
    * Node removed
    * @note NodeView.model will not be updated by the NodeView, it should be updated explicitly.
    * 
    * @param nodeId removed Node id
    */
    signal nodeRemoved(int nodeId)

    /**
    * Node position changed.
    * @note model will be updated by the NodeView
    *
    * @param nodeId removed Node id
    * @param x x coordinate relative to NodeView
    * @param y y coordinate relative to NodeView
    */
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

    /**
    * Find the PortsDockRow by Node id and Port id.
    * 
    * @param type:int nodeId Node id
    * @param type:int portId Port id
    * @return type:PortsDockRow PortsDockRow or undefined
    */
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

    /**
    * Clear NodeView.connectionsModel and recreate them from NodeView.model.
    */
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

    /**
    * Remove connections from and to specified Node from NodeView.connectionsModel and recreate them from NodeView.model.
    * @param type:int nodeId Node id
    */
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

    /**
    * Create ConnectionComponent and add it to the NodeView.connectionsModel
    * @param type:ConnectionComponent from Connection from
    * @param type:ConnectionComponent to Connection to
    * @param type:bool removable Is connection removable
    */
    function addConnectionComponent(from, to, removable) {
        var connection = {to: to, from: from, connectionShape: connectionShape, style: nodeView.style, removable: removable || false};
        connectionsModel.append(connectionComponent.createObject(from, connection));
    }

    /**
    * Remove all ConnectionComponent from NodeView.connectionsModel and destroy them.
    */
    function removeAllConnectionComponents() {
        for (var connectionIndex = 0; connectionIndex < connectionsModel.count;) {
            var connectionComponent = connectionsModel.get(connectionIndex);
            if (connectionComponent) {
                connectionsModel.remove(connectionIndex);
                connectionComponent.destroy();
            }
        }
    }

    /**
    * Remove ConnectionComponent from or to specified Node from NodeView.connectionsModel and destroy them.
    * @param type:int nodeId Node id
    */
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

    /**
    * Remove ConnectionComponent from NodeView.connectionsModel and destroy it.
    * @param type:ConnectionComponent from
    * @param type:ConnectionComponent to
    * @return type:bool true if first found connection was removed
    */
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

    /**
    * Set the state of PortsDockRow
    * @param type:string state PortsDockRow.state, see PortsDockRow.states
    * @param type:string filter Set the state to the filtered PortsDockRow, use undefined to apply state for all PortsDockRow.
    */
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

    /**
    * Check the filter on the given tags
    * @param type:string tags Tags to check. If tags are not defined, then only undefined filter will match them.
    * @param type:string filter Filter string to check. Undefined filter always match.
    * @return type:bool Match or not.
    */
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
