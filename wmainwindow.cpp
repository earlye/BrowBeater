#include "wmainwindow.h"
#include "ui_wmainwindow.h"

#include "wbrowserbutton.h"

#include <QKeyEvent>
#include <QLayout>

#include <iostream>
#include <sstream>

WMainWindow::WMainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::WMainWindow)
{
    ui->setupUi(this);
    ui->scrollAreaWidgetContents->setLayout(new QVBoxLayout());
    setWindowFlags(Qt::Window | Qt::FramelessWindowHint);
    ui->scrollArea->setFocusPolicy(Qt::NoFocus);
    prevWidget = NULL;
    firstWidget = NULL;
    //QObject::connect(this,&WMainWindow::,this,&WMainWindow::close);
    QObject* app = QApplication::instance();
    connect(app,SIGNAL(focusChanged(QWidget*, QWidget*)),this,SLOT(theFocusChanged(QWidget*, QWidget*)));
}

WMainWindow::~WMainWindow()
{
    delete ui;
}

void WMainWindow::add_browser(std::shared_ptr< Browser const > browser)
{
    WBrowserButton* btn = new WBrowserButton(browser,ui->scrollAreaWidgetContents);
    ui->scrollAreaWidgetContents->layout()->addWidget(btn);

    QObject::connect(btn,&WBrowserButton::afterClick,this,&WMainWindow::close);
    QObject::connect(btn,&WBrowserButton::getUrls,this,&WMainWindow::getUrls);
    btn->setFocusPolicy(Qt::StrongFocus);
    btn->setAutoDefault(true);
    btn->show();
    if (firstWidget == NULL) {
        btn->setFocus();
        setFocusProxy(btn);
        firstWidget = btn;
    }
    setTabOrder(prevWidget,btn);
    prevWidget = btn;
}

void WMainWindow::getUrls(std::vector<std::string const>& urls) {
    std::cout << "getUrls:" << urls.size() << std::endl;
    urls.clear();
    std::copy( m_urls.begin(),m_urls.end(), std::back_inserter(urls) );
}

void WMainWindow::set_urls(std::vector<const std::string> const & urls) {

    m_urls.clear();
    std::copy(urls.begin(),urls.end(),std::back_inserter(m_urls));

    refreshStatus();
}

void WMainWindow::refreshStatus() {
    std::stringstream status;
    std::string spacer;

#ifdef Q_DEBUG
    QWidget* focused = QApplication::focusWidget();
    if (focused)
    {
        status << spacer << "FocusWidget:" << typeid(*focused).name();
        spacer = " ";
    }
#endif

    status << spacer << "Opening " << m_urls.size() << " url" << (m_urls.size() > 1 ? "s" : "") << ":";
    for(auto const& url : m_urls ) {
        status << spacer << url;
        spacer = " ";
    }
    this->statusBar()->showMessage(QString(status.str().c_str()));
}

void WMainWindow::theFocusChanged(QWidget*,QWidget*)
{
    refreshStatus();
}


void WMainWindow::keyPressEvent(QKeyEvent *keyEvent)
{
    if (keyEvent->key() == Qt::Key_Escape)
    {
        close();
    }
}
