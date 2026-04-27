import sys
# 导入PyQt Widget包的全部内容
from PyQt5.QtWidgets import *


class MainWindow(QMainWindow):
    """
    定义主窗口类，在构造函数中定义的Widget会自动添加到主窗体中显示
    """
    def __init__(self):
        super(MainWindow, self).__init__()
        self.setWindowTitle('Hello World')
        self.resize(500, 350)

        self.button = QPushButton('Click Me', self)
        self.button.setGeometry(200, 150, 100, 30)
        # 关联按钮点击事件的信号与对应响应的槽
        self.button.clicked.connect(self.on_button_clicked)

    # 定义钮点击事件响应的槽，弹出一个信息提示框
    @staticmethod
    def on_button_clicked():
        alert = QMessageBox()
        alert.setIcon(QMessageBox.Information)
        alert.setWindowTitle('Information')
        alert.setText('You clicked the button!')
        alert.exec()


if __name__ == '__main__':
    app = QApplication(sys.argv)
    win = MainWindow()
    win.show()
    sys.exit(app.exec())
