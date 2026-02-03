import sys
import os
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtCore import QUrl

from app.core.backend import Backend


# 🟢 注意：不再导入 image_provider

def main():
    # 强制设置样式，防止报错
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"

    app = QGuiApplication(sys.argv)
    app.setOrganizationName("ReportTeam")
    app.setOrganizationDomain("dailyreport.com")

    # 🟢 修改：初始化 Backend 时不需要传 img_provider 了
    backend = Backend()

    engine = QQmlApplicationEngine()

    # 注册 Backend
    engine.rootContext().setContextProperty("backend", backend)

    # 🟢 注意：删除了 engine.addImageProvider(...) 这一行

    # 加载 QML
    base_dir = os.path.dirname(os.path.abspath(__file__))
    qml_file = os.path.join(base_dir, "app/qml/Main.qml")
    engine.load(QUrl.fromLocalFile(qml_file))

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()