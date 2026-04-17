#include "browbeaterapplication.h"

#include "platform_interface.hpp"

#include <QFileOpenEvent>

#ifdef Q_QDOC
    BrowBeaterApplication::BrowBeaterApplication(int &argc, char **argv)
        : QApplication(argc,argv)
#else
    BrowBeaterApplication::BrowBeaterApplication(int &argc, char **argv, int applicationFlags /* = ApplicationFlags */)
        : QApplication(argc,argv,applicationFlags)
#endif
    {
    }

    BrowBeaterApplication::~BrowBeaterApplication()
    {
    }

    bool BrowBeaterApplication::event(QFileOpenEvent *theEvent)
    {
        std::string url = theEvent->url().toString().toStdString();

        if (url.length()) {
            std::vector<std::string> urls;
            urls.push_back(url);
            mainWindow.set_urls(urls);
            mainWindow.show();
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
