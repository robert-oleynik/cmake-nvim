# cmake-nvim

## Introduction

cmake-nvim integrates [cmake](https://cmake.org/) into [neovim](https://neovim.io/).
Using this plugin user can configure and build projects, define multiple cmake configurations and switch between build types.
This plugin is inspired by `vector-of-bool`'s [CMake Tools](https://github.com/microsoft/vscode-cmake-tools) for `vscode`

## Quick Start

For using cmake-nvim a `settings.json` file is required. This file is used to
store the configurations. The `settings.json` file is located in the project's root
directory next to the `CMakeLists.txt` file.

Project structure:

    project_name
      ├─ ...
      ├─ CMakeLists.txt
      └─ settings.json

Example `settings.json` file:
```json
{
    "cmake": {
        "configurations": [
            {
                "name": "clang",
                "build_dir": "./build/%name%/%build_type%",
                "definitions": {
                    "CMAKE_C_COMPILER": "clang",
                    "CMAKE_CXX_COMPILER": "clang++"
                }
            }
        ]
    }
}
```

To configure cmake run:

    :CMakeConfigure

To build the project run:

    :CMakeBuild

To clean config directory run:

    :CMakeClean

To edit `settings.json` file run:

    :CMakeOpenSettings

## Roadmap

- [x] Use multiple configurations
- [x] Switch between build types and configurations
- [x] Generate link for `compile_commands.json`
- [x] Display cmake errors in list
- [x] Display build errors in list
- [ ] Run ctest and display results in test explorer
- [X] Build single target
- [X] Clean cmake build directory

## Installation

Install with [vim-plug](https://github.com/junegunn/vim-plug)

    Plug 'robert-oleynik/cmake-nvim'

## Docs

See `:h cmake-nvim.txt` or [doc/cmake-nvim.txt](https://gitlab.com/robert-oleynik/cmake-nvim/-/blob/main/doc/cmake-nvim.txt)

## Commands

### :CMakeConfigure

    Run CMake to configure project. Uses current selected config. If no config
    is selected, the first config is used. Opens quickfix on error.

### :CMakeBuild [<target>]

    Run CMake to build project. Uses current selected config. If no config is
    selected, the first config is used. Opens quickfix on error. If target is
    specified cmake only builds this target (Note: adds option 
    `--target <target>`).

### :CMakeClean

    Remove all built objects and other output files from build directory.

### :CMakeClear

    Remove all files from current build directory. The directory is specified
    by selected config. If no config is selected, the first config is used.

### :CMakeOpenSettings

    Start edit `settings.json` file.

### :CMakeLoadSettings

    Reload `settings.json`. Resets the build type and selected config (Note: 
    The `settings.json` fill will be reloaded on file save and root directory
    changes)

### :CMakeSelectBuildType [<build_type>]

    Sets current cmake build type. If not build type is specified, a dialog for
    selection is opened.

### :CMakeSelectConfig [<config_name>]

    Set current config name. If no name is specified, a dialog for selection is
    opened.

### :CMakePrintBuildType

    Prints current cmake build type.

### :CMakePrintConfig

    Prints name of selected configuration.
