# The Developmentimage for ROS2 Cuisine

## System Requirements


- Prozessor: amd64, arm32v7 or arm64v8
- RAM
  - 1.5 GB free RAM
  - 2+ GB for simulations (can be in an other machines)
- Software
  - Docker Engine to run Linuxcontainer
## Working with the image

Create a .devcontainer folder in your project and add a Dockerfile containing the line

```Dockerfile
FROM ros2cuisine/vsc-master:latest
```

followed by your custom instructions
have a look at [Cuisine](https://gitlab.com/ros2cuisine/cuisine.git) as an example 
