ifeq ($(OS),Windows_NT)
$(error Please use Windows Subsystem for Linux)
endif

# WSL else Linux
ifeq ($(shell grep -q microsoft /proc/version 2> /dev/null; echo $$?),0)
WSL=1
RUN:=cmd.exe /c run.cmd
TILED:=$(shell which tiled tiled.exe "/mnt/c/Program Files/Tiled/tiled.exe" | head -n1)
else
RUN:=./run
TILED:=$(shell which tiled | head -n1)
endif

ifeq ($(TILED),)
$(info Tiled Editor not found)
endif

# Variables and paths
PACKAGE_NAME=antibomb
BUILD_PATH=build
# Dependencies
DEPENDS_PATH:=$(BUILD_PATH)/depends
APPIMAGETOOL_PATH:=$(DEPENDS_PATH)/appimagetool.AppImage
APPIMAGETOOL_URL:=https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage
LOVE_WINDOWS_PATH:=$(DEPENDS_PATH)/love-win64.zip
LOVE_WINDOWS_URL:=https://github.com/love2d/love/releases/download/11.3/love-11.3-win64.zip
LOVE_WINDOWS_32_PATH:=$(DEPENDS_PATH)/love-win32.zip
LOVE_WINDOWS_32_URL:=https://github.com/love2d/love/releases/download/11.3/love-11.3-win32.zip
LOVE_APPIMAGE_PATH:=$(DEPENDS_PATH)/love-lin64.AppImage
LOVE_APPIMAGE_URL:=https://github.com/love2d/love/releases/download/11.3/love-11.3-x86_64.AppImage
LOVE_APPIMAGE_32_PATH:=$(DEPENDS_PATH)/love-lin32.AppImage
LOVE_APPIMAGE_32_URL:=https://github.com/love2d/love/releases/download/11.3/love-11.3-i686.AppImage
# Packages
PACKAGE_LOVE_PATH:=$(BUILD_PATH)/$(PACKAGE_NAME).love
PACKAGE_WINDOWS_PATH:=$(BUILD_PATH)/$(PACKAGE_NAME)-win64.zip
PACKAGE_WINDOWS_32_PATH:=$(BUILD_PATH)/$(PACKAGE_NAME)-win32.zip
PACKAGE_APPIMAGE_PATH:=$(BUILD_PATH)/$(PACKAGE_NAME)-lin64.AppImage
PACKAGE_APPIMAGE_32_PATH:=$(BUILD_PATH)/$(PACKAGE_NAME)-lin32.AppImage

