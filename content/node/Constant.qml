import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    width: 200
    height: 200

    Label {
        id: constantLabel
        text: "Constant Label"
        anchors.top: parent.top
    }

    ComboBox {
        id: valueTypeCombobox
        anchors.top: constantLabel.bottom
        textRole: "label"
        valueRole: "type"

        model: ListModel {
            ListElement { type: "Integer"; label: "Integer Value" }
            ListElement { type: "String"; label: "String Value" }
            ListElement { type: "Double"; label: "Double Value" }
        }
    }

    function getValueEditor(type) {
        if (type) {
            switch(type) {
            case "Integer":
                return integerValueEditor;
            case "Double":
                return doubleValueEditor;
            default:
                return stringValueEditor;
            }
        } else {
            return null;
        }
    }

    Rectangle {
        color: "white"
        border.color: "black";
        anchors.top: valueTypeCombobox.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 25

        Loader {
            anchors.fill: parent

            sourceComponent: getValueEditor(valueTypeCombobox.currentValue);
        }
    }

    Component {
        id: integerValueEditor

        TextInput {
            id: valueEditor
            text: nodeModel.value
            validator: IntValidator {}
            anchors.fill: parent

            onEditingFinished: () => { nodeModel.value = text; }
        }
    }

    Component {
        id: doubleValueEditor

        TextInput {
            id: valueEditor
            text: nodeModel.value
            validator: DoubleValidator {}
            anchors.fill: parent

            onEditingFinished: () => { nodeModel.value = text; }
        }
    }

    Component {
        id: stringValueEditor

        TextInput {
            id: valueEditor
            text: nodeModel.value
            validator: RegularExpressionValidator {}
            anchors.fill: parent

            onEditingFinished: () => { nodeModel.value = text; }
        }
    }
}
