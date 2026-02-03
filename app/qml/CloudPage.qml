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
            ComboBox { id: cloudCountry; model: backend.countryList }
            ComboBox {
                id: cloudLang
                model: ["中文 (zh-CN)", "英文 (en)"]
            }
            Button {
                text: "🔥 生成词云"
                onClicked: {
                    var langCode = cloudLang.currentIndex === 0 ? "zh-CN" : "en"
                    backend.generateCloud(cloudCountry.currentText, langCode)
                }
                background: Rectangle { color: "#F38BA8"; radius: 4 }
                contentItem: Text { text: parent.text; color: "#1E1E2E"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
        }

        // 内容分栏
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20

            // 左侧：图片
            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: 2
                color: "#181825"
                border.color: "#45475A"
                border.width: 1
                radius: 8

                Image {
                    id: cloudImage
                    anchors.fill: parent
                    anchors.margins: 5
                    fillMode: Image.PreserveAspectFit

                    // 🟢 核心修改：直接绑定 Python 传过来的 Base64 字符串
                    source: backend.cloudImageSource
                }

                // 提示文字（如果没有图片时显示）
                Text {
                    anchors.centerIn: parent
                    text: backend.cloudImageSource == "" ? "等待生成..." : ""
                    color: "#6C7086"
                    visible: backend.cloudImageSource == ""
                }
            }

            // 右侧：关键词文本
            ScrollView {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                background: Rectangle { color: "#11111B"; radius: 8 }

                TextArea {
                    text: backend.keywordsText
                    color: "#A6ADC8"
                    font.family: "Consolas"
                    readOnly: true
                    selectByMouse: true
                }
            }
        }

        Button {
            text: "💾 保存结果"
            Layout.alignment: Qt.AlignRight
            onClicked: backend.saveFile(backend.keywordsText, "cloud")
        }
    }
}