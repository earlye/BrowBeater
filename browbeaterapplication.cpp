#include "browbeaterapplication.h"

#include "platform_interface.hpp"

#include <QFileOpenEvent>

#include <iostream>

#ifdef Q_QDOC
    BrowBeaterApplication::BrowBeaterApplication(int &argc, char **argv)
        : QApplication(argc,argv)
#else
    BrowBeaterApplication::BrowBeaterApplication(int &argc, char **argv, int applicationFlags /* = ApplicationFlags */)
        : QApplication(argc,argv,applicationFlags)
#endif
    {
//        connectOs(*this);
    }

    BrowBeaterApplication::~BrowBeaterApplication()
    {
//        disconnectOs(*this);
    }

    bool BrowBeaterApplication::event(QFileOpenEvent *theEvent)
    {
        std::string url = theEvent->url().toString().toStdString();

        if (url.length()) {

            std::vector< std::string const > urls;
            urls.push_back(url);
            if (urls.size()) {
                mainWindow.set_urls(urls);
                mainWindow.show();
            }
        }
        return QApplication::event(theEvent);
    }


    bool BrowBeaterApplication::event(QEvent *theEvent)
    {
        if (theEvent->type() == QEvent::FileOpen) {
            return event(static_cast<QFileOpenEvent *>(theEvent));
        }
        return QApplication::event(theEvent);
    }
