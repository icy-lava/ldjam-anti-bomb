ifeq ($(OS),Windows_NT)
$(error Please use Windows Subsystem for Linux)
endif

RUN=./run

BINARY_NAME=game
BUILD_DIRECTORY=build

# .love
BINARY_LOVE_PATH_DIRECTORY=$(BUILD_DIRECTORY)
BINARY_LOVE_PATH=$(BINARY_LOVE_PATH_DIRECTORY)/$(BINARY_NAME).love

# .exe (x86-64)
BINARY_EXE_DIRECTORY=$(BUILD_DIRECTORY)/$(BINARY_NAME)_win64
BINARY_EXE_PATH=$(BINARY_EXE_DIRECTORY)/love.exe
BINARY_EXE_C_PATH=$(BINARY_EXE_DIRECTORY)/lovec.exe
LOVE_EXE_PATH=$(BUILD_DIRECTORY)/love_exe_64.zip
LOVE_EXE_URL=https://github.com/love2d/love/releases/download/11.3/love-11.3-win64.zip

# .exe (x86)
BINARY_EXE_32_DIRECTORY=$(BUILD_DIRECTORY)/$(BINARY_NAME)_win32
BINARY_EXE_32_PATH=$(BINARY_EXE_32_DIRECTORY)/love.exe
BINARY_EXE_32_C_PATH=$(BINARY_EXE_32_DIRECTORY)/lovec.exe
LOVE_EXE_32_PATH=$(BUILD_DIRECTORY)/love_exe_32.zip
LOVE_EXE_32_URL=https://github.com/love2d/love/releases/download/11.3/love-11.3-win32.zip

# AppImage tool (asumed x86-64 build machine)
APPIMAGE_TOOL_DIRECTORY=$(BUILD_DIRECTORY)
APPIMAGE_TOOL_PATH=$(APPIMAGE_TOOL_DIRECTORY)/appimagetool.AppImage
APPIMAGE_TOOL_URL=https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage

# .AppImage (x86-64)
BINARY_APPIMAGE_DIRECTORY=$(BUILD_DIRECTORY)
BINARY_APPIMAGE_FOLDER=$(BINARY_APPIMAGE_DIRECTORY)/$(BINARY_NAME)_appimage64
BINARY_APPIMAGE_PATH=$(BINARY_APPIMAGE_DIRECTORY)/$(BINARY_NAME)_appimage64.AppImage
LOVE_APPIMAGE_PATH=$(BUILD_DIRECTORY)/love_appimage_64.AppImage
LOVE_APPIMAGE_URL=https://github.com/love2d/love/releases/download/11.3/love-11.3-x86_64.AppImage

# .AppImage (x86)
BINARY_APPIMAGE_32_DIRECTORY=$(BUILD_DIRECTORY)
BINARY_APPIMAGE_32_FOLDER=$(BINARY_APPIMAGE_DIRECTORY)/$(BINARY_NAME)_appimage32
BINARY_APPIMAGE_32_PATH=$(BINARY_APPIMAGE_DIRECTORY)/$(BINARY_NAME)_appimage32.AppImage
LOVE_APPIMAGE_32_PATH=$(BUILD_DIRECTORY)/love_appimage_32.AppImage
LOVE_APPIMAGE_32_URL=https://github.com/love2d/love/releases/download/11.3/love-11.3-i686.AppImage

SOURCE_FILES=$(wildcard *.lua) $(shell find src lib -type f)
ASSET_FILES=$(shell find asset -type f)

