#ifndef WBROWSERBUTTON_H
#define WBROWSERBUTTON_H

#include "BrowserRegistrar.hpp"

#include <QPushButton>

class WBrowserButton : public QPushButton
{
    Q_OBJECT

public:
    WBrowserButton(std::shared_ptr<Browser const> browser, std::vector< std::string const > urls, QWidget* owner);

public Q_SLOTS:
    void click();

Q_SIGNALS:
    void afterClick();

private:
    std::shared_ptr<Browser const> m_browser;
    std::vector< std::string const > m_urls;
};

#endif // WBROWSERBUTTON_H
