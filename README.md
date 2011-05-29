AARRR - metrics for Pirates
-----------------------------

AARRR is a MongoDB backed Rails 3 plugin that helps you track metrics for your web apps (with cohorts!).

The name comes from an acronym coined by Dave McClure that represents the five most important early metrics for any web startup: Acquisition, Activation, Revenue, Retention, and Referral. It's also what pirates say.

A quick 5 min video:<br>
<http://500hats.typepad.com/500blogs/2007/09/startup-metrics.html>

Learn more about startup metrics for Pirates:<br>
<http://www.slideshare.net/dmc500hats/startup-metrics-for-pirates-long-version>

## Why you should use AARRR:

AARRR is meant to quickly get you started and provide a framework for collecting and displaying data. It's goal is to help you learn what to measure, and quickly get results. It's long term goal is to really get you to think very hard about how to measure and track your users in order to provide actionable metrics about your web app.

## Features:

* Easily define custom [cohorts](http://www.avc.com/a_vc/2009/10/the-cohort-analysis.html) (defaults to weekly cohorts). You can also define cohorts for specific deploys, or by traffic source.

* Uses MongoDB for storing analytics (no schema needed, and super crazy fast writes)

* Easily hooks into Devise (to capture User Acquisition event)

* Automatic configuration for Mongoid and MongoMapper users


## How to Install:

* Add `gem "aarrr"` to your Gemfile and `bundle`

* Run `rails g aarrr:install` to generate your initializer

* If you'd like to customize the MongoDB connection (or if you aren't using Mongoid/MongoMapper, then edit `config/initializers/aarrr.rb` and set `AARRR.connection` to a valid `Mongo::Connection`. See the [mongo gem tutorial](http://api.mongodb.org/ruby/current/file.TUTORIAL.html) for quick an easy instructions on how to set up a `Mongo::Connection`

AARRR is now set up, and will add an `around` filter to each request so it can handle user tracking. When a user first shows up at your site, we'll add in a "_utmarr" permanent cookie to them that uniquely identifies the user. You can configure this cookie in `config/initializers/aarrr.rb`.


## How to add tracking

AARRR defines a helper method `AARRR()` that returns a "session" object.  actually just an alias to AARRR.create_session(request.env). The session object's purpose is to define a user uniquely. All tracking events should be called from the session object

You can get a session in a few different ways:

    # from an env hash (we'll pull out the right cookie tracking code)
    AARRR(request.env)

    # directly from a user (if they're already logged in)
    # use this if you are doing tracking from model objects (you just need a reference to the user)
    AARRR(current_user)

    # pass in the tracking code directly
    AARRR(cookies["_utmarrr"])


### Acquisition

You'll probably want to track customer acquisition at the time of user signup. We can automatically hook into Devise so this event is triggered as soon as your user signs up.

If you'd rather define Acquisition events manually, just use:

    AARRR(request.env).acquisition!

### Activation

Activation events should be tracked as soon as your user interacts "sucessfully" with your app. You'll need to define this for your own app, however if your app is built to do something specific then you should add an activation event whenever that thing happens.

    # use this to specifically activate the user
    AARRR(request.env).track(:activation)

    # we can also mark an activation via usage (if the user is not already activated)
    AARRR(request.env).track(:usage)


### Retention

Retention is defined by how often your user keeps coming back to the app. There's no tracking event for retention (as that wouldn't make sense). However you should add tracking events for when people use the app

    AARRR(request.env).track(:usage)


### Referral

Referral should be triggered whenever someone gets someone else to sign up to your app. It's used to calculate a Virality coefficient which is. Learn more about the virality coefficient [here](http://andrewchenblog.com/2008/04/17/viral-coefficient-what-it-does-and-does-not-measure/).


Referrals are done in 2 parts. First you can track when someone decides to refer someone. This would be an "invite" link or something similar.

    # generate a referral
    referral_code = AARRR(request.env).referral({email: "someone@somewhere.com"})

    # email out the url with this referral code in the query param
    # "?_a=x71n5"

When someone enters the site without an activated session and a referral code shows up, then we track the referral event as soon as the user signs up.


### Revenue

Whenever you capture a dollar from user, then you should track that intake event.

    # customer paid you 55.00
    AARRR(request.env).revenue(55.00)

    # can also pass in the cents
    AARRR(request.env).revenue_cents(5500)

    # it's also useful to pass in a unique code here (receipt / invoice number or something) so you don't double track someone's revenue
    AARRR(request.env).revenue(55.00, :unique => "x8175m1o58113")


## Cohorts

Cohorts are ways to slice up reports so you can see the results for these 5 metrics for groups of specific users. Some useful ones are:

* Date (by day, week, month): slices up the metrics based on when users first came to your site (session creation). This is useful to see if what your building is actually improving your metrics

* By Traffic Source: slices up the metrics based on where your users are coming from.


## Split Testing

You can set up split testing easily by running

    AARRR(request.env).split_on(:landing_redesign, [:v1_layout, :v2_layout]).

This will attach the session with a randomly selected version of the split test. You can then query on this by using the `split?` method.

    AARRR(request.env).split?(:landing_redesign, :v1_layout)


## Ignored Cohorts

When you start seeing screwy data (spammers, seo, scrapers) you can selectively remove these people by configuring Ignored Cohorts. This just excludes data before running the report calculations.

This identified session that are likely "spam" and removes it from results.


## Pulling the Data out (generating reports)

AARRR provides some simple views that allow you to generate some basic reports. Reports are generated via a cron job `rake aarrr:generate`. This can take a long time, however as soon as it's updated

You can also generate the reports manually by running AARRR.generate!, however I'd advise you to run it via Resque or Delayed Job as it may take a long time to generate.

Once you have the reports, you can use the AARRR view helpers in order to render your reports to a web page.

Our report views probably aren't going to be exactly what you want, so we encourage you to cycle through the AAARR.report_results (returns the latest generated report results) and build up your own graphs and charts.

