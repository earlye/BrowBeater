#ifndef BROWBEATERAPPLICATION_H
#define BROWBEATERAPPLICATION_H

#include <QApplication>
#include <QEvent>
#include <QFileOpenEvent>

#include "wmainwindow.h"

class BrowBeaterApplication : public QApplication
{
public:
#ifdef Q_QDOC
    BrowBeaterApplication(int &argc, char **argv);
#else
    BrowBeaterApplication(int &argc, char **argv, int applicationFlags = ApplicationFlags);
#endif
    ~BrowBeaterApplication();

public:
    bool event(QEvent *event);
    bool event(QFileOpenEvent* event);

    WMainWindow& getMainWindow() { return mainWindow; }
private:
    WMainWindow mainWindow;
};

#endif // BROWBEATERAPPLICATION_H
