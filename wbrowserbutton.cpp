#include "wbrowserbutton.h"

#include <iostream>

WBrowserButton::WBrowserButton(std::shared_ptr<Browser const> browser, QWidget* parent)
    : QPushButton(QString(browser->get_name().c_str()), parent),
      m_browser(browser)
{
    this->setSizePolicy(QSizePolicy::Expanding,QSizePolicy::Expanding);
    QObject::connect(this, &QPushButton::clicked, this, &WBrowserButton::click);
    setStyleSheet("QPushButton { background-color: #0188cc; color: #ffffff; outline: none }"
                  "QPushButton:focus {  background-color: #000000; color: #ffffff; border: none }");
}

void WBrowserButton::click()
{
    std::cout << "clicked!" << std::endl;

    std::vector<std::string const> urls;

    emit getUrls(urls);

    std::cout << "urls:" << std::endl;
    m_browser->open_urls(urls);

    emit afterClick();
}
