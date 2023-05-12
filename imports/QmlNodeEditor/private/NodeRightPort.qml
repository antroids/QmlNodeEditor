import QtQuick 2.15
import QtQuick.Controls 2.15

Label {
    elide: Text.ElideRight
    text: portModel.name
    horizontalAlignment: Text.AlignRight
    rightPadding: 5
}