# File paths
SOURCE_PATTERNS=*.lua src lib
SOURCE_PATHS:=$(shell find $(SOURCE_PATTERNS) -type f)
ASSET_PATTERNS=asset
ASSET_PATHS:=$(shell find $(ASSET_PATTERNS) -type f)
MAP_PATHS:=$(wildcard asset/raw/map/*)
MAP_EXPORTED_PATHS:=$(patsubst asset/raw/map/%.tmx,asset/map/%.json,$(MAP_PATHS))

# Temporary path variables
RNG_STRING:=$(shell tr -dc a-f0-9 </dev/urandom | head -c 8)
TMP_PATH:=/tmp/make-love-build-$(RNG_STRING)
TMP_WINDOWS_PATH:=$(TMP_PATH)/$(PACKAGE_NAME)-win64
TMP_WINDOWS_32_PATH:=$(TMP_PATH)/$(PACKAGE_NAME)-win32
TMP_APPIMAGE_PATH:=$(TMP_PATH)/$(PACKAGE_NAME)-lin64
TMP_APPIMAGE_32_PATH:=$(TMP_PATH)/$(PACKAGE_NAME)-lin32

# Run run script
.PHONY: run
run: build_maps
	$(RUN) $(PROGRAM_ARGS)

# Tiled map exporting
build_maps: $(MAP_EXPORTED_PATHS)
asset/map/%.json: asset/raw/map/%.tmx
	mkdir -p $(shell dirname "$@")
	"$(TILED)" --export-map json "$<" "$@"

# Package building
.PHONY: all
all: build_love build_win64 build_win32 build_lin64 build_lin32

.PHONY: build_love
build_love: $(PACKAGE_LOVE_PATH)
$(PACKAGE_LOVE_PATH): $(SOURCE_PATHS) $(ASSET_PATHS) $(MAP_EXPORTED_PATHS)
	rm $@ 2> /dev/null || true
	mkdir -p $(shell dirname $@)
	7z a -bd -tzip -mx0 -r $@ $(SOURCE_PATTERNS) $(ASSET_PATTERNS)

.PHONY: build_win64
build_win64: $(PACKAGE_WINDOWS_PATH)
$(PACKAGE_WINDOWS_PATH): $(LOVE_WINDOWS_PATH) $(PACKAGE_LOVE_PATH)
	mkdir -p $(TMP_WINDOWS_PATH)
	7z e -bd $< -o$(TMP_WINDOWS_PATH) '-ir!*.exe' '-ir!*.dll' '-ir!license.txt'
	cat $(PACKAGE_LOVE_PATH) | tee --append $(TMP_WINDOWS_PATH)/love.exe $(TMP_WINDOWS_PATH)/lovec.exe > /dev/null
	mv $(TMP_WINDOWS_PATH)/love.exe $(TMP_WINDOWS_PATH)/$(PACKAGE_NAME).exe
	mv $(TMP_WINDOWS_PATH)/lovec.exe $(TMP_WINDOWS_PATH)/$(PACKAGE_NAME)-console.exe
	rm $@ 2> /dev/null || true
	mkdir -p $(shell dirname $@)
	7z a -bd -tzip -r $@ $(TMP_WINDOWS_PATH)
	rm -rf $(TMP_WINDOWS_PATH) || true
	rmdir $(TMP_PATH) 2> /dev/null || true

.PHONY: build_win32
build_win32: $(PACKAGE_WINDOWS_32_PATH)
$(PACKAGE_WINDOWS_32_PATH): $(LOVE_WINDOWS_32_PATH) $(PACKAGE_LOVE_PATH)
	mkdir -p $(TMP_WINDOWS_32_PATH)
	7z e -bd $< -o$(TMP_WINDOWS_32_PATH) '-ir!*.exe' '-ir!*.dll' '-ir!license.txt'
	cat $(PACKAGE_LOVE_PATH) | tee --append $(TMP_WINDOWS_32_PATH)/love.exe $(TMP_WINDOWS_32_PATH)/lovec.exe > /dev/null
	mv $(TMP_WINDOWS_32_PATH)/love.exe $(TMP_WINDOWS_32_PATH)/$(PACKAGE_NAME).exe
	mv $(TMP_WINDOWS_32_PATH)/lovec.exe $(TMP_WINDOWS_32_PATH)/$(PACKAGE_NAME)-console.exe
	rm $@ 2> /dev/null || true
	mkdir -p $(shell dirname $@)
	7z a -bd -tzip -r $@ $(TMP_WINDOWS_32_PATH)
	rm -rf $(TMP_WINDOWS_32_PATH) || true
	rmdir $(TMP_PATH) 2> /dev/null || true

.PHONY: build_lin64
build_lin64: $(PACKAGE_APPIMAGE_PATH)
$(PACKAGE_APPIMAGE_PATH): $(LOVE_APPIMAGE_PATH) $(APPIMAGETOOL_PATH) $(PACKAGE_LOVE_PATH)
	mkdir -p $(TMP_APPIMAGE_PATH)
	7z x -bd $< -o$(TMP_APPIMAGE_PATH)
	sed -i 's|exec "$${APPIMAGE_DIR}/love" "$$@"|exec "$${APPIMAGE_DIR}/love" "$${APPIMAGE_DIR}/game.love" "$$@"|' $(TMP_APPIMAGE_PATH)/usr/bin/wrapper-love
	cp $(PACKAGE_LOVE_PATH) $(TMP_APPIMAGE_PATH)/game.love
	chmod +x $(TMP_APPIMAGE_PATH)/AppRun $(TMP_APPIMAGE_PATH)/usr/bin/wrapper-love $(TMP_APPIMAGE_PATH)/love $(TMP_APPIMAGE_PATH)/usr/bin/love
	chmod +x $(APPIMAGETOOL_PATH)
	$(APPIMAGETOOL_PATH) $(TMP_APPIMAGE_PATH) $@
	rm -rf $(TMP_APPIMAGE_PATH) || true
	rmdir $(TMP_PATH) 2> /dev/null || true

.PHONY: build_lin32
build_lin32: $(PACKAGE_APPIMAGE_32_PATH)
$(PACKAGE_APPIMAGE_32_PATH): $(LOVE_APPIMAGE_32_PATH) $(APPIMAGETOOL_PATH) $(PACKAGE_LOVE_PATH)
	mkdir -p $(TMP_APPIMAGE_32_PATH)
	7z x -bd $< -o$(TMP_APPIMAGE_32_PATH)
	sed -i 's|exec "$${APPIMAGE_DIR}/love" "$$@"|exec "$${APPIMAGE_DIR}/love" "$${APPIMAGE_DIR}/game.love" "$$@"|' $(TMP_APPIMAGE_32_PATH)/usr/bin/wrapper-love
	cp $(PACKAGE_LOVE_PATH) $(TMP_APPIMAGE_32_PATH)/game.love
	chmod +x $(TMP_APPIMAGE_32_PATH)/AppRun $(TMP_APPIMAGE_32_PATH)/usr/bin/wrapper-love $(TMP_APPIMAGE_32_PATH)/love $(TMP_APPIMAGE_32_PATH)/usr/bin/love
	chmod +x $(APPIMAGETOOL_PATH)
	$(APPIMAGETOOL_PATH) $(TMP_APPIMAGE_32_PATH) $@
	rm -rf $(TMP_APPIMAGE_32_PATH) || true
	rmdir $(TMP_PATH) 2> /dev/null || true

# Dependency downloads
$(LOVE_WINDOWS_PATH):
	mkdir -p $(shell dirname $@)
	curl -L $(LOVE_WINDOWS_URL) -o $@

$(LOVE_WINDOWS_32_PATH):
	mkdir -p $(shell dirname $@)
	curl -L $(LOVE_WINDOWS_32_URL) -o $@

$(LOVE_APPIMAGE_PATH):
	mkdir -p $(shell dirname $@)
	curl -L $(LOVE_APPIMAGE_URL) -o $@

$(LOVE_APPIMAGE_32_PATH):
	mkdir -p $(shell dirname $@)
	curl -L $(LOVE_APPIMAGE_32_URL) -o $@

$(APPIMAGETOOL_PATH):
	mkdir -p $(shell dirname $@)
	curl -L $(APPIMAGETOOL_URL) -o $@

.PHONY: clean
clean:
	rm -rf $(BUILD_PATH)
	rm $(MAP_EXPORTED_PATHS) || true
