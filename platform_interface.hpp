#ifndef PLATFORM_INTERFACE_HPP
#define PLATFORM_INTERFACE_HPP

#include <memory>
#include <string>
#include <vector>

class BrowBeaterApplication;

class Browser
{
public:
  virtual ~Browser() = default;
  virtual std::string get_name() const = 0;
  virtual void open_urls( std::vector<std::string> const& urls ) const = 0;
};

class BrowserRegistrar
{
public:
  virtual ~BrowserRegistrar() = default;
  virtual std::vector< std::shared_ptr< Browser > > listBrowsers() = 0;
};

std::shared_ptr< BrowserRegistrar > getBrowserRegistrar();
void registerApplication(std::string const& path);

#endif
