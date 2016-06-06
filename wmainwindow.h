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

    void add_browser( std::shared_ptr< Browser const > browser , std::vector<std::string const> const& urls );
    void set_urls( std::vector< std::string const > const& vectors );
private:
    Ui::WMainWindow *ui;
};

#endif // WMAINWINDOW_H
