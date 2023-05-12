import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: connectionComponent
    anchors.fill: parent

    required property Item from
    required property Item to
    required property Component connectionShape
    required property QtObject style
    required property bool removable

    property Item fromNodeRoot
    property Item toNodeRoot

    Loader {
        id: connectionShapeLoader
        anchors.fill: parent

        property real startX: 0
        property real startY: 0
        property real endX: 0
        property real endY: 0
        property QtObject style: parent.style
        property string state: parent.state

        property point fromPortPosition
        property point toPortPosition

        sourceComponent: connectionShape

        Binding on fromPortPosition {
            value: if (from) from.relativeConnectorX < 0 ? "-1, 0" : "1, 0"
            when: from
        }

        Binding on toPortPosition {
            value: if (to) to.relativeConnectorX < 0 ? "-1, 0" : "1, 0"
            when: to
        }
    }

    Binding on fromNodeRoot {
        value: if (from) from.getNodeRoot()
        when: from
    }

    Binding on toNodeRoot {
        value: if (to) to.getNodeRoot()
        when: to
    }

    containmentMask: connectionShapeLoader.item
    focus: true
    activeFocusOnTab: true

    states: [
        State {
            when: activeFocus
            name: "focused"
        },
        State {
            when: hover.hovered
            name: "hovered"
        }
    ]

    HoverHandler {
        id: hover
        enabled: connectionComponent.state !== "focused"
    }

    TapHandler {
        enabled: connectionComponent.state !== "focused"
        acceptedButtons: Qt.LeftButton
        onTapped: forceActiveFocus();
    }

    Keys.onPressed: (event) => {
        if (connectionComponent.removable && event.key === nodeView.deleteKey) {
            showConnectionDeleteDialog();
            event.accepted = true;
        }
    }

    Loader {
        id: connectionDeleteConfirmationDialogLoader
        property alias from: connectionComponent.from
        property alias to: connectionComponent.to
        sourceComponent: nodeView.connectionDeleteConfirmationDialog
    }
    Connections {
        target: connectionDeleteConfirmationDialogLoader.item
        function onAccepted() {
            connectionDeleteConfirmationDialogLoader.active = false;
            nodeView.connectionRemoved(connectionComponent.from.nodeId, connectionComponent.from.portId,
                                        connectionComponent.to.nodeId, connectionComponent.to.portId);
        }
    }
    function showConnectionDeleteDialog() {
        connectionDeleteConfirmationDialogLoader.item.open();
    }

    function updateFromX() {
        connectionShapeLoader.startX = fromNodeRoot.x + from.relativeConnectorX;
    }
    function updateFromY() {
        connectionShapeLoader.startY = fromNodeRoot.y + from.relativeConnectorY;
    }
    function updateToX() {
        connectionShapeLoader.endX = toNodeRoot.x + to.relativeConnectorX;
    }
    function updateToY() {
        connectionShapeLoader.endY = toNodeRoot.y + to.relativeConnectorY;
    }
    function updateAll() {
        updateFromX();
        updateFromY();
        updateToX();
        updateToY();
    }

    Connections {
        target: fromNodeRoot

        function onXChanged() {
            updateFromX();
        }

        function onYChanged() {
            updateFromY();
        }
    }

    Connections {
        target: toNodeRoot

        function onXChanged() {
            updateToX();
        }

        function onYChanged() {
            updateToY();
        }
    }

    Connections {
        target: from

        function onRelativeConnectorXChanged() {
            updateFromX();
        }

        function onRelativeConnectorYChanged() {
            updateFromY();
        }
    }

    Connections {
        target: to

        function onRelativeConnectorXChanged() {
            updateToX();
        }

        function onRelativeConnectorYChanged() {
            updateToY();
        }
    }

    Component.onCompleted: {
        updateAll();
    }
}
