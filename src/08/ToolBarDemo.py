import sys

from PyQt5.QtCore import QSize
from PyQt5.QtWidgets import *


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()

        self.setWindowTitle("工具栏示例程序")
        self.setGeometry(100, 100, 600, 400)
        self.container = QWidget()
        self.setCentralWidget(self.container)
        self.layout = QVBoxLayout(self.container)

        # 创建底部状态栏
        self.statusbar = QStatusBar()
        self.setStatusBar(self.statusbar)

        # 创建工具栏
        self.toolbar = self.addToolBar('常用工具')

        # 创建新建文件动作，这里用Emoj模拟图标
        new_action = QAction('🗒️', self)
        new_action.setShortcut('Ctrl+N')
        new_action.triggered.connect(self.handle_new_file)
        self.toolbar.addAction(new_action)

        # 创建打开文件动作
        open_action = QAction('📁', self)
        open_action.setShortcut('Ctrl+O')
        open_action.triggered.connect(self.handle_open_file)
        self.toolbar.addAction(open_action)

        # 创建退出动作
        exit_action = QAction('🔋', self)
        exit_action.setShortcut('Ctrl+Q')
        exit_action.triggered.connect(self.close)
        self.toolbar.addAction(exit_action)

    def handle_new_file(self):
        self.statusbar.showMessage('创建新文件')

    def handle_open_file(self):
        self.statusbar.showMessage('打开已有文件')


if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())