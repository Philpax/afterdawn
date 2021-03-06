-- Return paths relative to where vespertine is
function RerootPath(path)
	return "vespertine/" .. path
end

function RerootPaths(paths)
	ret = {}
	for _, v in pairs(paths) do
		table.insert(ret, RerootPath(v))
	end
	return ret
end

solution "Afterdawn"
	configurations { "Debug", "Release" }

	startproject "Afterdawn"

	-- Include the vespertine project in this solution
	include "vespertine/premake5.lua"

	project "Afterdawn"
		kind "WindowedApp"
		language "C++"
		targetdir "bin/%{cfg.buildcfg}"
		debugdir "bin/%{cfg.buildcfg}"

		includedirs(RerootPaths(VENDOR_INCLUDES))
		includedirs { "vespertine/include/", "include/" }
		files { "include/**.hpp", "src/**.cpp" }
		flags { "FatalWarnings", "WinMain", "Symbols" }
		exceptionhandling "Off"
		rtti "Off"

		links { "Vespertine", "dxgi", "d3d11", "d3dcompiler" }
		links(RerootPaths(VENDOR_LINKS.all))
		postbuildcommands 
		{ 
			[[{COPY} %{RerootPath "data"} bin/%{cfg.buildcfg}/data]] 
		}

		filter "configurations:Debug"
			defines { "DEBUG", "_ITERATOR_DEBUG_LEVEL=0" }
			flags { "Symbols" }
			links(RerootPaths(VENDOR_LINKS.debug))
			filter { "configurations:Debug", "action:vs*" }
				ignoredefaultlibraries { "libcmt" }

		filter "configurations:Release"
			defines { "NDEBUG" }
			optimize "On"
			links(RerootPaths(VENDOR_LINKS.release))

		configuration { "vs*" }
			editandcontinue "off"
			buildoptions { "/EHsc" }

		configuration { "gmake" }
			buildoptions { "-std=c++11" }