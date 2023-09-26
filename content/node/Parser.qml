import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    width: 200
    height: 200

    Label {
        id: producerLabel
        text: "Parser Label"
    }

    TextArea {
        anchors.top: producerLabel.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        background: Rectangle {
            color: "white"
            border.color: "black"
        }

        text: nodeModel.value

        onEditingFinished: () => { nodeModel.value = text; }
    }
}
