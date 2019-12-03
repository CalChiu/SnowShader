# Snow Shader
This is a simple solution to generate snow for your Unity scene via 100% post processing in camera space (without alternating the game objects' respective shaders).

# Technologies Used/Requirements
- Tested for Unity 2018.4.4f1

# Assets
- SnowShader.shader: Main shader for postprocessing (for camera, not intended for material rendering).
- CameraSnowScript.cs: Script tool to attach to your Main camera as shown in example scene.

# Installation
You need to attach the CameraSnowScript component to the camera that will render the snow. If you have objects that should not have snow on them, please use a combination of multiple cameras, culling masks, and camera depth.

# License
MIT
