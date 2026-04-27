import sys

from PyQt5.QtCore import Qt
from PyQt5.QtWidgets import *


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()

        self.setWindowTitle("菜单栏示例程序")
        self.setGeometry(100, 100, 600, 400)
        self.container = QWidget()
        self.setCentralWidget(self.container)
        self.layout = QVBoxLayout(self.container)

        # 创建菜单栏
        self.menubar = self.menuBar()
        # 创建文件菜单
        menu_file = self.menubar.addMenu('文件')

        # 创建新建文件动作，添加快捷键，添加点击事件绑定
        action_new = QAction('新建', self)
        action_new.setShortcut('Ctrl+N')
        action_new.triggered.connect(self.handle_new_file)
        menu_file.addAction(action_new)

        # 创建打开文件动作
        action_open = QAction('打开', self)
        action_open.setShortcut('Ctrl+O')
        action_open.triggered.connect(self.handle_open_file)
        menu_file.addAction(action_open)

        # 创建退出动作
        action_exit = QAction('退出', self)
        action_exit.setShortcut('Ctrl+Q')
        action_exit.triggered.connect(self.close)
        menu_file.addAction(action_exit)

    def handle_new_file(self):
        # 这里通过弹出一个对话框进行新建文件的模拟
        message = QMessageBox()
        message.setIcon(QMessageBox.Information)
        message.setText("新建文件！")
        message.setStandardButtons(QMessageBox.Ok)
        message.exec()

    def handle_open_file(self):
        # 这里通过显示一个文本标签模拟打开文件
        label = QLabel("人类的悲欢并不相通，我只觉得他们吵闹", self)
        label.setAlignment(Qt.AlignCenter)  # 设置文本居中
        self.layout.addWidget(label)


if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())
