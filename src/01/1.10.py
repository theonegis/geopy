# 1.10 面向对象编程高级

import math


class Shape(object):
    def __init__(self, name, coordinates, fill='blank', stroke='black'):
        # 构造函数，对类进行初始化
        self.name = name  # 多边形名称
        self.fill = fill  # 多边形填充色
        self.stroke = stroke  # 多边形边的颜色
        self.coordinates = coordinates  # 多边形坐标

    def area(self):
        pass

    def perimeter(self):
        pass


class Rectangle(Shape):
    # Rectangle继承自Shape
    def __init__(self, coordinates):
        # 使用super方法调用父类的构造函数
        super(Rectangle, self).__init__('Rectangle', coordinates)
        # 使用assert断言判断坐标串个数为4，或者前后坐标串相等时为5
        assert (len(coordinates) == 4 or
                (len(coordinates) == 5 and self.coordinates[0] != self.coordinates[-1]))

        width = math.sqrt((coordinates[0][0] - coordinates[1][0]) ** 2 +
                          (coordinates[0][1] - coordinates[1][1]) ** 2)
        height = math.sqrt((coordinates[1][0] - coordinates[2][0]) ** 2 +
                           (coordinates[1][1] - coordinates[2][1]) ** 2)

        self.coordinates = coordinates
        # 如果给定坐标不闭合，将多边形坐标闭合
        if self.coordinates[0] != self.coordinates[-1]:
            self.coordinates.append(self.coordinates[0])

        # 较长的边作为多边形的长，较短的作为多边形的宽
        self.width = min(width, height)
        self.height = max(width, height)

    def area(self):
        # 计算矩形面积
        return self.height * self.width

    def perimeter(self):
        # 计算矩形周长
        return 2 * (self.height + self.width)


class Circle(Shape):
    def __init__(self, coordinates, center=(0, 0), radius=0):
        super(Circle, self).__init__('Circle', coordinates)
        # 如果没有给定坐标串，给定圆心和半径也可以，因为圆心和半径可以唯一确定一个圆
        if coordinates is None:
            self.center = center
            self.radius = radius
        else:
            # 圆心和圆上任意一点坐标也可以确定一个圆，所以给定坐标串个数为2
            assert len(coordinates) == 2
            # coordinates为圆心坐标和圆上任意一点坐标
            self.center = coordinates[0]  # 圆心坐标
            self.radius = math.sqrt((coordinates[0][0] - coordinates[1][0]) ** 2 +
                                    (coordinates[0][1] - coordinates[1][1]) ** 2)

    def area(self):
        # 计算圆形面积
        return math.pi * self.radius ** 2

    def perimeter(self):
        # 计算圆形周长
        return math.pi * self.radius * 2


if __name__ == '__main__':
    coords = input('请输入几何图形坐标（如：1.2 2.5, 3.0 4.7, ...）：')
    # 首先将coordinates以逗号分割开 coords.split(',')
    # 然后去除掉分割结果中前后的空格再以空格将坐标分割开p.strip().split(' ')
    # 最后将字符串坐标转为数字tuple([float(i) for i in p.strip().split(' ')])
    coords = [tuple([float(i) for i in p.strip().split(' ')]) for p in coords.split(',')]
    shape = None
    if len(coords) == 2:
        print(f'您输入圆形坐标为：{coords}')
        shape = Circle(coords)
    elif len(coords) == 4:
        print(f'您输入矩形坐标为：{coords}')
        shape = Rectangle(coords)

    print(f'图形面积为：{shape.area()}')
    print(f'图形周长为：{shape.perimeter()}')
