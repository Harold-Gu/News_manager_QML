import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    background: Rectangle { color: "transparent" }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // 控制区
        RowLayout {
            spacing: 10
            ComboBox {
                id: countryBox
                model: backend.countryList
                Layout.preferredWidth: 150
            }

            // 简单日期模拟 (真实日历控件需要 Qt.labs.calendar，这里简化)
            TextField {
                id: dateField
                text: Qt.formatDate(new Date(), "yyyy-MM-dd")
                Layout.preferredWidth: 120
                placeholderText: "yyyy-MM-dd"
            }

            Button {
                text: "🔍 获取日报"
                highlighted: true
                onClicked: backend.fetchNews(countryBox.currentText, dateField.text)
                background: Rectangle {
                    color: parent.down ? "#45475A" : "#89B4FA"
                    radius: 4
                }
                contentItem: Text { text: parent.text; color: "#1E1E2E"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }

            Item { Layout.fillWidth: true } // 弹簧占位

            Button {
                text: "💾 保存TXT"
                onClicked: {
                    var content = "【日报汇总】\n"
                    // 遍历 Model 拼接文本
                    for(var i=0; i<backend.newsModel.length; i++) {
                        var item = backend.newsModel[i]
                        content += (i+1) + ". " + item.title + "\n链接: " + item.link + "\n\n"
                    }
                    backend.saveFile(content, "news")
                }
            }
        }

        // 列表展示区
        ListView {
            id: newsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: backend.newsModel
            spacing: 10

            delegate: Rectangle {
                width: newsList.width
                height: 80
                color: "#313244"
                radius: 8
                border.color: mouseArea.containsMouse ? "#89B4FA" : "transparent"

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: backend.openLink(modelData.link)
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    Text {
                        text: (index + 1) + ". " + modelData.title
                        color: "#CDD6F4"
                        font.pixelSize: 14
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Text {
                        text: "来源: " + modelData.source
                        color: "#6C7086"
                        font.pixelSize: 12
                    }
                }
            }
        }
    }
}