MAPS = $(wildcard asset/raw/map/*)
MAPS_EXPORTED = $(patsubst asset/raw/map/%.tmx,asset/map/%.json,$(MAPS))

TILED=tiled

# Check for WSL
ifeq ($(shell grep -q microsoft /proc/version 2> /dev/null; echo $$?),0)
WSL=1
RUN=cmd.exe /c run.cmd
TILED=$(shell which tiled tiled.exe "/mnt/c/Program Files/Tiled/tiled.exe" | head -n1)
ifeq ($(TILED),)
$(error Tiled not found)
endif
endif

.PHONY: run build_all $(BINARY_LOVE_PATH) build_exe build_exe_32 build_appimage clean compile_all tiled_compile recompile

run: compile_all
	$(RUN) $(PROGRAM_ARGS)

build_all: compile_all $(BINARY_LOVE_PATH) build_exe build_exe_32 build_appimage build_appimage_32

build_appimage: $(BINARY_APPIMAGE_PATH)
build_appimage_32: $(BINARY_APPIMAGE_32_PATH)
build_exe: $(BINARY_EXE_PATH) $(BINARY_EXE_C_PATH)
build_exe_32: $(BINARY_EXE_32_PATH) $(BINARY_EXE_32_C_PATH)

$(BINARY_LOVE_PATH): compile_all $(SOURCE_FILES) $(ASSET_FILES)
	rm "$(BINARY_LOVE_PATH)" 2> /dev/null || true
	mkdir -p "$(BINARY_LOVE_PATH_DIRECTORY)"
	7z a -bd -tzip -stl -mx0 -r "$(BINARY_LOVE_PATH)" *.lua src lib asset

$(LOVE_EXE_PATH):
	mkdir -p $(shell dirname "$@")
	curl -L "$(LOVE_EXE_URL)" -o "$@"

$(LOVE_EXE_32_PATH):
	mkdir -p $(shell dirname "$@")
	curl -L "$(LOVE_EXE_32_URL)" -o "$@"

$(BINARY_EXE_PATH) $(BINARY_EXE_C_PATH): $(LOVE_EXE_PATH) $(BINARY_LOVE_PATH)
	rm $(BINARY_EXE_DIRECTORY)/* 2> /dev/null || true
	mkdir -p "$(BINARY_EXE_DIRECTORY)"
	7z e -bd "$(LOVE_EXE_PATH)" "-o$(BINARY_EXE_DIRECTORY)" '-ir!*.exe' '-ir!*.dll' '-ir!license.txt'
	cat "$(BINARY_LOVE_PATH)" | tee --append $(BINARY_EXE_PATH) $(BINARY_EXE_C_PATH) > /dev/null

$(BINARY_EXE_32_PATH) $(BINARY_EXE_32_C_PATH): $(LOVE_EXE_32_PATH) $(BINARY_LOVE_PATH)
	rm $(BINARY_EXE_32_DIRECTORY)/* 2> /dev/null || true
	mkdir -p "$(BINARY_EXE_32_DIRECTORY)"
	7z e -bd "$(LOVE_EXE_32_PATH)" "-o$(BINARY_EXE_32_DIRECTORY)" '-ir!*.exe' '-ir!*.dll' '-ir!license.txt'
	cat "$(BINARY_LOVE_PATH)" | tee --append $(BINARY_EXE_32_PATH) $(BINARY_EXE_32_C_PATH) > /dev/null

$(APPIMAGE_TOOL_PATH):
	mkdir -p $(shell dirname "$@")
	curl -L "$(APPIMAGE_TOOL_URL)" -o "$@"
	chmod +x "$@"
	
$(LOVE_APPIMAGE_PATH):
	mkdir -p $(shell dirname "$@")
	curl -L "$(LOVE_APPIMAGE_URL)" -o "$@"

$(BINARY_APPIMAGE_FOLDER): $(BINARY_LOVE_PATH) $(LOVE_APPIMAGE_PATH)
	rm -rf $(BINARY_APPIMAGE_FOLDER) 2> /dev/null || true
	mkdir -p "$(BINARY_APPIMAGE_FOLDER)"
	7z x -bd "$(LOVE_APPIMAGE_PATH)" "-o$(BINARY_APPIMAGE_FOLDER)"
	sed -i 's|exec "$${APPIMAGE_DIR}/love" "$$@"|exec "$${APPIMAGE_DIR}/love" "$${APPIMAGE_DIR}/game.love" "$$@"|' $(BINARY_APPIMAGE_FOLDER)/usr/bin/wrapper-love
	cp $< $(BINARY_APPIMAGE_FOLDER)/game.love

$(BINARY_APPIMAGE_PATH): $(BINARY_APPIMAGE_FOLDER) $(APPIMAGE_TOOL_PATH)
	$(APPIMAGE_TOOL_PATH) $< $(BINARY_APPIMAGE_PATH)
	
$(LOVE_APPIMAGE_32_PATH):
	mkdir -p $(shell dirname "$@")
	curl -L "$(LOVE_APPIMAGE_32_URL)" -o "$@"

$(BINARY_APPIMAGE_32_FOLDER): $(BINARY_LOVE_32_PATH) $(LOVE_APPIMAGE_32_PATH)
	rm -rf $(BINARY_APPIMAGE_32_FOLDER) 2> /dev/null || true
	mkdir -p "$(BINARY_APPIMAGE_32_FOLDER)"
	7z x -bd "$(LOVE_APPIMAGE_32_PATH)" "-o$(BINARY_APPIMAGE_32_FOLDER)"
	sed -i 's|exec "$${APPIMAGE_DIR}/love" "$$@"|exec "$${APPIMAGE_DIR}/love" "$${APPIMAGE_DIR}/game.love" "$$@"|' $(BINARY_APPIMAGE_32_FOLDER)/usr/bin/wrapper-love
	cp $< $(BINARY_APPIMAGE_32_FOLDER)/game.love

$(BINARY_APPIMAGE_32_PATH): $(BINARY_APPIMAGE_32_FOLDER) $(APPIMAGE_TOOL_PATH)
	$(APPIMAGE_TOOL_PATH) $< $(BINARY_APPIMAGE_32_PATH)

recompile: clean compile_all
compile_all: tiled_compile

clean:
	rm -rf $(BUILD_DIRECTORY)
	rm $(wildcard asset/map/*.json)

tiled_compile: $(MAPS_EXPORTED)

asset/map/%.json: asset/raw/map/%.tmx
	mkdir -p $(shell dirname "$@")
	"$(TILED)" --export-map json "$<" "$@"
