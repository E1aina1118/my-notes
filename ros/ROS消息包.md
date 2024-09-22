# 标准消息包std_msgs

ROS消息包主要分为**std_msgs（标准消息包）**和**common_msgs（常规消息包）**。

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7B0FF25E7E-67BB-424F-ACB0-D97562D5611E%7D.png" alt="{0FF25E7E-67BB-424F-ACB0-D97562D5611E}" style="zoom:50%;" />

> 大部分节点之间的通信都是用常规消息包。

### 个别消息类型：

- ColorRGBA: 包含 **红、绿、蓝、透明度** 四个分量的结构体，用于描述图片
- Duration: 相对时间 可正可负

- Time: 绝对时间 无符号 不可为负
- Header: 记录时间戳和坐标系名称，在所有包含Stamped关键词的消息类型，都会包含Header结构体

# 几何消息包geometry_msgs和sensor_msgs

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7BEC8CD7F9-A141-40A1-AAF7-AE428700CFB8%7D.png" alt="{EC8CD7F9-A141-40A1-AAF7-AE428700CFB8}" style="zoom:50%;" />

> 其中最常用geometry_msgs和sensor_msgs消息包

### geometry_msgs消息包

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7B12DA4EBE-0046-48BA-A910-147656BF100F%7D.png" alt="{12DA4EBE-0046-48BA-A910-147656BF100F}" style="zoom:50%;" />

### sensor_msgs传感器消息包

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7BB11150C9-05C4-4BC4-919C-4502AA29F3F0%7D.png" alt="{B11150C9-05C4-4BC4-919C-4502AA29F3F0}" style="zoom:50%;" />

# 自定义消息包

当官方消息包无法满足要求，可以自定义消息包

消息包可以嵌套消息包。

**首先进入`~/catkin_ws/src`目录，新建消息包**

```shell
catkin_create_pkg qq_msgs roscpp rospy std_msgs message_generation message_runtime
```

其中message_generation和message_runtime是消息包的特有的依赖项

进入新建消息包目录

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7B63D14278-3990-4B5D-B623-C9A8C236308C%7D.png" alt="{63D14278-3990-4B5D-B623-C9A8C236308C}" style="zoom:33%;" />

**创建`msg`文件夹，新建文件`Carry.msg`，然后在msg内定义消息内容的消息类型**

```
string grade
int64 star
string data
```

**在`CMakeLists.txt`中，添加**

```cmake
add_message_file(
	FILES
	Carry.msg
)
generate_messages(
	DEPENDENCIES
	std_msgs
)
catkin_package(
	# CATKIN_DEPENDS message_generation message_runtime roscpp rospy std_msgs ...
)
```

**打开`package.xml`文件**

确保

```xml
<build_depend> ... </build_depend>
<exec_depend> ... </exec_depend>
```

都列出了`message_generation`和`message_runtime`

**最后进入`~/catkin_ws`，进行`catkin_make`**

可以使用

```shel
rosmsg show qq_msgs/Carry
```

可以查看**消息结构**

## 节点中调用自定义消息类型

**首先打开`CMakeLists.txt`**

添加依赖

```cmake
find_package(catkin REQUIRED COMPONENTS
	roscpp
	rospy
	std_msgs
	qq_msgs
)
```

这样就代表了先编译消息包，再编译节点，防止依赖缺失编译出错

在末尾处添加

```cmake
add_dependencies(my_node qq_msgs_generate_messages_cpp)
```

**再打开`package.xml`**

```xml
<build_depend>qq_msgs</build_depend>
<exec_depend>qq_msgs</exec_depend>
```

添加qq_msgs包

### C++节点

```cpp
// #include ...
#include <qq_msgs/Carry.h>
```

### Python节点

```python
# import ...
from qq_msgs.msg import Carry
```



