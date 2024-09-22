# 简介

​	IMU(Inertial Measurement Unit)，即惯性测量单元。是安装在机器人内部的传感器模块，用于测量机器人的空间姿态。

## ROS中IMU的消息包

IMU通常会输出一个根据裸数据融合得到的空间姿态描述orientation。描述了机器人在空间中XYZ三个坐标轴的偏移量。

![{FBF6A32B-B4D5-445D-A5C8-92A83D7AE9AF}](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/%7BFBF6A32B-B4D5-445D-A5C8-92A83D7AE9AF%7D.png)

输出的是x,y,z,w四元数。

本次代码需要使用TF工具将四元数转换成欧拉角。

# 代码实现

## C++写法

```cpp
#include "ros/ros.h"
#include "sensor_msgs/Imu.h"
#include "tf/tf.h"

void IMUCallback(sensor_msgs::Imu msg)
{
    if(msg.orientation_covariance[0] < 0) return;
    tf::Quaternion quaternion(
        msg.orientation.x,
        msg.orientation.y,
        msg.orientation.z,
        msg.orientation.w
    );// 将四元数转化为rpy
    
    double roll, pitch, yaw;
    tf::Matrix3x3(quaternion).getRPY(roll, pitch, yaw);
    // 此处的rpy是弧度制，转换成角度制，则roll = roll*180/M_PI
    
}

int main(int argc, char *argv[])
{
    ros::init(argc, argv, "imu_node");
    ros::NodeHandle n;
    ros::Subscriber imu_sub = n.subscribe("/imu/data", 10, IMUCallback);
    
    ros::spin();
    
    return 0;
}
```

## Python写法

```python
#!/usr/bin/env python3
#coding=utf-8

import rospy
from sensor_msgs.msg import Imu
from tf.transformations import euler_from_quaterion
import math

def imu_callback(msg):
    if msg.orientation_covariance[0] < 0:
        return
    
    quaternion = [
        msg.orientation.x,
        msg.orientation.y,
        msg.orientation.z,
        msg.orientation.w
    ]
    (roll,pitch,yaw) = euler_from_quaternion(quaternion)
    
if __name__ == "__main__":
    rospy.init_node("imu_node")
    imu_sub = rospy.Subscriber("/imu/data", Imu, imu_callback, queue_size=10)
    rospy.spin()
```

