#import "theme.typ": *

#show: doc => setup-base-fonts(
  doc,
  cjk-mono-family: ("JetBrains Maple Mono", "SF Mono SC"),
)

#show: course-theme.with(
  title: [第八章：GIS系统二次开发],
  author: [谭振宇],
  institution: [西北大学城市与环境学院],
  bg-image: "figures/西北大学.jpeg",
  logo-image: "figures/西北大学.pdf",
  title-font-size: 1.2em,
  toc-font-size: 26pt,
  toc-spacing: 1em,
  code-font-size: 0.9em,
)

#course-title-slide(
  bg-image: "figures/西北大学.jpeg",
  logo-image: "figures/西北大学.pdf",
)

= GIS系统二次开发

== 学习目标

#titled-card(
  [核心学习目标],
  [
    - 熟悉QGIS软件的常规使用
    - 掌握基于PyQGIS的批处理程序设计
    - 了解GUI程序的基本组成和控件概念
    - 掌握PyQt接口的基本使用
    - 能够在GUI程序中加载矢量空间数据
    - 能够在GUI程序中加载栅格影像数据
  ]
)

== 背景介绍

基于命令行的数据处理方式适合大批量的不需要人工交互的数据操作。由于 GIS 经常需要进行空间分析和可视化制图，图形用户界面系统可以更方便地与人工交互。

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: top,
  titled-card(
    [PyQGIS开发],
    [
      - 了解基于PyQGIS如何控制地图交互
      - 掌握如何调用处理算法模型
    ]
  ),
  titled-card(
    [GUI定制开发],
    [
      - 如何设计图形界面
      - 如何处理界面与用户的交互逻辑
      - 如何进行桌面GIS程序开发
    ]
  )
)

= PyQGIS入门

== QGIS 简介

`QGIS` 是一个开源免费的地理信息系统应用程序，类似ArcGIS软件，提供了丰富的功能用于创建、编辑、可视化、分析和发布地理空间信息。

QGIS平台基于C++ GUI库Qt进行开发，`PyQGIS`是QGIS对其C++ API进行封装暴露的Python接口。

#titled-card(
  [PyQGIS 的应用场景],
  [
    - QGIS 内置的 Python 控制台中执行交互式操作
    - 开发 QGIS 插件
    - 编写独立的基于 QGIS API 的自定义桌面应用程序
  ]
)

== QGIS安装及其开发环境配置

作为一款跨平台的软件，QGIS同时支持Windows、macOS和Linux系统。

可以从QGIS官网下载安装包。QGIS官网提供了在线下载方式的安装包 OSGeo4W network Installer及离线下载安装的 QGIS Standalone Installer。由于在线下载方式较慢，建议选择离线安装。官网一般会提供一个最新版本和一个长期维护版本（LTR）。

#align(center)[
  #image("figures/QGIS-Download.png", width: 70%)
]

== 基于QGIS的交互式数据操作

用户可以通过QGIS的菜单栏 `Plugins` -> `Python Console` 打开Python控制台，和当前QGIS中加载的数据进行交互操作。在交互式QGIS环境中, 默认有一个 `iface` 变量，该变量是 `QgisInterface` 类的实例。通过 `iface` 变量用户可以访问当前图层中加载的空间数据。

#text(0.85em)[
  ```python
  from qgis.core import *
  import qgis.utils	
  
  # 获取当前激活的图层
  layer = iface.activeLayer()
  print(f"This current layer is consist of {layer.featureCount()} features")
  
  # 遍历图层要素并打印属性
  features = layer.getFeatures()	
  for feature in features:
      print(feature.attributes())
      
  # 按照属性条件选择要素，满足条件的要素在图层中会高亮显示出来
  layer.selectByExpression("name = '长安区'")
  ```
]

== 基于PyQGIS进行栅格图层操作

#text(0.75em)[
  ```python
  layer = iface.activeLayer()
  print(f"This current layer is consist of {layer.bandCount()} bands")
  print(f'Raster height and width: {layer.height()}, {layer.width()}')
  layer.setName('Elevation') # 修改图层名称

  # 查看处理工具箱中所有的算法
  for alg in QgsApplication.processingRegistry().algorithms():
      print(alg.id(), "->", alg.displayName())
      
  # 可以使用 algorithmHelp 查看算法文档
  # processing.algorithmHelp("native:slope")
  
  # 执行原生的坡度计算提取算法（需要注意输入、输出参数的设置）
  import processing
  processing.run("native:slope", {
      'INPUT': 'Elevation', 
      'Z_FACTOR': 1, 
      'OUTPUT': '/Users/tanzhenyu/Desktop/Slope.tif'
  })
  ```
]

