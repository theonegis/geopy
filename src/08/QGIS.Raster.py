from qgis.core import *
from qgis.gui import *
from qgis.PyQt.QtCore import Qt
from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
import sys
from pathlib import Path
from functools import partial


class BandCombWindow(QDialog):
    def __init__(self, parent, rasterLayer):
        super().__init__(parent)
        self.rasterLayer = rasterLayer
        self.bandCount = rasterLayer.bandCount()
        self.setWindowTitle("波段组合渲染")
        self.setGeometry(0, 0, 200, 200)

        self.lblRed = QLabel("红波段", self)
        self.lblRed.move(50, 50)
        self.lblRed.setStyleSheet("background-color: red")
        self.lblGreen = QLabel("绿波段", self)
        self.lblGreen.move(50, 50)
        self.lblGreen.setStyleSheet("background-color: green")
        self.lblBlue = QLabel("蓝波段", self)
        self.lblBlue.move(50, 50)
        self.lblBlue.setStyleSheet("background-color: blue")

        self.combRed = QComboBox(self)
        self.combGreen = QComboBox(self)
        self.combBlue = QComboBox(self)
        for combo in (self.combRed, self.combGreen, self.combBlue):
            for ix in range(self.bandCount):
                combo.addItem(f'Band {ix + 1}')

        self.btnBox = QDialogButtonBox(QDialogButtonBox.Ok | QDialogButtonBox.Cancel)
        self.btnBox.accepted.connect(self.accept)
        self.btnBox.rejected.connect(self.reject)

        layout = QGridLayout()
        layout.addWidget(self.lblRed, 0, 0)
        layout.addWidget(self.combRed, 0, 1)
        layout.addWidget(self.lblGreen, 1, 0)
        layout.addWidget(self.combGreen, 1, 1)
        layout.addWidget(self.lblBlue, 2, 0)
        layout.addWidget(self.combBlue, 2, 1)
        layout.addWidget(self.btnBox, 3, 0, 1, 2)
        self.setLayout(layout)

    def accept(self):
        self.rasterLayer.renderer().setRedBand(int(self.combRed.currentText()[5:]))
        self.rasterLayer.renderer().setGreenBand(int(self.combGreen.currentText()[5:]))
        self.rasterLayer.renderer().setBlueBand(int(self.combBlue.currentText()[5:]))
        self.rasterLayer.triggerRepaint()
        super().accept()


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
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
        actionBands = QAction("波段组合", self)

        actionZoomIn.setCheckable(True)
        actionZoomOut.setCheckable(True)
        actionPan.setCheckable(True)
        actionBands.setCheckable(False)

        actionZoomIn.triggered.connect(self.zoomIn)
        actionZoomOut.triggered.connect(self.zoomOut)
        actionPan.triggered.connect(self.pan)

        self.toolbar = self.addToolBar("Canvas actions")
        self.toolbar.addAction(actionZoomIn)
        self.toolbar.addAction(actionZoomOut)
        self.toolbar.addAction(actionPan)
        self.toolbar.addAction(actionBands)

        # 地图放大缩小和平移工具对象和工具栏对应的Action绑定起来
        self.toolPan = QgsMapToolPan(self.canvas)
        self.toolPan.setAction(actionPan)
        self.toolZoomIn = QgsMapToolZoom(self.canvas, False)
        self.toolZoomIn.setAction(actionZoomIn)
        self.toolZoomOut = QgsMapToolZoom(self.canvas, True)
        self.toolZoomOut.setAction(actionZoomOut)
        # 默认地图浏览工具为平移
        self.pan()
        # 默认打开对话框的路径为用户HOME目录
        self.lastDir = Path().home()

    def zoomIn(self):
        self.canvas.setMapTool(self.toolZoomIn)

    def zoomOut(self):
        self.canvas.setMapTool(self.toolZoomOut)

    def pan(self):
        self.canvas.setMapTool(self.toolPan)

    def bandComb(self, rasterLayer):
        bandWindow = BandCombWindow(self, rasterLayer)
        bandWindow.show()


    def open(self):
        names = QFileDialog.getOpenFileName(self, '加载数据', str(self.lastDir),
                                            "Shapefile (*.shp);; GeoTiff (*.tif)")
        name = names[0]
        self.lastDir = Path(name).parent
        layer = None

        bandAction = next(filter(lambda act: act.text() == '波段组合',
                                 self.toolbar.actions()))
        if name and len(name) > 0:
            if name[-3:] == 'shp':
                # 打开栅格数据的时候，将波段组合功能禁用
                layer = QgsVectorLayer(name, Path(name).stem, 'ogr')
                bandAction.setCheckable(False)
            elif name[-3:] == 'tif':
                # 打开栅格数据的时候，将波段组合功能启用，然后将工具栏的bandAction和打开波段对话框的函数bandComb()进行绑定
                layer = QgsRasterLayer(name, Path(name).stem, 'gdal')
                bandAction.setCheckable(True)
                # 这里的partial是一个偏函数，将bandComb()函数的第二个参数固定设置为当前图层中的栅格数据
                bandAction.triggered.connect(partial(self.bandComb, layer))

            if layer is None or not layer.isValid():
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
