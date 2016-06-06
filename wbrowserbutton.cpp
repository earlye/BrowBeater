#include "wbrowserbutton.h"

#include <iostream>

WBrowserButton::WBrowserButton(std::shared_ptr<Browser const> browser, std::vector<std::string const> urls, QWidget* parent)
    : QPushButton(QString(browser->get_name().c_str()), parent),
      m_browser(browser),
      m_urls(urls)
{
    this->setSizePolicy(QSizePolicy::Expanding,QSizePolicy::Expanding);
    QObject::connect(this, &QPushButton::clicked, this, &WBrowserButton::click);
}

void WBrowserButton::click()
{
    std::cout << "clicked!" << std::endl;

    m_browser->open_urls(m_urls);

    emit afterClick();
}
