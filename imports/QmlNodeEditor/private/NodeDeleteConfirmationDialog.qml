import QtQuick 2.15
import QtQuick.Controls 2.15

Dialog {
    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    modal: true
    focus: true
    title: "Do you really want to remove node " + nodeModel.nodeId + "?"
    standardButtons: Dialog.Ok | Dialog.Cancel
}
