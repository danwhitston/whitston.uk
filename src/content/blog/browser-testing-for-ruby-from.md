---
title: "Browser testing for Ruby from within Windows Subsystem for Linux"
description: "A rough guide to driving Selenium and Capybara browser tests for Ruby from inside Windows Subsystem for Linux, back when that was hard."
pubDate: 2017-05-14
---
This is a rough guide to setting up browser testing through Selenium on Windows Subsystem for Linux (WSL), aka Bash on Ubuntu on Windows. It assumes the following environment:

- Windows 10, running WSL
- A Ruby dev environment, running inside WSL
- Code that we want to test using a web driver, in this case Selenium, with a Capybara and RSpec test framework

The coding project folders are stored in the main Windows filing hierarchy and accessed via dev/mnt, but that makes no real difference to development and testing other than making it possible to edit the code using a GUI based editor within Windows.
The problem with browser testing in WSL is that it relies on opening and controlling a web browser, and browsers don't work on WSL at present as it deliberately doesn't include X Windows or some other GUI manager - it's meant to be command line after all. So while you can `apt-get firefox`, trying to actually run it isn't going to work.

## Some possible solutions

### Give WSL a graphical interface

This kind of goes against the point of WSL, but [is apparently possible](https://github.com/Microsoft/BashOnWindows/issues/1169#issuecomment-252148854). The idea is to run an X server in Windows and connect it to WSL. I haven't tried this out yet as it feels slightly horrifying.

### Run tests on a local virtual machine

Anything with GUI functionality should get round this issue, and using Docker in particular might open a path to easy automation so it's not too awkward to run tests during development. This would be important, as I'd prefer not to manually spin up and run tests on a VM each time I want to run tests during coding, at least not at this point. I've played with Docker and with Windows' own virtualisation software, and used to use VirtualBox as a mildly clunky dev environment. However, I haven't quite reached a workable Dockerfile for my own purposes yet.

### Run tests on a remote CI server

CI tools such as Travis can happily run browser tests in a VM, and offer a free integrated service on GitHub repos. This isn't useful for swift checking of code, or for working through issues in a REPL such as IRB or Pry.

### Use a headless browser

I've had luck using gems such as Mechanize, but the obvious choice, PhantomJS, has been [pretty painful to get working in WSL](https://github.com/Microsoft/BashOnWindows/issues/903). This would obviate the X Windows issue, but [isn't as thorough as driving a GUI browser](https://watirmelon.blog/2015/12/08/real-vs-headless-browsers-for-automated-acceptance-tests/).

### Launch and drive a Windows test suite directly from WSL

There's a tool called Windows Application Driver that [could potentially be driven using the to-be-launched interoperability](https://github.com/Microsoft/BashOnWindows/issues/1169#issuecomment-252659238) between WSL and Windows.

### Run a Windows Selenium server and remote driver

This appears to be the recommended and the cleanest approach. Set up a Selenium server in Windows, and then use a remote client in WSL to carry out testing. Both WSL and Windows have access to the same localhost, so this isn't that complex in theory.

## Implemented solution - Windows Selenium server

To set up the Windows Selenium server:

- Download the Selenium server for Windows
- Install Java for Windows
- Run the server from CMD or Powershell in Windows. If you run into a port conflict, as I did, you'll need to set a different port when starting the server, by using e.g. java -jar .\selenium-server-standalone-3.0.1.jar -port 4445. There are some more instructions on the Selenium website.
- You should now be able to see the server at <http://localhost:4445/wd/hub/static/resource/hub.html>

That should get the server up and running. However, it's still necessary to have some 'glue' that connects the server to the browser, for example Chromedriver or Geckodriver, and for the server to know where to find both the glue and the browser executable.

## For Firefox (incomplete)

- [Install geckodriver](https://github.com/mozilla/geckodriver/releases) on Windows. Note that the modern webdriver for Firefox is now known as Marionette, but that, if I understand correctly, the old webdriver is used for remote connections such as the one we're setting up.
- Try something similar to the Chrome code below, but with :firefox instead of :chrome
- Get errors such as `'Selenium::WebDriver::Error::UnknownError: The path to the driver executable must be set by the webdriver.gecko.driver system property'` and try Chrome instead

Worth noting: [this page](http://toolsqa.com/selenium-webdriver/how-to-use-geckodriver/) suggests that the path to geckodriver can be set in the file properties of the Selenium server executable, which seems more useful than the standard instructions on how to include the path in a Java program, and may resolve the issue.

## For Chrome (implemented)

- [Download Chromedriver](https://sites.google.com/a/chromium.org/chromedriver/downloads), and place it in the Windows PATH where it can be found automatically. I went overboard and copied it to a few places, just to be sure
- Ensure Chrome can be reached at the default location of `C:\Users\%USERNAME%\AppData\Local\Google\Chrome\Application\chrome.exe` - I created a shortcut to the actual location on my setup. You can find the actual location via `chrome://version/`
- There's also [some useful info in the Selenium docs](https://github.com/SeleniumHQ/selenium/wiki/ChromeDriver)
- If I'm reading those docs correctly, it may be possible to run Chromedriver directly without a separate Selenium server, but this is the way I've done it for now

Once the server's all up and running, the following should do the trick in Ruby:

```ruby
require 'selenium-webdriver'
def setup
 @driver = Selenium::WebDriver.for(:remote, :url => 'http://localhost:4445/wd/hub', :desired_capabilities => :chrome)
 #@driver = Selenium::WebDriver.for :chrome
 @base_url = "http://www.google.com/"
 @driver.manage.timeouts.implicit_wait = 30
 @verification_errors = []
end
```

Now just run:

```ruby
setup
@driver.get "https://google.com"
```

Further [examples of methods and usage](https://github.com/SeleniumHQ/selenium/wiki/Ruby-Bindings) [are available](https://community.perfectomobile.com/posts/938840-ruby-example-for-remotewebdriver).

## Using Capybara with a remote Selenium server

The above solution successfully controls a browser through `@driver`. However, when using the above solution in IRB after requiring capybara and selenium-webdriver, 'visit' is an undefined method unless forced in with `@driver.extend Capybara::DSL`, at which point it appears to drop to a default driver. From various stories elsewhere, it appears that recent versions of Capybara may be limiting their functionality to scripts in spec_features.

Using the remote driver solution with actual Capybara tests in RSpec is a somewhat easier experience. Just add the following lines to spec_helper.rb, straight after defining the `Capybara.app`:

```ruby
# This sets Capybara up to use a REMOTE Selenium server 
Capybara.javascript_driver = :selenium_remote_chrome
Capybara.register_driver "selenium_remote_chrome".to_sym do |app|
 Capybara::Selenium::Driver.new(app, browser: :remote, url: "http://localhost:4445/wd/hub", desired_capabilities: :chrome)
end
```

Now, when you create a spec that requires JavaScript to complete, Capybara will successfully call the remote Selenium server and return the appropriate result:

```ruby
feature 'Enter names' do
 scenario 'submitting names', :js => true do
  visit('/')
  fill_in :player_1_name, with: 'Dave'
  fill_in :player_2_name, with: 'Mittens'
  click_button 'Submit'
  expect(page).to have_content 'Dave vs. Mittens'
 end
end
```

---

*Originally published at <https://gist.github.com/DanielJohnston/5cea26ae0861ce1520695cff3c2c3315>. This post's recommendations are somewhat outdated: WSL2 was released, PhantomJS was deprecated, headless browser automation in general works better now. So take the advice with a pinch of salt.*
