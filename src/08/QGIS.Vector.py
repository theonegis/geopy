from qgis.core import *
from qgis.gui import *
from qgis.PyQt.QtCore import Qt
from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
import sys
import os


class MainWindow(QMainWindow):
    def __init__(self):
        QMainWindow.__init__(self)
        self.setWindowTitle('GIS小工具')

        self.canvas = QgsMapCanvas()
        self.canvas.setCanvasColor(Qt.white)
        self.setCentralWidget(self.canvas)

        openAction = QAction('&打开', self)
        openAction.setShortcut(QKeySequence.Open)
        openAction.triggered.connect(self.open)

        exitAction = QAction('&退出', self)
        exitAction.setShortcut(QKeySequence.Quit)
        exitAction.triggered.connect(qApp.quit)

        self.menubar = self.menuBar()
        fileMenu = self.menubar.addMenu('文件')
        fileMenu.addAction(openAction)
        fileMenu.addAction(exitAction)

        actionZoomIn = QAction("放大", self)
        actionZoomOut = QAction("缩小", self)
        actionPan = QAction("平移", self)

        actionZoomIn.setCheckable(True)
        actionZoomOut.setCheckable(True)
        actionPan.setCheckable(True)

        actionZoomIn.triggered.connect(self.zoomIn)
        actionZoomOut.triggered.connect(self.zoomOut)
        actionPan.triggered.connect(self.pan)

        self.toolbar = self.addToolBar("Canvas actions")
        self.toolbar.addAction(actionZoomIn)
        self.toolbar.addAction(actionZoomOut)
        self.toolbar.addAction(actionPan)

        # create the map tools
        self.toolPan = QgsMapToolPan(self.canvas)
        self.toolPan.setAction(actionPan)
        self.toolZoomIn = QgsMapToolZoom(self.canvas, False)
        self.toolZoomIn.setAction(actionZoomIn)
        self.toolZoomOut = QgsMapToolZoom(self.canvas, True)
        self.toolZoomOut.setAction(actionZoomOut)

        self.pan()

    def zoomIn(self):
        self.canvas.setMapTool(self.toolZoomIn)

    def zoomOut(self):
        self.canvas.setMapTool(self.toolZoomOut)

    def pan(self):
        self.canvas.setMapTool(self.toolPan)

    def open(self):
        names = QFileDialog.getOpenFileName(self, '加载数据')
        name = names[0]
        if name and len(name) > 0:
            layer = QgsVectorLayer(name, os.path.basename(name).split('.')[0], 'ogr')
            if not layer.isValid():
                message = QMessageBox()
                message.setIcon(QMessageBox.Information)
                message.setText("数据加载错误！")
                message.setWindowTitle("警告")
                message.setStandardButtons(QMessageBox.Ok)
                message.exec()
            else:
                QgsProject.instance().addMapLayer(layer)
                self.canvas.setExtent(layer.extent())
                self.canvas.setLayers([layer])


if __name__ == '__main__':
    app = QApplication(sys.argv)
    app.setApplicationName('QGIS')
    win = MainWindow()
    win.show()
    sys.exit(app.exec())

