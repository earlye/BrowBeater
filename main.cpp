#include "wmainwindow.h"

#include "BrowserRegistrar.hpp"

#include <QApplication>
#include <iostream>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    WMainWindow w;

    std::vector< std::string const > urls;
    for (int i = 1; i < argc; ++i) {
        urls.push_back(std::string(argv[i]));
    }

    if (!urls.size()) {
        std::cerr << "Usage: BrowBeater {url}+" << std::endl;
        return 0;
    }

    std::shared_ptr< BrowserRegistrar > registrar = getBrowserRegistrar();
    std::vector< std::shared_ptr< Browser > > browsers = registrar->listBrowsers();
    for( auto const& browser : browsers )
      {
        w.add_browser(browser,urls);
      }
    
    w.set_urls(urls);
    w.show();

    return a.exec();
}
