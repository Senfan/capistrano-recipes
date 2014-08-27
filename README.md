capistrano-recipes
==================

Common recipes

#deploy steps

Stages: 
	local      : for local dev env deploy
	testing    : for testing env deploy
	staging    : for staging env deploy
	production : for production env deploy
Roles:
	nginx   : nginx proxy server
	sinatra : sinatra server
	db      : postgres db server
