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
    BrowserRegistrar.hpp

FORMS    += wmainwindow.ui

mac {
  OBJECTIVE_SOURCES += osx.mm
  LIBS += -framework AppKit
}
