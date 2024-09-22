# 栅格地图

## 介绍

ROS机器人导航所使用的数据，是导航软件包里的map_server节点

![{8B2862FB-0296-4695-800B-4981D1F5C4E9}](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7B8B2862FB-0296-4695-800B-4981D1F5C4E9%7D.png)

其中OccupancyGrid，翻译过来叫占据栅格。

形象表示：

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7B755F5A7E-8A00-4D4C-BA46-F05B4C19390D%7D.png" alt="{755F5A7E-8A00-4D4C-BA46-F05B4C19390D}" style="zoom:50%;" />

> 栅格尺寸决定了地图分辨率，ros中默认分辨率是0.05米

![{1A243551-B9B9-4CBD-AE28-4A572AE34A67}](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7B1A243551-B9B9-4CBD-AE28-4A572AE34A67%7D.png)

> 栅格地图是一个数组，地图信息从下到上，从左到右进行排列。

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7BB812DE53-F0EB-4048-9ACC-7031B440504A%7D.png" alt="{B812DE53-F0EB-4048-9ACC-7031B440504A}" style="zoom:50%;" />

> 即(0,0)位置为地图最左下角的栅格

![{D4687894-26EE-4022-954B-EEC3ED79FD21}](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7BD4687894-26EE-4022-954B-EEC3ED79FD21%7D.png)

> 栅格地图的消息结构

![{24B82819-5BF0-4B16-A0B1-62C1FD3697E1}](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7B24B82819-5BF0-4B16-A0B1-62C1FD3697E1%7D.png)

## 代码实现

此次发布一个2*4的地图

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7B111ADD9A-E790-499B-9871-050BF7E58A65%7D.png" alt="{111ADD9A-E790-499B-9871-050BF7E58A65}" style="zoom:33%;" />

```shell
catkin_create_pkg map_pkg rospy roscpp nav_msgs
```

### C++实现

```cpp
#include <ros/ros.h>
#include <nav_msgs/OccupancyGrid.h>

int main(int argc, char *argv[])
{
    // ... omitted
    
    ros::Rate r(1);
    while(ros::ok())
    {
        nav_msgs::OccupancyGrid msg;
        msg.header.frame_id = "map";
        msg.header.stamp = ros::Time:now();
        
        msg.info.origin.position.x = 0;
        msg.info.origin.position.y = 0;
        // 地图原点相对于世界坐标系的偏移量
        msg.info.resolution = 1.0;
        msg.info.width = 4;
        msg.info.height = 2;
        
        msg.data.resize(4*2);
        msg.data[0] = 100;
        msg.data[1] = 100;
        msg.data[2] = 0;
        msg.data[3] = -1;
        
        pub.publish(msg);
        
        r.sleep();
	}
}
```

### Python实现

```python
#!/usr/bin/env python3
#coding=utf-8

import rospy
from nav_msgs.msg import OccupancyGrid

if __name__ == "__main__":
    # ... omitted
    
    rate = rospy.Rate(1)
    while not rospy.is_shutdowm():
        msg = OccupancyGrid()
        
        msg.header.frame_id = "map"
        msg.header.stamp = rospy.Time.now()
        
        msg.info.origin.position.x = 0
        msg.info.origin.position.y = 0
        msg.info.solution = 1.0
        msg.info.width = 4
        msg.info height = 2
        
        msg.data = [0]*4*2
        msg.data[0] = 100
        msg.data[1] = 100
        msg.data[2] = 0
        msg.data[3] = -1
        
        pub.publish(msg)
        rate.sleep()

```

### 查看效果

首先启动节点

```shell
rosrun map_pkg map_pub_node
```

打开Rviz

```shell
rviz
```

订阅话题，显示地图。

![{3D4B979C-E741-47D3-923B-CB4CC6CD34F2}](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7B3D4B979C-E741-47D3-923B-CB4CC6CD34F2%7D.png)



# 使用Hector_Mapping进行SLAM建图

## Hector_Mapping体验

```shell
sudo apt install ros-noetic-hector-mapping
```

打开仿真环境

```shell
roslaunch wpr_simulation wpb_stage_slam.launch
```

运行slam节点

```shell
rosrun hector_mapping hector_mapping
```

打开rviz，添加RobotModel, LaserScan, Map

![{4B74A07C-5127-4596-81ED-A65DE9B153F9}](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%257B4B74A07C-5127-4596-81ED-A65DE9B153F9%257D.png)

让机器人动起来，对场景进行建图

```shell
rosrun rqt_robot_steering rqt_robot_steering
```

![{7E97D8A2-21DA-4362-B023-38D4528F437A}](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7B7E97D8A2-21DA-4362-B023-38D4528F437A%7D.png)

![{C257D940-F6E0-4D34-A063-107A83C3B271}](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7BC257D940-F6E0-4D34-A063-107A83C3B271%7D.png)

## 通过launch文件启动Hector_mapping

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7BEF9E895F-0F3E-43F4-BAFD-9CC8B55AF02A%7D.png" alt="{EF9E895F-0F3E-43F4-BAFD-9CC8B55AF02A}" style="zoom:50%;" />

> 文件目录

![{F0FDF24C-D74C-4DFE-8A0D-D5AA02911BC1}](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7BF0FDF24C-D74C-4DFE-8A0D-D5AA02911BC1%7D.png)

> 目标为将上述四条指令集成到launch文件中

编辑`hector.launch`文件，并进行参数设置

```xml
<launch>
    
    <include file="&(find wpr_simulation)/launch/wpb_stage_slam.launch"/>
    
    <node pkg="hector_mapping" type="hector_mapping" name="hector_mapping" output="screen">
    	<param name="map_update_distance_thresh" value="0.1"/>
    </node>
    
    <node pkg="rviz" type="rviz" name="rviz" args="-d $(find slam_pkg)/rviz/slam.rviz"/>
    
    <node pkg="rqt_robot_steering" type="rqt_robot_steering" name="rqt_robot_steering"/>
    
</launch>
```

运行roslaunch文件

```shell
roslaunch slam_pkg hector.launch
```

# ROS的TF系统

## 引入

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7B96A26EA2-81F1-487A-BB19-862DE242FA28%7D.png" alt="{96A26EA2-81F1-487A-BB19-862DE242FA28}" style="zoom:50%;" />

- 地图坐标系 map
- 原点定在机器人地盘投影到地面的中心位置 base_footprint

因为是描述机器人的位置，将map坐标系定义为**父坐标系**，机器人地盘定义为**子坐标系**

两个坐标系的空间关系，可以描述为子坐标系再父坐标系中的x, y, z轴上的**距离值**和**角度值**

## TF系统简介

TF(TransForm)，坐标系变换。

在ros中，坐标系间的变换关系通过话题/tf发布。

![{188903B5-CA7D-46E7-8386-D87D82ACF1EC}](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7B188903B5-CA7D-46E7-8386-D87D82ACF1EC%7D.png)

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7B3C89B02F-2AA0-4320-B93B-CFF9C925C089%7D.png" alt="{3C89B02F-2AA0-4320-B93B-CFF9C925C089}"  />

查看tf话题

```shell
rostopic echo /tf
```

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7BDCD68FEF-A688-4758-88D5-46B59E0CB05E%7D.png" alt="{DCD68FEF-A688-4758-88D5-46B59E0CB05E}" style="zoom:50%;" />

查看tf树

```shell
rosrun rqt_tf_tree rqt_tf_tree
```

![{EF3AE65D-9F52-4EC0-97AB-7E31D21AAEF2}](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7BEF3AE65D-9F52-4EC0-97AB-7E31D21AAEF2%7D.png)