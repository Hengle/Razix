-- Configuration settings
require 'Scripts/premake-config'

-- Workspace Settings
settings = { }
settings.workspace_name     = 'Razix'
settings.bundle_identifier  = 'com.PhaniSrikar'

outputdir = "%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}"

-- Current root directory where the global premake file is located
-- TODO: Use a fixed installation directory in program files insted of an arbitrary thing/ infact use this to verify the proper installation directory 
root_dir = os.getcwd()

-- Using the command line to get the selected architecture
Arch = ""

if _OPTIONS["arch"] then
    Arch = _OPTIONS["arch"]
else
    if _OPTIONS["os"] then
        _OPTIONS["arch"] = "arm"
        Arch = "arm"
    else
        _OPTIONS["arch"] = "x64"
        Arch = "x64"
    end
end

-- The Razix Engine Workspace
workspace ( settings.workspace_name )
    location "build"
    startproject "Sandbox"
    flags 'MultiProcessorCompile'

    -- Output directory path based on build config
    outputdir = "%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}"
    -- Binaries Output directory
    targetdir ("bin/%{outputdir}/")
    -- Intermediate files Output directory
    objdir ("bin-int/%{outputdir}/obj/")

    -- Setting the architecture for the workspace
    if Arch == "arm" then
        architecture "ARM"
    elseif Arch == "x64" then
        architecture "x86_64"
    elseif Arch == "x86" then
        architecture "x86"
    end

    print("Generating Project files for Architecture = ", Arch)

    -- Various build configuration for the engine
    configurations
    {
        "Debug",
        "Release",
        "Distribution"
    }

    -- Build scripts for the Razix vendor dependencies
    group "Dependencies"
        require("Engine/vendor/cereal/premake5")
        require("Engine/vendor/glfw/premake5")
        require("Engine/vendor/imgui/premake5")
        require("Engine/vendor/spdlog/premake5")
    group ""

    -- Build Script for Razix Engine
    --------------------------------------------------------------------------------
    group "Engine"
        include "Engine/premake5"
    group ""
    --------------------------------------------------------------------------------

    -- Build script for Sandbox
    --group "Sandbox"
        include "Sandbox/premake5"
    --group ""

    -- Engine related tools\
    -- TODO: Add a project here that outputs the Engine Version and Signanture when run (Using RazixVersion.h), depneds on the same config as Razix Engine (Used by GitHub workflow for creating releases automatically)
    group "Tools/Build"
            -- premake scripts Utility project for in IDE management
            include "Tools/Build/premake/premake5"
            -- Gets the version of the Engine for Build workflows
            include "Tools/Build/RazixVersion/premake5"
    group ""

    -- TODO: Tests (recrusively projects are added)
    -- TODO: Samples