== QGIS命令行运行过程展示

#align(center)[
  #image("figures/QGIS-Console-Process.png", width: 75%)
]
#text(0.8em, align(center)[*在QGIS Python命令行终端中使用GDAL坡度算法通过DEM计算坡度*])


== 独立脚本开发配置

如果要脱离QGIS的图形用户界面，编写可以批量处理的Python脚本，则需要将Python开发环境切换为QGIS内置的Python解释器。

#titled-card(
  [不同系统Python解释器路径配置],
  [
    - *Windows*：`C:/Program Files/QGIS 3.3x/bin/python-qgis.bat`
    - *macOS*：`/Applications/QGIS.app/Contents/MacOS/bin/python3.9`
    - *Ubuntu*：系统自带Python，一般为 `/usr/bin/python`
  ]
)

#align(center)[
  #image("figures/QGIS-Python-Env-1.png", width: 75%)
]

== 独立脚本开发环境配置验证

可以通过PyCharm集成开发环境中查看配置环境的结果：
#align(center)[
  #image("figures/QGIS-Python-Env-2.png", width: 70%)
]

== 独立脚本开发

独立脚本编程第一步需要在脚本中指定QGIS的安装路径，使用 `QgsApplication` 类初始化QGIS应用程序。如果要使用处理功能，需要初始化 `Processing` 类。

#text(0.70em)[
  ```python
  from qgis.core import *
  import processing
  from processing.core.Processing import Processing
  
  # 指定 QGIS 的前缀路径（不同系统需修改）
  QgsApplication.setPrefixPath(r"C:\Program Files\QGIS 3.26\apps\qgis", True)
  # 新建一个QGIS应用实例，参数 False 禁用 GUI 显示
  qgs = QgsApplication([], False)
  qgs.initQgis()
  Processing.initialize() # 初始化算法工具箱
  
  # 新建一个栅格图层
  fn = "dem25.tif"
  layer = QgsRasterLayer(fn, "SRTM")
  QgsProject.instance().addMapLayer(layer, False)
  
  # 执行算法
  processing.run("native:slope", {'INPUT': "SRTM", 'Z_FACTOR': 1, 'OUTPUT': 'slope25.tif'})
  
  # 退出并释放资源
  QgsProject.instance().removeMapLayer(layer.id())
  qgs.exitQgis()
  ```
]

= Qt GUI入门

== Qt GUI 库简介

Qt是一个跨平台的C++应用程序框架，提供了一系列通用的基础类库和图形界面设计接口。支持Windows、Linux、macOS、Android、iOS等。Qt库提供了商业和开源两种许可。

Python绑定：
#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: top,
  titled-card(
    [PyQt],
    [
      由 Riverbank Computing 开发，采用 GPL 协议（开源软件可以免费使用，但不适用于闭源商用软件，需要购买商业许可）。学习资料非常丰富，相对成熟。
    ]
  ),
  titled-card(
    [PySide],
    [
      由 Qt 官方发行的 Python 绑定，采用 LGPL 协议（可以免费用于闭源商业软件开发）。
    ]
  )
)

== Qt开发核心概念

- *控件 (Widget)*：在Qt程序中，应用程序显示的整体界面或基本元素（如按钮、标签、文本框）都统称为 Widget，`QWidget` 是所有控件的基类。
- *布局 (Layout)*：将控件按照规则在窗口中排列组合从而形成复杂节目，Qt的布局管理系统提供了 `QHBoxLayout`、`QVBoxLayout`、`QGridLayout` 等常见布局。

#titled-card(
  [信号与槽 (Signal & Slot)],
  [
    GUI程序需要响应用户的输入进行处理并给出反馈。Qt中通过信号槽机制绑定触发行为和响应操作：\
    当对象状态改变（如按钮被点击 `button.clicked`），就会触发发送信号 (Signal)。若该信号关联了槽函数 (Slot)，则响应的槽函数被执行完成相应的功能。\
    `button.clicked.connect(self.on_button_clicked)`
  ]
)

