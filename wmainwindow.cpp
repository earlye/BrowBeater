#include "wmainwindow.h"
#include "ui_wmainwindow.h"

#include "wbrowserbutton.h"

#include <QLayout>

#include <sstream>

WMainWindow::WMainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::WMainWindow)
{
    ui->setupUi(this);
    ui->scrollAreaWidgetContents->setLayout(new QVBoxLayout());
}

WMainWindow::~WMainWindow()
{
    delete ui;
}

void WMainWindow::add_browser( std::shared_ptr< Browser const > browser , std::vector<std::string const> const& urls )
{
    WBrowserButton* btn = new WBrowserButton(browser,urls,ui->scrollAreaWidgetContents);
    ui->scrollAreaWidgetContents->layout()->addWidget(btn);

    QObject::connect(btn,&WBrowserButton::afterClick,this,&WMainWindow::close);
    btn->show();
}

void WMainWindow::set_urls( std::vector<const std::string> const & urls) {
    std::stringstream status;
    std::string spacer;

    status << "Opening " << urls.size() << " url" << (urls.size() ? "s" : "") << ":";
    for(auto const& url : urls ) {
        status << spacer << url;
        spacer = " ";
    }
    this->statusBar()->showMessage(QString(status.str().c_str()));
}
