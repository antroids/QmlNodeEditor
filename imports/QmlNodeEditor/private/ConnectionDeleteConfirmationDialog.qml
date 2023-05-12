import QtQuick 2.15
import QtQuick.Controls 2.15

Dialog {
    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    modal: true
    focus: true
    title: "Do you really want to remove connection from node " + from.nodeId + " port " + from.portId + " to node " + to.nodeId + " port " + to.portId + "?"
    standardButtons: Dialog.Ok | Dialog.Cancel
}
