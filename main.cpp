#include "wmainwindow.h"

#include "browbeaterapplication.h"
#include "platform_interface.hpp"

#include <QApplication>
#include <iostream>

int main(int argc, char *argv[])
{
    BrowBeaterApplication a(argc, argv);

    registerApplication(argv[0]);

    std::shared_ptr< BrowserRegistrar > registrar = getBrowserRegistrar();
    std::vector< std::shared_ptr< Browser > > browsers = registrar->listBrowsers();
    for( auto const& browser : browsers )
      {
        a.getMainWindow().add_browser(browser);
      }

    std::vector< std::string const > urls;
    for (int i = 1; i < argc; ++i) {
        urls.push_back(std::string(argv[i]));
    }

    if (urls.size()) {
        a.getMainWindow().set_urls(urls);
        a.getMainWindow().show();
    }


    return a.exec();
}
