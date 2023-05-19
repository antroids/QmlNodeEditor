// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0

import QtQuick 6.2
import QmlNodeEditor
import QtQuick.Controls 2.15

import QmlNodeEditor 1.0

Window {
    width: 640
    height: 480

    visible: true
    title: "QmlNodeEditor"

    ListModel {
        id: nodesModel

        onDataChanged: (firstRow, lastRow, role) => {
                           console.info("Model changed " + firstRow + "; " + lastRow + "; " + role);
                       }

        ListElement {
            nodeId: 1
            name: "Node 1 long name long name long name long name long name long name long name long name"
            x: 100
            y: 100
            leftPorts: [
                ListElement {
                    portId: 1
                    name: "Port 1"
                    filter: "output"
                    tags: "input"
                },
                ListElement {
                    portId: 2
                    name: "Port 2"
                    filter: "output"
                    tags: "input"
                }
            ]
            rightPorts: [
                ListElement {
                    portId: 3
                    name: "Port 3"
                },
                ListElement {
                    portId: 4
                    name: "Port 4"
                }
            ]
            connections: []
        }
        ListElement {
            nodeId: 2
            x: 300
            y: 200
            name: "Node 2"
            removable: true
            leftPorts: [
                ListElement {
                    portId: 1
                    name: "Port 1"
                },
                ListElement {
                    portId: 2
                    name: "Port 2"
                }
            ]
            rightPorts: [
                ListElement {
                    portId: 3
                    name: "Port 3"
                    filter: "input"
                    tags: "output"
                }
            ]
            connections: [
                ListElement {
                    fromNodeId: 2
                    fromPortId: 1
                    toNodeId: 1
                    toPortId: 2
                },
                ListElement {
                    fromNodeId: 2
                    fromPortId: 1
                    toNodeId: 1
                    toPortId: 1
                    removable: true
                }
            ]
        }
        ListElement {
            nodeId: 3
            x: 50
            y: 250
            name: "Node 3"
            removable: false
            leftPorts: [
                ListElement {
                    portId: 31
                    name: "Port 31"
                },
                ListElement {
                    portId: 32
                    name: "Port 32"
                },
                ListElement {
                    portId: 33
                    name: "Port 33"
                },
                ListElement {
                    portId: 34
                    name: "Port 34"
                },
                ListElement {
                    portId: 35
                    name: "Port 35"
                },
                ListElement {
                    portId: 36
                    name: "Port 36"
                },
                ListElement {
                    portId: 37
                    name: "Port 37"
                    filter: "input,output"
                },
                ListElement {
                    portId: 38
                    name: "Port 38"
                }
            ]
            connections: []
        }

        function findNode(nodeId) {
            var nodeIndex = findNodeIndex(nodeId);
            return nodeIndex !== undefined ? get(nodeIndex) : undefined;
        }

        function findNodeIndex(nodeId) {
            for (var nodeIndex = 0; nodeIndex < count; nodeIndex++) {
                var node = get(nodeIndex);
                if (node && node.nodeId === nodeId) {
                    return nodeIndex;
                }
            }
            return undefined;
        }

        function findPort(portId, ports) {
            for (var portIndex = 0; portIndex < ports.count; portIndex++) {
                var port = ports.get(portIndex);
                if (port && port.portId === portId) {
                    return port;
                }
            }
            return undefined;
        }

        function addConnection(fromNodeId, fromPortId, toNodeId, toPortId) {
            var fromNodeIndex = findNodeIndex(fromNodeId);
            if (fromNodeIndex !== undefined) {
                var fromNode = nodesModel.get(fromNodeIndex);
                if (fromNode) {
                    var fromNodeConnections = fromNode.connections;
                    if (fromNodeConnections) {
                        fromNodeConnections.append({fromNodeId: fromNodeId, fromPortId: fromPortId, toNodeId: toNodeId, toPortId: toPortId});
                    }
                }
            }
        }

        function removeConnectionsByNode(nodeId) {
            for (var nodeIndex = 0; nodeIndex < count; nodeIndex++) {
                var node = get(nodeIndex);
                if (node) {
                    var nodeConnections = node.connections;
                    for (var connectionIndex = 0; connectionIndex < nodeConnections.count; ) {
                        var connection = nodeConnections.get(connectionIndex);
                        if (connection && (connection.fromNodeId === nodeId || connection.toNodeId === nodeId)) {
                            nodeConnections.remove(connectionIndex);
                        } else {
                            connectionIndex++;
                        }
                    }
                }
            }
        }

        function removeConnection(fromNodeId, fromPortId, toNodeId, toPortId) {
            console.debug("Removing connection fromNodeId " + fromNodeId + " fromPortId " + fromPortId + " toNodeId " + toNodeId + " toPortId " + toPortId);
            for (var nodeIndex = 0; nodeIndex < count; nodeIndex++) {
                var node = get(nodeIndex);
                if (node) {
                    var nodeConnections = node.connections;
                    for (var connectionIndex = 0; connectionIndex < nodeConnections.count; connectionIndex++) {
                        var connection = nodeConnections.get(connectionIndex);
                        if (connection &&
                                connection.fromNodeId === fromNodeId &&
                                connection.toNodeId === toNodeId &&
                                connection.fromPortId === fromPortId &&
                                connection.toPortId === toPortId) {
                            nodeConnections.remove(connectionIndex);
                            return true;
                        }
                    }
                }
            }
            console.warn("Connection not found fromNodeId " + fromNodeId + " fromPortId " + fromPortId + " toNodeId " + toNodeId + " toPortId " + toPortId);
            return false;
        }
    }

    Button {
        text: "Test"

        onClicked: {
            nodesModel.setProperty(0, "x", 300);
        }
    }


    NodeView {
        model: nodesModel

        anchors.fill: parent

        onConnectionAdded: (fromNodeId, fromPortId, toNodeId, toPortId) => nodesModel.addConnection(fromNodeId, fromPortId, toNodeId, toPortId);
        onNodePositionChanged: (nodeId, nodeX, nodeY) => {
                                   var nodeIndex = nodesModel.findNodeIndex(nodeId);
                                   if (nodeIndex !== undefined) {
                                       nodesModel.setProperty(nodeIndex, "x", nodeX);
                                       nodesModel.setProperty(nodeIndex, "y", nodeY);
                                   }
                               }
        onNodeRemoved: (nodeId) => {
                           var nodeIndex = nodesModel.findNodeIndex(nodeId);
                           nodesModel.removeConnectionsByNode(nodeId);
                           nodesModel.remove(nodeIndex);
                       }
        onConnectionRemoved: (fromNodeId, fromPortId, toNodeId, toPortId) => nodesModel.removeConnection(fromNodeId, fromPortId, toNodeId, toPortId);
    }
}

