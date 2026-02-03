import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: 1000
    height: 700
    title: "每日汇报助手 Pro (Qt Quick)"
    color: "#1E1E2E" // 背景色

    // 顶部栏
    header: ToolBar {
        background: Rectangle { color: "#181825" }
        RowLayout {
            anchors.fill: parent
            spacing: 15

            Label {
                text: "  📊 全球视野"
                font.bold: true
                font.pixelSize: 18
                color: "#CDD6F4"
            }

            // 选项卡切换
            TabBar {
                id: navBar
                Layout.fillWidth: true
                background: Rectangle { color: "transparent" }

                TabButton {
                    text: "📋 每日日报"
                    contentItem: Text {
                        text: parent.text
                        color: parent.checked ? "#89B4FA" : "#6C7086"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle { color: "transparent" }
                }
                TabButton {
                    text: "🔥 热点词云"
                    contentItem: Text {
                        text: parent.text
                        color: parent.checked ? "#F38BA8" : "#6C7086" // 选中变红
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle { color: "transparent" }
                }
            }

            Label {
                text: backend.ipString
                color: "#A6E3A1"
                font.pixelSize: 12
                Layout.rightMargin: 15
            }
        }
    }

    // 内容区：堆叠页面
    StackLayout {
        anchors.fill: parent
        currentIndex: navBar.currentIndex

        NewsPage {}  // index 0
        CloudPage {} // index 1
    }

    // 底部状态栏
    footer: ToolBar {
        height: 30
        background: Rectangle { color: "#11111B" }
        Label {
            id: statusLabel
            text: "准备就绪"
            color: "#6C7086"
            font.pixelSize: 11
            anchors.centerIn: parent
        }
    }

    // 连接 Python 信号更新状态栏
    Connections {
        target: backend
        function onStatusMessageChanged(msg) { statusLabel.text = msg }
    }
}