== Qt开发入门实战

编写一个简单的 Hello World 应用程序窗口。入口通过 `QApplication` 对象驱动，窗口类继承自 `QMainWindow`。

```python
import sys
from PyQt5.QtWidgets import *

class MainWindow(QMainWindow):
    def __init__(self):
        super(MainWindow, self).__init__()
        self.setWindowTitle('Hello World')
        self.resize(500, 350)

        self.button = QPushButton('Click Me', self)
        self.button.setGeometry(200, 150, 100, 30) # 绝对位置布局（通常不推荐）
        self.button.clicked.connect(self.on_button_clicked) # 绑定信号与槽

    @staticmethod
    def on_button_clicked():
        alert = QMessageBox() # 点击弹出对话框
        alert.setText('You clicked the button!')
        alert.exec()


if __name__ == '__main__':
  app = QApplication(sys.argv)
  win = MainWindow()
  win.show() # 显示窗口
  sys.exit(app.exec()) # 进入主事件循环
```

== Qt入门程序运行结果

#align(center)[
  #image("figures/Qt-HelloWorld.png", width: 65%)
]
#text(0.8em, align(center)[*最简单的Qt入门程序示例*])


== 菜单栏 (MenuBar)

菜单栏通常位于窗口顶部，包含多个下拉菜单。由 `QMenuBar` 和 `QMenu` 来实现，菜单项由 `QAction` 表示。

#text(0.65em)[
  ```python
  class MainWindow(QMainWindow):
      def __init__(self):
          super().__init__()
          # 菜单栏构建
          self.menubar = self.menuBar()
          menu_file = self.menubar.addMenu('文件')
          
          # 动作创建与绑定
          action_new = QAction('新建', self)
          action_new.setShortcut('Ctrl+N')
          action_new.triggered.connect(self.handle_new_file)
          menu_file.addAction(action_new)
          
          action_open = QAction('打开', self)
          action_open.triggered.connect(self.handle_open_file)
          menu_file.addAction(action_open)
          
      def handle_open_file(self):
          label = QLabel("人类的悲欢并不相通，我只觉得他们吵闹", self)
          label.setAlignment(Qt.AlignCenter)  # 设置文本居中
          self.layout.addWidget(label)
  ```
]

== PyQt实现应用程序菜单栏图示

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: center,
  image("figures/PyQt-Menus-1.png", width: 95%),
  image("figures/PyQt-Menus-2.png", width: 95%)
)
#text(0.8em, align(center)[*在Linux操作系统中由于自由软件属性可以自定义菜单栏布局*])

== 工具栏 (ToolBar)

工具栏通常包含一系列按钮，帮助用户快速访问常用的命令或功能。PyQt 中的工具栏由 `QToolBar` 类实现。

#text(0.70em)[
  ```python
  class MainWindow(QMainWindow):
      def __init__(self):
          super().__init__()
          # ...
          # 创建底部状态栏
          self.statusbar = QStatusBar()
          self.setStatusBar(self.statusbar)

          # 工具栏构建
          self.toolbar = self.addToolBar('常用工具')
          
          new_action = QAction('🗒️', self)
          new_action.triggered.connect(self.handle_new_file)
          self.toolbar.addAction(new_action)
          
      def handle_new_file(self):
          self.statusbar.showMessage('创建新文件')
  ```
]

== PyQt实现应用程序工具栏图示

#align(center)[
  #image("figures/PyQt-ToolBar.png", width: 80%)
]


= 基于QGIS的二次开发

== QGIS 地图画布加载矢量数据

在 PyQt 中用于显示地图容器的类是 `QgsMapCanvas`。通过向其添加图层可实现可视化显示。配合 `QgsMapToolPan` 等地图工具，可实现平移缩放等地图交互。
数据图层抽象表示为：`QgsVectorLayer` (矢量) 和 `QgsRasterLayer` (栅格)。

