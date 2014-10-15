all:
	cd src && bundle exec jekyll build

serve:
	cd src && bundle exec jekyll serve --no-watch

