#-------------------------------------------------
#
# Project created by QtCreator 2016-06-02T14:07:31
#
#-------------------------------------------------

QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = BrowBeater
TEMPLATE = app


SOURCES += main.cpp\
        wmainwindow.cpp \
    wbrowserbutton.cpp


HEADERS  += wmainwindow.h \
    wbrowserbutton.h \
    platform_interface.hpp

FORMS    += wmainwindow.ui

mac {
  OBJECTIVE_SOURCES += platform_osx.mm
  LIBS += -framework AppKit
  QMAKE_INFO_PLIST += mac/info.plist
  DISTFILES += mac/browbeater.icns

  PkgInfo.target      =   PkgInfo
  PkgInfo.depends     =
  PkgInfo.commands    =   echo "APPLWISPR" > BrowBeater.app/Contents/PkgInfo
  QMAKE_EXTRA_TARGETS +=  PkgInfo
  PRE_TARGETDEPS      +=  PkgInfo

  icons.target        = icons
  icons.depends       = mac/browbeater.icns
  icons.commands      = cp $< BrowBeater.app/Contents/Resources/
  QMAKE_EXTRA_TARGETS += icons
  PRE_TARGETDEPS      += icons                        
}

