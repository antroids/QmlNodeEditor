import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: nodePortConnector

    width: style.nodePortConnectorWidth
    height: style.nodePortConnectorWidth
    radius: style.nodePortConnectorWidth
    color: style.nodePortConnectorColor

    border.color: style.nodePortConnectorBorderColor
    border.width: style.nodePortConnectorBorderWidth

    state: parent.state

    states: [
        State {
            name: "hovered"
            PropertyChanges {
                target: nodePortConnector
                width: style.nodePortConnectorHoverWidth
                height: style.nodePortConnectorHoverWidth
                radius: style.nodePortConnectorHoverWidth
                color: style.nodePortConnectorHoverColor
            }
        },
        State {
            name: "highlighted"
            PropertyChanges {
                target: nodePortConnector
                color: style.nodePortConnectorHighlightColor
                width: style.nodePortConnectorHighlightWidth
                height: style.nodePortConnectorHighlightWidth
                radius: style.nodePortConnectorHighlightWidth
            }
        }
    ]
}
