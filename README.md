# BrowBeater

I'm a huge fan of MultiBrowser for Mac:
http://www.macupdate.com/app/mac/33861/multibrowser

Unfortunately, it isn't available on Windows, and appears to have been
abandoned even on OSX. It still installs as of this writing (El
Capitan), but the System Preferences panel no longer works.

So, I figured I could either bitch and moan about that, or I could
write my own. I've been itching to see what's new with Qt, so I
figured I'd download the latest Qt Creator (3.6.1), the latest Qt
(5.6.0), and see if I could pull it off.

And now, I've got the Mac version (mostly) working. Next item in the
backlog is more than a little crucial, though :-D.

### BACK LOG:

* ~~Figure out how to register Brow Beater as a browser on mac~~
  Apparently this requires a bunch of info.plist magic. It looks like
  you have to specify an application version along with a whole bunch
  of url schemes and file types. I'm not sure what the minimal set is.

* ~~Make sure that clicking a link outside BrowBeater will launch
  BrowBeater, and that the user can then use BrowBeater to launch
  other browsers. This is clearly not as straightforward as "accept
  urls on cli," at least on OSX.~~ It turns out the way to do this
  is add a QApplication derivative, override QApplication::event(QEvent*), 
  and provide custom handling for QFileOpenEvent

* ~~Filter BrowBeater out of the list of browsers.~~

* ~~Add keyboard navigation so that after clicking, you can up/down
  arrow to choose your preferred browser.~~

* ~~Make the UI not so... F!@#$ ugly.~~

* Figure out how to show browsers' icons in their respective buttons.

* Write Windows platform code.

* Write Linux platform code.

* Make the UI... actually pretty.

* Add continuous integration and deployment.

* Tech Debt: minimize the amount of info.plist magic.
