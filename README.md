AARRR - metrics for Pirates
-----------------------------

AARRR is a MongoDB backed Rails 3 plugin that helps you track **user lifecycle** metrics for your web apps (with cohorts!).

The name comes from an acronym coined by Dave McClure that represents the five most important early metrics for any web startup: Acquisition, Activation, Revenue, Retention, and Referral.

A quick 5 min video:<br>
<http://500hats.typepad.com/500blogs/2007/09/startup-metrics.html>

Learn more about startup metrics for Pirates:<br>
<http://www.slideshare.net/dmc500hats/startup-metrics-for-pirates-long-version>

![mascot](https://github.com/railsjedi/aarrr/raw/master/aarrr.png "Mascot")

## Why you should use AARRR:

AARRR is meant to quickly get you started and provide a framework for collecting and displaying data. It's goal is to help you learn what to measure, and quickly get results. It's long term goal is to really get you to think very hard about how to measure and track your users in order to provide actionable metrics about your web app.

While it has support for split testing, it's main goal is to provide macro metrics for your users. For more micro experiment driven metrics, you should check out tools such as [Vanity](https://github.com/assaf/vanity) and [ABingo](http://www.bingocardcreator.com/abingo)


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

AARRR defines a helper method `AARRR()` that returns a "session" object.  actually just an alias to AARRR::Session.new(). The session object's purpose is to define a user uniquely. All tracking events should be called from the session object

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

    AARRR(request.env).activation!(:built_page)

    AARRR(request.env).activation!(:finished_game)


### Retention

Retention is defined by how often your user keeps coming back to the app. You can define retention rules separately in reports (e.g. 5 times in 2 months)

    AARRR(request.env).retention!(:logged_in)


### Referral

Referral should be triggered whenever someone gets someone else to sign up to your app. It's used to calculate a Virality coefficient which is. Learn more about the virality coefficient [here](http://andrewchenblog.com/2008/04/17/viral-coefficient-what-it-does-and-does-not-measure/).


Referrals are done in 2 parts. First you can track when someone decides to refer someone. This would be an "invite" link or something similar.

    # generate a referral
    referral_code = AARRR(request.env).referral!({email: "someone@somewhere.com"})

    # email out the url with this referral code in the query param
    # "?_a=x71n5"

When someone enters the site without an activated session and a referral code shows up, then we track the referral event as soon as the user signs up.


### Track

Track allows you to trigger multiple events at a time. (defaults to :activation event)

    AARRR(request.env).track!(:built_page, [:activation, :retention])


### Revenue

Whenever you capture a dollar from user, then you should track that intake event.

    # customer paid you 55.00
    AARRR(request.env).revenue!(55.00)

    # can also pass in the cents
    AARRR(request.env).revenue_cents!(5500)

    # it's also useful to pass in a unique code here (receipt / invoice number or something) so you don't double track someone's revenue
    AARRR(request.env).revenue!(55.00, :unique => "x8175m1o58113")


## Cohorts

Cohorts are ways to slice up reports so you can see the results for these 5 metrics for groups of specific users. Some useful examples are:

* Date (by day, week, month): slices up the metrics based on when users first came to your site (session creation). This is useful to see if what your building is actually improving your metrics

    # assigns a cohort based on the week
    AARRR.define_cohort :weekly do |user|
      user["created_at"].beginning_of_week.strftime("%B %d, %Y")
    end

* By Traffic Source: slices up the metrics based on where your users are coming from. This allows you to see what sources of traffic are most value and target your marketing efforts on these.

    # assigns a cohort based on the traffic source
    AARRR.define_cohort :source do |user|
      case user["referrer"]
      when /google.com/, /gmail.com/
        "google"
      when /facebook.com/
        "facebook"
      else
        nil
      end
    end

* By gender (assuming you've captured it in data)

    AARRR.define_cohort :gender do |user, data|
      if data["gender"].to_s.upcase == "M"
        "male"
      elsif data["gender"].to_s.upcase == "F"
        "female"
      else
        nil
      end
    end


## Split Testing

You can set up split testing by using:

    AARRR.define_split :landing_redesign, :options => {
      :v1_layout => 0.9,
      :v2_layout => 0.1
    }

To use these split tests, just add the following to your views:

    AARRR(request.env).split?(:landing_redesign, :v1_layout) #=> true

The first argument is a reference to the split test that you defined in your initializer. The second argument is the split option to return.

This will attach the session with a randomly selected version of the split test and return whether it matches the second argument.

You can also just return the split option currently assigned to the user by using:

    AARRR(request.env).split(:landing_redesign) #=> :v1_layout

Split test results can be accessed via the reports, and you can slice up the user metrics based on which users saw what split. People who saw neither splits will not be included in the results.


## Ignored Cohorts

When you start seeing screwy data (spammers, seo, scrapers) you can selectively remove these people by configuring Ignored Cohorts. This just excludes data before running the report calculations.

This allows you to identify the AARRR users that are likely "spam" and removes them from most report results.

    # pass it a mongo query that defines the users you want to ignore
    AARRR.ignored_cohort :googlebot, "data.useragent" => /googlebot/


## Pulling the Data out (generating reports)

AARRR provides some simple views that allow you to generate some basic reports. Reports are generated via a cron job `rake aarrr:generate`. This can take a long time, however as soon as it's updated.

You can also generate the reports manually by running AARRR.generate!, however I'd advise you to run it via Resque or Delayed Job as it may take a long time to generate.

Once you have the reports, you can use the AARRR view helpers in order to render your reports to a web page.

Our report views probably aren't going to be exactly what you want, so we encourage you to cycle through the `AAARR.report_results` (returns the latest generated report results) and build up your own graphs and charts.



## Data Model

This section describes how AARRR stores your data within the MongoDB collections (raw and reports).

### Raw Events

AARRR tracks the raw metric data in a 2 main tables:

`aarrr_users` tracks the unique identities of each user. the `aarrr_user_id` is used for each event.

* `_id`: generated aarrr user id
* `user_id`: optional tie in to your database's user_id
* `data`: hash that stores any data that's passed for the user on creation. main use is for analyzing the cohort data
* `splits`: hash that maps split testing rules to assigned splits for the user
* `cohorts`: a hash that maps cohort rules with the results
* `ignore_reason`: a string that represents the reason this user is ignored in reports
* `first_event_at`: date that the user first interacted with the site
* `last_event_at`: date that the user last interacted with the site

`aarrr_events` tracks each event that the user is engaged in.

* `_id`: generated aarrr event id
* `aarrr_user_id`: id that maps event back to the aarrr users table
* `event_types`: array of types of the event that was tracked
* `event_name`: name for the event that was tracked
* `data`: data that should be tracked along with the event
* `revenue`: revenue the was generated on this event
* `referral_code`: referral code that was generated for this event



