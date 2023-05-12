import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15

Item {
    id: connectionShape

    anchors.fill: parent
    property real startX: parent.startX
    property real startY: parent.startY
    property real endX: parent.endX
    property real endY: parent.endY
    property real mouseAreaWidth: style.connectionStrokeWidth
    property string state: parent.state
    property QtObject style: parent.style

    property point fromPortPosition: parent.fromPortPosition
    property point toPortPosition: parent.toPortPosition

    containmentMask: shape

    Shape {
        id: shape

        property real controlPoint1Distance: connectionShape.fromPortPosition.x * style.connectionControlPointDistance
        property real controlPoint2Distance: connectionShape.toPortPosition.x * style.connectionControlPointDistance

        property real normalizedPointerSize: toPortPosition.x * style.connectionPointerSize

        property int relativeVerticalPosition: connectionShape.startY < connectionShape.endY ? 1 : -1

        anchors.fill: parent
        containsMode: Shape.FillContains
        state: connectionShape.state

        states: [
            State {
                name: "focused"
                PropertyChanges {
                    target: connectionPath
                    strokeColor: style.connectionStrokeFocusColor
                    strokeWidth: style.connectionStrokeFocusWidth
                }
            },
            State {
                name: "hovered"
                PropertyChanges {
                    target: connectionPath
                    strokeColor: style.connectionStrokeHoverColor
                    strokeWidth: style.connectionStrokeHoverWidth
                }
            }
        ]

        ShapePath {
            id: connectionMouseArea

            property real mouseAreaShift: shape.relativeVerticalPosition * connectionShape.mouseAreaWidth

            strokeWidth: 1
            strokeColor: "transparent"
            fillColor: "transparent"

            startX: connectionShape.startX
            startY: connectionShape.startY

            PathLine {
                x: connectionShape.startX - connectionMouseArea.mouseAreaShift
                y: connectionShape.startY - connectionShape.mouseAreaWidth
            }
            PathCubic {
                x: connectionShape.endX - connectionMouseArea.mouseAreaShift
                y: connectionShape.endY - connectionShape.mouseAreaWidth * connectionShape.toPortPosition.x
                relativeControl1X: shape.controlPoint1Distance
                control2X: x + shape.controlPoint2Distance
                relativeControl1Y: 0
                control2Y: y
            }
            PathLine {
                x: connectionShape.endX + connectionMouseArea.mouseAreaShift
                y: connectionShape.endY + connectionShape.mouseAreaWidth * connectionShape.toPortPosition.x
            }
            PathCubic {
                x: connectionShape.startX + connectionMouseArea.mouseAreaShift
                y: connectionShape.startY + connectionShape.mouseAreaWidth
                relativeControl1Y: 0
                relativeControl1X: shape.controlPoint2Distance
                control2Y: y
                control2X: x + shape.controlPoint1Distance
            }
            PathLine {
                x: connectionShape.startX
                y: connectionShape.startY
            }
        }

        ShapePath {
            id: connectionPath

            strokeWidth: style.connectionStrokeWidth
            strokeColor: style.connectionStrokeColor
            fillColor: "transparent"

            startX: connectionShape.startX
            startY: connectionShape.startY

            PathCubic {
                x: connectionShape.endX
                y: connectionShape.endY
                relativeControl1X: shape.controlPoint1Distance
                control2X: x + shape.controlPoint2Distance
                relativeControl1Y: 0
                control2Y: y
            }
            PathLine {
                relativeX: shape.normalizedPointerSize
                relativeY: style.connectionPointerSize
            }
            PathLine {
                relativeX: -shape.normalizedPointerSize
                relativeY: -style.connectionPointerSize
            }
            PathLine {
                relativeX: shape.normalizedPointerSize
                relativeY: -style.connectionPointerSize
            }
            PathLine {
                x: connectionShape.endX
                y: connectionShape.endY
            }
            PathCubic {
                x: connectionShape.startX
                y: connectionShape.startY
                relativeControl1Y: 0
                relativeControl1X: shape.controlPoint2Distance
                control2Y: y
                control2X: x + shape.controlPoint1Distance
            }
        }
    }
}
