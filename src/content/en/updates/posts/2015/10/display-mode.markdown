---
layout: updates/post
title: "Detecting if a web app is launched from the home screen"
published_on: 2015-10-16
updated_on: 2015-10-16
authors:
  - kenchris
tags:
  - news
  - addtohomescreen
featured_image: /web/updates/images/2015/10/splashscreen.png
description: "Detecting if a web app is launched from the home screen"
---

During the past year we have focused on enabling users to build app like 
experiences on the web by making it possible for apps to work offline using 
[Service Worker](/web/fundamentals/primers/service-workers) and to get a 
presence on the homescreen using the 
[Web App Manifest](/web/fundamentals/engage-and-retain/simplified-app-installs).

Now apps tend to offer different experiences as sites, and developers might want to
offer different experiences depending on whether the site is viewed in the browser
or launched as a standalone web app, from the homescreen.

One example could be to show a navigation drawer only when launched as an app
(ie. without any browser chrome).

A way to accomplish this has been to encode a custom parameter  on the URL defined
in start_url in the manifest, which when launched will be accessible to the page
via `window.location`:

{% highlight javascript %}
{
  "name": "Air Horner",
  "short_name": "Air Horner",
  ...
  "start_url": "/?homescreen=1",
  "display": "standalone",
  "background_color": "#2196F3",
  "theme_color": "#2196F3"
}
{% endhighlight %}

While this works, it means that the developer needs to handle everything from
directly JavaScript, including modifying CSS, or applying different CSS rules.

The web already has a very nice way of working with conditional CSS, called
[media queries](https://developer.mozilla.org/en-US/docs/Web/CSS/Media_Queries/Using_media_queries).
Since M46, Chrome in Android supports the [display-mode](https://w3c.github.io/manifest/#the-display-mode-media-feature) media
query feature, which can be used to find out what the current `display-mode`
is being used for displaying the app, ie. is it being displayed by a `browser`,
`standalone` or `fullscreen`. `display-mode` is also supported for standalone Chrome
apps, which will mean that `(display-mode: standalone)` is `true`.

To apply a different background color for the app above when being launched
from the homescreen, all we need to do it use the following conditional CSS:

{% highlight javascript %}
@media all and (display-mode: standalone) {
  body {
    background-color: yellow; 
  }
}
{% endhighlight %}

It is also possible to detect is the `display-mode` is `standalone` from JavaScript:

{% highlight javascript %}
if (window.matchMedia('(display-mode: standalone)').matches) {
  console.log("Thank you for installing our app!");
}
{% endhighlight %}

Unfortunately, you cannot check whether the `display-mode` media query feature
is available, as `(display-mode)` returns `false` in M46. This issue has since been
fixed and should ship in M48.


##Best practices
As a general note, it is recommended to not use the media query to hide or show
so-called manual "install banners", telling people to add the app to the home
screen manually. This is better done by using the rules set out in "Increasing
engagement with Web App install banners".

It is also recommended to not add back-buttons which are visible in the standard
Chrome UI. If a back-button is needed, the `"display": "browser"` mode can be used
in the Web App Manifest instead.

###FAQ
* Will this work on Chrome for iOS or on Desktop?
  * This feature works on any platform where web apps can be added to the homescreen,
    meaning it works for Android as well as for desktop "Add to desktop" apps. It
    additional works for Chrome Apps distributed through the Chrome store. It currently
    does not work on iOS.
* Can't I use "display": "minimal-ui" instead of "display": "browser" if I want a
  simple back-button?
  * Chrome currently doesn't support "minimal-ui", nor is such support planned for
    the foreseeable future.
