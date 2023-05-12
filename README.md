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

There is no documentation yet. 
Look into DemoApp.qml for samples.
The most of the components of the nodes view can be customized by replacing them.