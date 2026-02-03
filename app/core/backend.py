import os
import sys
import base64
from io import BytesIO
from PyQt6.QtCore import QObject, pyqtSignal, pyqtSlot, pyqtProperty, QUrl, QDate
from PyQt6.QtGui import QDesktopServices
from app.core.workers import DataWorker, WordCloudWorker
from app.config.settings import COUNTRY_CONFIGS


class Backend(QObject):
    # 信号
    ipChanged = pyqtSignal()
    newsDataChanged = pyqtSignal()
    cloudResultChanged = pyqtSignal()  # 图片更新信号
    statusMessageChanged = pyqtSignal(str)

    def __init__(self):  # 🟢 注意：这里不再需要 image_provider 参数了
        super().__init__()
        self._ip = "📍 定位中..."
        self._news_model = []
        self._keywords = ""
        self._save_dir = os.path.join(os.path.expanduser("~"), "Desktop")
        self._current_date = QDate.currentDate().toString("yyyy-MM-dd")

        # 🟢 新增：存储 Base64 图片字符串
        self._cloud_image_source = ""

        self.fetch_ip()

    # --- 属性 ---
    @pyqtProperty(str, notify=ipChanged)
    def ipString(self):
        return self._ip

    @pyqtProperty(list, notify=newsDataChanged)
    def newsModel(self):
        return self._news_model

    @pyqtProperty(str, notify=cloudResultChanged)
    def keywordsText(self):
        return self._keywords

    # 🟢 新增：直接把图片以字符串形式传给 QML
    @pyqtProperty(str, notify=cloudResultChanged)
    def cloudImageSource(self):
        return self._cloud_image_source

    @pyqtProperty(str)
    def saveDir(self):
        return self._save_dir

    @pyqtProperty(list, constant=True)
    def countryList(self):
        return list(COUNTRY_CONFIGS.keys())

    # --- 槽函数 ---
    @pyqtSlot()
    def fetch_ip(self):
        self.worker_ip = DataWorker("ip")
        self.worker_ip.result_signal.connect(self._handle_ip)
        self.worker_ip.start()

    def _handle_ip(self, res):
        if res['success']:
            self._ip = f"📍 {res['data']}"
            self.ipChanged.emit()

    @pyqtSlot(str, str)
    def fetchNews(self, country_name, date_str):
        self._current_date = date_str
        url = COUNTRY_CONFIGS.get(country_name, {}).get("url")
        if not url: return
        self.statusMessageChanged.emit("正在抓取新闻...")
        self.worker_news = DataWorker("news", url=url)
        self.worker_news.result_signal.connect(self._handle_news)
        self.worker_news.start()

    def _handle_news(self, res):
        if res['success']:
            self._news_model = res['data']
            self.newsDataChanged.emit()
            self.statusMessageChanged.emit("新闻获取成功")
        else:
            self.statusMessageChanged.emit("获取失败")

    @pyqtSlot(str, str)
    def generateCloud(self, country_name, lang):
        url = COUNTRY_CONFIGS.get(country_name, {}).get("url")
        self.statusMessageChanged.emit("正在生成词云...")
        self.worker_cloud = WordCloudWorker(url, lang)
        self.worker_cloud.finished_signal.connect(self._handle_cloud)
        self.worker_cloud.start()

    def _handle_cloud(self, pil_image, text):
        if pil_image:
            # 🟢 核心修改：不存 ImageProvider，直接转 Base64 字符串
            try:
                buffered = BytesIO()
                pil_image.save(buffered, format="PNG")
                img_str = base64.b64encode(buffered.getvalue()).decode()
                # 拼接成 HTML 可识别的格式
                self._cloud_image_source = f"data:image/png;base64,{img_str}"

                self._keywords = text
                self.cloudResultChanged.emit()
                self.statusMessageChanged.emit("词云生成完毕")
            except Exception as e:
                print(f"Base64 Convert Error: {e}")
                self.statusMessageChanged.emit("图片转换失败")
        else:
            self._keywords = f"生成失败: {text}"
            self.cloudResultChanged.emit()

    @pyqtSlot(str)
    def openLink(self, link):
        QDesktopServices.openUrl(QUrl(link))

    @pyqtSlot(str)
    def setSaveDir(self, path):
        clean = QUrl(path).toLocalFile()
        self._save_dir = clean
        self.statusMessageChanged.emit(f"目录: {clean}")

    @pyqtSlot(str, str)
    def saveFile(self, content, file_type):
        name = f"{self._current_date}_{'日报' if file_type == 'news' else '热词'}.txt"
        path = os.path.join(self._save_dir, name)
        try:
            with open(path, "w", encoding="utf-8") as f:
                f.write(content)
            self.statusMessageChanged.emit(f"已保存: {name}")
        except Exception as e:
            self.statusMessageChanged.emit(f"保存失败: {e}")