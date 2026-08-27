// -*- mode: objc ; -*-
#include "platform_interface.hpp"

#include <Cocoa/Cocoa.h>
#include <Carbon/Carbon.h>

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
    : m_app_url(nil)
  { }

public:
  ~OsxBrowser()
  {
    if (m_app_url) CFRelease(m_app_url);
  }

  std::string get_name() const
  {
    return m_name;
  }

  void open_urls( std::vector<std::string> const& urls ) const
  {
    NSMutableArray* itemUrls = [NSMutableArray arrayWithCapacity:urls.size()];
    if (!itemUrls)
      throw std::runtime_error("Failed to create NSMutableArray for URLs");

    for( auto const& url : urls )
    {
        NSString* nsStringUrl = [NSString stringWithUTF8String:url.c_str()];
        if (!nsStringUrl)
            throw std::runtime_error("Invalid UTF-8 URL string: " + url);

        NSURL* itemUrl = [NSURL URLWithString:nsStringUrl];
        if (!itemUrl)
            throw std::runtime_error("Failed to create NSURL from string: " + url);
        [itemUrls addObject:itemUrl];
    }

    LSLaunchURLSpec args;
    args.appURL = m_app_url;
    args.itemURLs = (CFArrayRef)itemUrls;
    args.passThruParams = nil;
    args.launchFlags = 0;
    args.asyncRefCon = nil;

    CFURLRef launchedUrl = nil;
    OSStatus status = LSOpenFromURLSpec( &args, &launchedUrl );
    throwOSXStatus(status);
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
      if (!result->m_name.length() || result->m_bundle_id.empty() || !result->m_app_url)
        throw std::runtime_error("OsxBrowser::Builder: incomplete builder");
      return result;
    }

    Builder& set_name( std::string value )
    {
      result->m_name = value;
      return *this;
    }

    Builder& set_bundle_id( CFStringRef value )
    {
      if (value) result->m_bundle_id = std::string([(id)value UTF8String]);
      return *this;
    }

    Builder& set_app_url( CFURLRef value )
    {
      result->m_app_url = value;
      if (value) CFRetain(value);
      return *this;
    }
  };
  friend class Builder;
  static Builder builder() { return Builder(); }

private:
  std::string m_name;
  std::string m_bundle_id;
  CFURLRef m_app_url;
};

std::string url_decode(std::string const& input) {
  std::string result;
  std::string::size_type start = 0;
  while( true ) {
    std::string::size_type percent = input.find('%', start);
    if (percent != std::string::npos) {
      result += input.substr(start, percent - start);
      std::string encoded = input.substr(percent + 1, 2);
      int val = (int)strtol(encoded.c_str(), nullptr, 16);
      result += (char)val;
      start = percent + 3;
    } else {
      result += input.substr(start);
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

    CFStringRef selfBundleId = CFBundleGetIdentifier(CFBundleGetMainBundle());
    std::string selfBrowser = selfBundleId ? std::string([(id)selfBundleId UTF8String]) : "";

    CFArrayRef handlers = LSCopyAllHandlersForURLScheme(CFSTR("http"));
    if (handlers)
    {
        for(CFIndex i=0; i<CFArrayGetCount(handlers); i++)
        {
            CFStringRef nsbrowser = (CFStringRef)CFArrayGetValueAtIndex(handlers, i);
            std::string browser = std::string([(id)nsbrowser UTF8String]);
            if (!selfBrowser.empty() && selfBrowser == browser) {
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
                CFRelease(nsurls);
            }
        }
        CFRelease(handlers);
    }
    std::sort( result.begin(),result.end(), [](std::shared_ptr<Browser> pBrowserL, std::shared_ptr<Browser> pBrowserR) {
        return pBrowserL->get_name() < pBrowserR->get_name();
    });
    return result;
  }
};

std::shared_ptr< BrowserRegistrar > getBrowserRegistrar()
{
  return std::shared_ptr< BrowserRegistrar >(new OsxBrowserRegistrar());
}


void registerApplication(std::string const& path)
{
    std::string pattern = ".app/Contents";
    std::string::size_type appPos = path.find(pattern);
    if (appPos == std::string::npos)
    {
        throw std::runtime_error("Cannot register non-app path:" + path);
    }

    std::string appPath = path.substr(0,appPos) + ".app";
    NSString* nspath = [NSString stringWithUTF8String:appPath.c_str()];
    NSURL* appUrl = [NSURL fileURLWithPath:nspath];
    OSStatus status = LSRegisterURL( (CFURLRef) appUrl, true );
    throwOSXStatus(status);
}
