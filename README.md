Sinatra Oauth2 Authentication Example 
============

Using Oauth to authenticate against an existing login service is an extremely useful technique.

Since I coudn't find an example that was complete enough to copy, I decided to put this example out there.

It uses DataMapper, but would be easy to convert to whatever storage mechanism you prefer.

It uses sinatra, but it doens't have to- the mechanics are simple enough to move to your chosen platform.

This is meant as an example that works, and possibly as a skeleton that you can fork and make use of in your own projects.

CAUTION: I AM NOT A SECURITY EXPERT and I'm new at working with oAuth2.  This is the best I've come up with to date.  As I learn more, I will improve it.  If you see anything tragic, stupid, or missing, please let me know!

You must setup the following in your environment:

	ENV['DATABASE_URL']  		(Follow datamapper guidelines)
	ENV['SESSION_SECRET']		(Come up with your own)
	ENV['G_API_CLIENT']			(Get this from Google)
	ENV['G_API_SECRET']			(Get this from Google, keep it private.)

Then, do a bundle install and rackup, and you'll be authenticating.
