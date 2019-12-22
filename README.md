# The Developmentimage for ROS2 Cuisine

## Pulling the image

```bash
docker pull ros2cuisine/vsc-master:latest
```

## Working with the image

Create a .devcontainer folder in your project and add a Dockerfile containing the line

```Dockerfile
FROM ros2cuisine/vsc-master:latest
```

followed by your custom instructions
have a look at [Cuisine](https://gitlab.com/ros2cuisine/cuisine.git) as an example usage
