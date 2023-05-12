import QtQuick 2.15
import QtQuick.Controls 2.15

QtObject {
    property color borderColor: "black"
    property color borderHoverColor: "#555555"
    property color borderFocusColor: "orange"
    property color backgroundColor: "#cccccc"

    property color nodeBorderColor: borderColor
    property color nodeBorderHoverColor: borderHoverColor
    property color nodeBorderFocusColor: borderFocusColor
    property real nodeBorderWidth: 2
    property real nodeBorderRadius: 10

    property color nodeBackgroundColor: "transparent"
    property var nodeBackgroundGradient: "PremiumWhite"

    property int nodeHeaderHeight: 20
    property color nodeHeaderBackgroundColor: "lightgray"

    property real leftPortDockWidth: 100
    property real rightPortDockWidth: 100

    property color nodePortConnectorColor: "gray"
    property color nodePortConnectorHoverColor: borderHoverColor
    property color nodePortConnectorHighlightColor: "green"
    property real nodePortConnectorWidth: 10
    property real nodePortConnectorHoverWidth: 15
    property real nodePortConnectorHighlightWidth: 15
    property real nodePortConnectorMargin: 3
    property color nodePortConnectorBorderColor: borderColor
    property int nodePortConnectorBorderWidth: 1

    property color connectionStrokeColor: borderColor
    property color connectionStrokeHoverColor: borderHoverColor
    property color connectionStrokeFocusColor: borderFocusColor
    property real connectionStrokeWidth: 2
    property real connectionStrokeHoverWidth: 3
    property real connectionStrokeFocusWidth: 3
    property real connectionControlPointDistance: 100
    property real connectionPointerSize: 5
}
