#ifndef WBROWSERBUTTON_H
#define WBROWSERBUTTON_H

#include "platform_interface.hpp"

#include <QPushButton>

class WBrowserButton : public QPushButton
{
    Q_OBJECT

public:
    WBrowserButton(std::shared_ptr<Browser const> browser, QWidget* owner);

public Q_SLOTS:
    void click();

Q_SIGNALS:
    void getUrls(std::vector<std::string const>& urls);
    void afterClick();

private:
    std::shared_ptr<Browser const> m_browser;
};

#endif // WBROWSERBUTTON_H
