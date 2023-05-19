# QmlNodeEditor
Pure QML implementation of a view with connected nodes

## Installation
Copy the following file structure to the QML import path:
* QmlNodeEditor
* * NodeView.qml
* * NodeViewStyle.qml
* * qmldir
* * private folder with content

Specify the import path for QML Engine: https://doc.qt.io/qt-6/qqmlengine.html#addImportPath

## Usage
```
import QmlNodeEditor 1.0
NodeView {
    model: nodesModel
}
```
Look into DemoApp.qml for samples.

## Documentation
[NodeView](docs/html/db/da9/class_node_view.html)