#text(0.85em)[
```python
class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        # 地图画布初始化
        self.canvas = QgsMapCanvas()
        self.canvas.setCanvasColor(Qt.white)
        self.setCentralWidget(self.canvas)

        # 交互工具设置：将地图画布的行为绑定到特定的处理工具
        self.toolPan = QgsMapToolPan(self.canvas)
        actionPan = QAction("平移", self)
        actionPan.triggered.connect(self.pan)
        # ...
        
    def pan(self):
        self.canvas.setMapTool(self.toolPan)

    def open(self):
          # 通过文件对话框加载数据
          names = QFileDialog.getOpenFileName(self, '加载数据')
          name = names[0]
          if name and len(name) > 0:
              layer = QgsVectorLayer(name, os.path.basename(name).split('.')[0], 'ogr')
              if not layer.isValid():
                  pass # 提示错误
              else:
                  # 将图层加到全局QgsProject单例中进行注册
                  QgsProject.instance().addMapLayer(layer)
                  
                  # 设置画布显示范围，然后将图层交由画布绘制
                  self.canvas.setExtent(layer.extent())
                  self.canvas.setLayers([layer])
```
]
== QGIS 画布程序运行界面图示

#align(center)[
  #image("figures/PyQGIS-Vector.png", width: 70%)
]


== 基于PyQGIS加载影像数据

加载栅格数据通过 `QgsRasterLayer` 类实现。

#text(0.85em)[
  ```python
      def open(self):
          names = QFileDialog.getOpenFileName(...)
          name = names[0]
          layer = QgsRasterLayer(name, Path(name).stem, 'gdal')
          
          # 判断波段组合功能是否启用
          bandAction = next(filter(lambda act: act.text() == '波段组合', self.toolbar.actions()))
          bandAction.setCheckable(True)
          
          # partial是一个偏函数，将第二参数固定设置为当前图层中的栅格数据
          bandAction.triggered.connect(partial(self.bandComb, layer))
          
          if layer.isValid():
              QgsProject.instance().addMapLayer(layer)
              self.canvas.setExtent(layer.extent())
              self.canvas.setLayers([layer])
  ```
]

== 栅格数据自定义波段可视化渲染

如果希望让用户选取渲染波段并自定义RGB颜色配置。可以通过自定义下拉框（`QComboBox`）由用户指定各波段位置。然后基于图层对象的 `renderer()` 对波段进行赋值映射。

#text(0.7em)[
  ```python
  class BandCombWindow(QDialog):
      def __init__(self, parent, rasterLayer):
          super().__init__(parent)
          self.rasterLayer = rasterLayer
          # ...在UI上创建用于选择红、绿、蓝三个颜色的QComboBox组件供用户选择...
          
      def accept(self):
          # 用户点击对话框确认按钮后的回调函数槽
          # 从UI控件中拉取选中的波段序号进行分别赋值
          self.rasterLayer.renderer().setRedBand(int(self.combRed.currentText()[5:]))
          self.rasterLayer.renderer().setGreenBand(int(self.combGreen.currentText()[5:]))
          self.rasterLayer.renderer().setBlueBand(int(self.combBlue.currentText()[5:]))
          
          # 触发栅格重绘操作以将颜色改变反映到画布
          self.rasterLayer.triggerRepaint()
          super().accept()	
  ```
]

== 基于PyQGIS实现空间栅格数据自定义可视化图示

#align(center)[
  #image("figures/PyQGIS-Raster.png", width: 80%)
]

= 课后练习

== 本章小结

#bg-card()[
  本章主要介绍了基于PyQt及PyQGIS的GUI编程机制：
  - 能够基于PyQGIS进行交互式编程及编写独立程序进行空间数据的复杂处理
  - 了解PyQt程序的基本结构，清楚主窗口及各种Qt界面的组织和控件的使用
  - 深入理解PyQt程序中的特有基于信号-槽事件处理机制
  - 能够使用工具栏和菜单栏进行用户交互，并绑定地图处理工具
  - 能够实现空间矢量数据和栅格数据的动态加载以及不同波段的数据自定义可视化展示呈现
]

== 牛刀小试

#titled-card(
  [综合练习作业],
  [
    配置PyQGIS与PyQt桌面开发环境。尝试制作一个综合的GIS小软件程序：
    
    1. 增加界面顶部菜单栏和工具箱，包含文件加载与基础退出操作
    2. 主界面的左边是类似ArcGIS/QGIS的图层列表面板（可以使用 `QListWidget` 或树形图菜单控件），用于显示用户载入的图层
    3. 主界面的右侧是核心地图显示区 `QgsMapCanvas`，要求实现图层渲染，能够可视化加载在图层列表中的栅格和矢量数据
  ]
)
