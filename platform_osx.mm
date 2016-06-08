#include "platform_interface.hpp"

#include "browbeaterapplication.h"

#include <QApplication>
#include <QMessageBox>

#include <Cocoa/Cocoa.h>
#include <Carbon/Carbon.h>

#include <iostream>
#include <fstream>
#include <sstream>

void throwOSXStatus(OSStatus status)
{
    switch(status)
    {
    case noErr: break;
#define X(STATUS) case STATUS: throw std::runtime_error(#STATUS);
    X(kLSAppInTrashErr)
    X(kLSUnknownErr)
    X(kLSNotAnApplicationErr)
    X(kLSNotInitializedErr)
    X(kLSDataUnavailableErr)
    X(kLSApplicationNotFoundErr)
    X(kLSUnknownTypeErr)
    X(kLSDataTooOldErr)
    X(kLSDataErr)
    X(kLSLaunchInProgressErr)
    X(kLSNotRegisteredErr)
    X(kLSAppDoesNotClaimTypeErr)
    X(kLSAppDoesNotSupportSchemeWarning)
    X(kLSServerCommunicationErr)
    X(kLSCannotSetInfoErr)
    X(kLSNoRegistrationInfoErr)
    X(kLSIncompatibleSystemVersionErr)
    X(kLSNoLaunchPermissionErr)
    X(kLSNoExecutableErr)
    X(kLSNoClassicEnvironmentErr)
    X(kLSMultipleSessionsNotSupportedErr)
#undef X
            default:
        std::stringstream msg;
        msg << "Unrecognized status:" << status;
            throw std::runtime_error(msg.str());
    }
}

class OsxBrowser : public Browser
{
private:
  OsxBrowser() 
    : m_bundle_id( nil ),
      m_app_url(nil)
  { }

public:
  std::string get_name() const
  {
    return m_name;
  }

  void open_urls( std::vector< std::string const > const& urls ) const
  {
    std::cout << "opening urls..." << urls.size() << std::endl;
    NSMutableArray* itemUrls = [NSMutableArray arrayWithCapacity:urls.size()];
    if (!itemUrls)
      throw std::runtime_error("wtf, itemUrls?");

    for( auto const& url : urls )
    {
        std::cout << "opening url: " << url << std::endl;
        NSString* nsStringUrl = [NSString stringWithUTF8String:url.c_str()];
        if (!nsStringUrl)
            throw std::runtime_error("wtf, eh?");

        std::cout << "2. opening url:" << url << std::endl;
        NSURL* itemUrl = [NSURL URLWithString:nsStringUrl];
        if (!itemUrl)
            throw std::runtime_error("wtf, url?");
        [itemUrls addObject:itemUrl];
    }

    LSLaunchURLSpec args;
    args.appURL = m_app_url;
    args.itemURLs = (CFArrayRef)itemUrls;
    args.passThruParams = nil;
    args.launchFlags = 0;
    args.asyncRefCon = nil;

    std::cout << "args: " << std::endl;
    std::cout << "args.appURL: " << args.appURL << std::endl;

    CFURLRef launchedUrl = nil;
    OSStatus status = LSOpenFromURLSpec( &args, &launchedUrl );
    std::cout << "status" << status << std::endl;
  }

  class Builder 
  {
  private:
    std::shared_ptr< OsxBrowser > result;
  public:

    Builder() 
      : result( new OsxBrowser() )
    {}

    std::shared_ptr< OsxBrowser > build()
    {
      assert( result->m_name.length() );
      assert( result->m_bundle_id );
      assert( result->m_app_url );
      return result;
    }

    Builder& set_name( std::string value )
    {
      result->m_name = value;
      return *this;
    }    

    Builder& set_bundle_id( CFStringRef value )
    {
      result->m_bundle_id = value;
      return *this;
    }

    Builder& set_app_url( CFURLRef value )
    {
      result->m_app_url = value;
      return *this;
    }
  };
  friend class Builder;
  static Builder builder() { return Builder(); }

private:
  std::string m_name;
  CFStringRef m_bundle_id;
  CFURLRef m_app_url;
};

std::string url_decode(std::string const& input) {
  std::string result;
  std::string::size_type start = 0;
  while( true ) {
    std::string::size_type percent = input.find('%',start);
    std::string substr = input.substr(start,percent);
    // std::cout << "input:" << input << " start:" << start << " percent:" << percent << " substr:" << substr << std::endl;
    result += substr;
    if (percent != std::string::npos) {
      std::string encoded = input.substr(percent + 1, 2);
      int val = atoi(encoded.c_str());
      result += (char)val;
      start = percent + 3;
    } else {
      return result;
    }
  }
}

class OsxBrowserRegistrar : public BrowserRegistrar
{
public:
  std::vector< std::shared_ptr< Browser > > listBrowsers()
  {
    std::vector< std::shared_ptr< Browser > > result;
    CFArrayRef handlers = LSCopyAllHandlersForURLScheme(CFSTR("http"));
    if (handlers)
    {
        for(CFIndex i=0; i<CFArrayGetCount(handlers); i++)
        {
            CFStringRef nsbrowser = (CFStringRef)CFArrayGetValueAtIndex(handlers, i);
            std::string browser = std::string([(id)nsbrowser UTF8String]);
            std::cout << "browser:" << browser << std::endl;
            if ("com.whispersoft.browbeater" == browser) {
                continue;
            }

            CFErrorRef error = NULL;
            CFArrayRef nsurls = LSCopyApplicationURLsForBundleIdentifier( nsbrowser, &error );
            if (nsurls)
            {
                for (CFIndex j=0; j<CFArrayGetCount(nsurls); ++j)
                {
                    CFURLRef nsurl = (CFURLRef)CFArrayGetValueAtIndex(nsurls, j);
                    std::string name = std::string([[[[(id)nsurl absoluteString] lastPathComponent] stringByDeletingPathExtension] UTF8String]);
                    name = url_decode(name);
                    result.push_back(OsxBrowser::builder().set_name( name ).set_bundle_id( nsbrowser ).set_app_url(nsurl).build());
                }
            }
        }
    }
    std::sort( result.begin(),result.end(), [](std::shared_ptr<Browser> pBrowserL, std::shared_ptr<Browser> pBrowserR) {
        return pBrowserL->get_name() < pBrowserR->get_name();
    });
    for(auto pBrowser : result) {
        std::cout << "sorted:" << pBrowser->get_name() << std::endl;
    }
    return result;
  }
};

std::shared_ptr< BrowserRegistrar > getBrowserRegistrar()
{
  return std::shared_ptr< BrowserRegistrar >(new OsxBrowserRegistrar());
}


void registerApplication(std::string const& path)
{
    CFStringRef appID = ::CFBundleGetIdentifier(::CFBundleGetMainBundle());
    if (appID != nil) {
      std::cout << "appId:" << [(id)appID UTF8String] << std::endl;
    }

    std::cout << "Registering application:" << path << std::endl;
    std::string pattern = ".app/Contents";
    std::string::size_type appPos = path.find(pattern);
    if (appPos == std::string::npos)
    {
        throw std::runtime_error("Cannot register non-app path:" + path);
    }

    std::string appPath = path.substr(0,appPos) + ".app";

    std::cout << "Registering path:" << appPath << std::endl;
    NSString* nspath = [NSString stringWithUTF8String:appPath.c_str()];
    NSURL* appUrl = [NSURL fileURLWithPath:nspath];
    OSStatus status = LSRegisterURL( (CFURLRef) appUrl, true );
    throwOSXStatus(status);
    std::cout << "Registered url:" << [[appUrl absoluteString] UTF8String] << " Status:" << status << std::endl;
}

