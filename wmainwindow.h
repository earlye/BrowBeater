#ifndef WMAINWINDOW_H
#define WMAINWINDOW_H

#include <QMainWindow>

#include "platform_interface.hpp"

namespace Ui {
class WMainWindow;
}

class WMainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit WMainWindow(QWidget *parent = 0);
    ~WMainWindow();

    void add_browser( std::shared_ptr< Browser const > browser );
    void set_urls( std::vector< std::string const > const& urls );
    void keyPressEvent(QKeyEvent *event); // declaration

public Q_SLOTS:
    void refreshStatus();
    void theFocusChanged(QWidget*,QWidget*);
    void getUrls(std::vector<std::string const>& urls);

private:
    Ui::WMainWindow *ui;
    std::vector< std::string const > m_urls;
    QWidget* prevWidget;
    QWidget* firstWidget;
};

#endif // WMAINWINDOW_H
