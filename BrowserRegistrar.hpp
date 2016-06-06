#ifndef hEA648BE9E34A437D81EDD9945E6383AF
#define hEA648BE9E34A437D81EDD9945E6383AF

#include <memory>
#include <string>
#include <vector>

class Browser
{
public:
  virtual std::string get_name() const = 0;
  virtual void open_urls( std::vector< std::string const > const& urls ) const = 0;
};

class BrowserRegistrar
{
public:
  virtual std::vector< std::shared_ptr< Browser > > listBrowsers() = 0;
};

std::shared_ptr< BrowserRegistrar > getBrowserRegistrar();

#endif
