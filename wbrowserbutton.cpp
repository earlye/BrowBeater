#include "wbrowserbutton.h"

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
    emit browserSelected(m_browser);
}
