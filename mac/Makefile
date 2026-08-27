SVG     := icon.svg
ICONSET := browbeater.iconset
ICNS    := browbeater.icns
QMAKE   ?= /opt/homebrew/opt/qt@5/bin/qmake

PNGS := icon16.png icon32.png icon64.png icon128.png icon256.png icon512.png icon1024.png

.PHONY: all icns browbeater.app clean

all: browbeater.app

browbeater.app: icns
	cd .. && $(QMAKE) BrowBeater.pro && $(MAKE)

.PHONY: icns
icns: $(ICNS)

icon%.png: $(SVG)
	inkscape -w $* -h $* --export-filename=$@ $<

$(ICNS): $(PNGS)
	mkdir -p $(ICONSET)
	cp icon16.png   $(ICONSET)/icon_16x16.png
	cp icon32.png   $(ICONSET)/icon_16x16@2x.png
	cp icon32.png   $(ICONSET)/icon_32x32.png
	cp icon64.png   $(ICONSET)/icon_32x32@2x.png
	cp icon128.png  $(ICONSET)/icon_128x128.png
	cp icon256.png  $(ICONSET)/icon_128x128@2x.png
	cp icon256.png  $(ICONSET)/icon_256x256.png
	cp icon512.png  $(ICONSET)/icon_256x256@2x.png
	cp icon512.png  $(ICONSET)/icon_512x512.png
	cp icon1024.png $(ICONSET)/icon_512x512@2x.png
	iconutil -c icns -o $@ $(ICONSET)

clean:
	rm -f $(PNGS)
	rm -rf $(ICONSET)
