import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: nodeRoot

    property var nodeModel: model

    property bool active: nodeModel
    property int nodeId: nodeModel.nodeId
    property bool removable: nodeModel.removable || false
    x: nodeModel.x
    y: nodeModel.y

    property alias leftPortDockRepeater: nodeLeftPortDock.repeater
    property alias rightPortDockRepeater: nodeRightPortDock.repeater

    function updateHeight() {
        height = nodeHeaderLoader.height
                + nodeView.style.nodeBorderWidth * 2
                + nodeTopContentLoader.height
                + Math.max(
                    nodeCenterLoader.height,
                    nodeLeftPortDock.height,
                    nodeRightPortDock.height);
    }

    Loader {
        id: nodeDeleteConfirmationDialogLoader
        active: nodeRoot.active
        property var nodeModel: nodeRoot.nodeModel
        sourceComponent: nodeView.nodeDeleteConfirmationDialog
    }
    Connections {
        target: nodeDeleteConfirmationDialogLoader.item
        function onAccepted() {
            nodeDeleteConfirmationDialogLoader.active = false;
            nodeView.nodeRemoved(nodeRoot.nodeModel.nodeId);
        }
    }
    function showNodeDeleteDialog() {
        nodeDeleteConfirmationDialogLoader.item.open();
    }

    Rectangle {
        id: nodeRootRectangle
        anchors.fill: parent
        border.color: nodeView.style.nodeBorderColor
        border.width: nodeView.style.nodeBorderWidth
        color: nodeView.style.nodeBackgroundColor
        gradient: nodeView.style.nodeBackgroundGradient
        radius: nodeView.style.nodeBorderRadius
        focus: true
        activeFocusOnTab: true
        clip: false

        states: [
            State {
                name: "focus"
                when: nodeRootRectangle.activeFocus
                PropertyChanges {
                    target: nodeRootRectangle
                    border.color: nodeView.style.nodeBorderFocusColor
                }
            },
            State {
                name: "hover"
                when: nodeRootRectangleHover.hovered
                PropertyChanges {
                    target: nodeRootRectangle
                    border.color: nodeView.style.nodeBorderHoverColor
                }
            }
        ]

        Keys.onPressed: (event) => {
                            if (nodeRoot.removable && event.key === nodeView.deleteKey) {
                                showNodeDeleteDialog();
                                event.accepted = true;
                            }
                        }

        HoverHandler {
            id: nodeRootRectangleHover
        }

        TapHandler {
            acceptedButtons: Qt.LeftButton
            onTapped: nodeRootRectangle.forceActiveFocus();
        }

        Column {
            id: nodeRootColumn
            anchors.top: parent.top
            anchors.topMargin: nodeRootRectangle.border.width
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width

            Loader {
                id: nodeHeaderLoader
                active: nodeRoot.active
                property alias nodeModel: nodeRoot.nodeModel
                property QtObject style: nodeView.style
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: nodeRootRectangle.border.width
                anchors.rightMargin: nodeRootRectangle.border.width

                sourceComponent: nodeView.nodeHeaderComponent
                onHeightChanged: nodeRoot.updateHeight()

                MouseArea {
                    id: nodeHeaderMouseArea
                    anchors.fill: parent
                    cursorShape: Qt.DragMoveCursor
                    acceptedButtons: Qt.LeftButton
                    drag.target: nodeRoot
                    drag.smoothed: false
                    drag.minimumX: 0
                    drag.maximumX: nodeView.width - nodeRoot.width;
                    drag.minimumY: 0
                    drag.maximumY: nodeView.height - nodeRoot.height;
                    onPressed: nodeRootRectangle.forceActiveFocus();

                    onReleased: {
                        if (drag.active) {
                            nodeRoot.nodeModel.x = nodeRoot.x;
                            nodeRoot.nodeModel.y = nodeRoot.y;
                            nodeRoot.x = Qt.binding(function() {  return nodeRoot.nodeModel.x; });
                            nodeRoot.y = Qt.binding(function() {  return nodeRoot.nodeModel.y; });
                            nodeView.nodePositionChanged(nodeRoot.nodeModel.nodeId, nodeRoot.x, nodeRoot.y);
                        }
                    }

                    onPositionChanged: (event) => {
                                           var snapPosition = snapGrid.snapPosition(Qt.point(drag.target.x, drag.target.y));
                                           drag.target.x = snapPosition.x;
                                           drag.target.y = snapPosition.y;
                                       }
                }
            }

            Loader {
                id: nodeTopContentLoader
                active: nodeRoot.active
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: nodeRootRectangle.border.width
                anchors.rightMargin: nodeRootRectangle.border.width
                property alias nodeModel: nodeRoot.nodeModel
                property QtObject style: nodeView.style
                sourceComponent: nodeView.nodeTopContentComponent
                onHeightChanged: nodeRoot.updateHeight()
            }

            Row {
                id: nodeContentRow
                anchors.left: parent.left
                anchors.leftMargin: -nodeView.style.nodePortConnectorMargin

                width: nodeCenterLoader.width + nodeLeftPortDock.width + nodeRightPortDock.width

                property real relativeX: nodeRootRectangle.x + nodeRootColumn.x + nodeContentRow.x
                property real relativeY: nodeRootRectangle.y + nodeRootColumn.y + nodeContentRow.y

                PortsDock {
                    id: nodeLeftPortDock
                    nodePortComponent: nodeView.nodeLeftPortComponent
                    relativeX: parent.relativeX + x
                    relativeY: parent.relativeY + y
                    model: nodeRoot.nodeModel.leftPorts
                    onHeightChanged: nodeRoot.updateHeight()
                }

                Loader {
                    id: nodeCenterLoader
                    active: nodeRoot.active
                    property alias nodeModel: nodeRoot.nodeModel
                    property QtObject style: nodeView.style
                    sourceComponent: nodeView.nodeCenterContentComponent
                    onHeightChanged: nodeRoot.updateHeight()
                    onWidthChanged: nodeRoot.width = width
                                    + nodeView.style.leftPortDockWidth
                                    + nodeView.style.rightPortDockWidth
                }

                PortsDock {
                    id: nodeRightPortDock
                    nodePortComponent: nodeView.nodeRightPortComponent
                    layoutDirection: Qt.RightToLeft
                    model: nodeRoot.nodeModel.rightPorts
                    onHeightChanged: nodeRoot.updateHeight()
                }
            }
        }

        Repeater {
            model: nodeRoot.nodeModel.connections
            onItemAdded: (index, item) => {
                             var fromComponent = findConnectorRow(item.fromNodeId, item.fromPortId);
                             var toComponent = findConnectorRow(item.toNodeId, item.toPortId);
                             if (fromComponent && toComponent) {
                                 addConnectionComponent(fromComponent, toComponent);
                             }
                         }
            onItemRemoved: (index, item) => {
                               var fromComponent = findConnectorRow(item.fromNodeId, item.fromPortId);
                               var toComponent = findConnectorRow(item.toNodeId, item.toPortId);
                               if (fromComponent && toComponent) {
                                   removeConnectionComponent(fromComponent, toComponent);
                               } else {
                                   console.warn("Cannot found connection source or destination port " + item);
                               }
                           }

            delegate: Item {
                property var connectionModel: model.fromNodeId ? model : modelData

                property int fromNodeId: connectionModel.fromNodeId
                property int fromPortId: connectionModel.fromPortId
                property int toNodeId: connectionModel.toNodeId
                property int toPortId: connectionModel.toPortId
            }
        }
    }
}
