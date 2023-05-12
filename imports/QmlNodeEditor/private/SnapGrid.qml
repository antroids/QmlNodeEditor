import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15

Item {
    id: snapGrid
    anchors.fill: parent
    property int cellSize: 20
    property int snapDistance: 5

    property int rows: height / cellSize
    property int columns: width / cellSize

    function snapPosition(point) {
        var snappedX = Math.round(point.x / snapGrid.cellSize) * snapGrid.cellSize;
        var snappedY = Math.round(point.y / snapGrid.cellSize) * snapGrid.cellSize;

        return Qt.point(
                    Math.abs(point.x - snappedX) > snapGrid.snapDistance ? point.x : snappedX,
                    Math.abs(point.y - snappedY) > snapGrid.snapDistance ? point.y : snappedY);
    }

    function snapX(x) {
        var snapped = Math.round(x / snapGrid.cellSize) * snapGrid.cellSize;
        return Math.abs(x - snapped) > snapGrid.snapDistance ? x : snapped;
    }

    function snapY(y) {
        var snapped = Math.round(y / snapGrid.cellSize) * snapGrid.cellSize;
        return Math.abs(y - snapped) > snapGrid.snapDistance ? y : snapped;
    }

    Repeater {
        model: snapGrid.rows
        Shape {
            ShapePath {
                startX: 0
                startY: snapGrid.cellSize * index
                strokeColor: "#eeeeee"
                PathLine {
                    x: snapGrid.width
                    y: snapGrid.cellSize * index
                }
            }
        }
    }

    Repeater {
        model: snapGrid.columns
        Shape {
            ShapePath {
                startX: snapGrid.cellSize * index
                startY: 0
                strokeColor: "#eeeeee"
                PathLine {
                    x: snapGrid.cellSize * index
                    y: snapGrid.width
                }
            }
        }
    }
}
