import QtQuick 2.15
import QtQuick.Controls 2.15

//Rectangle {
//    border.color: style.nodeHeaderBorderColor
//    color: style.nodeHeaderBackgroundColor
//    gradient: style.nodeHeaderBackgroundGradient
//    height: 20
//    Label {
//        text: nodeModel.name
//        anchors.fill: parent
//        horizontalAlignment: Text.AlignHCenter
//    }
//}


Item {
    height: style.nodeHeaderHeight
    Rectangle {
        radius: style.nodeBorderRadius
        color: style.nodeHeaderBackgroundColor
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: style.nodeBorderRadius
            color: style.nodeHeaderBackgroundColor
            gradient: style.nodeHeaderBackgroundGradient
        }

        Label {
            elide: Text.ElideRight
            text: nodeModel.name
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
