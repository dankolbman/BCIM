#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = 'Daniel Kolbman'
SITENAME = 'BCIM'
SITESUBTITLE = 'Brownian Colloid Simulator'
SITEURL = ''
#SITEURL = 'http://kolbman.com/bcim'


PATH = 'content'
PAGE_PATHS = ['pages']
#ARTICLE_PATHS = ['content']
STATIC_PATHS = ['images', 'data']

OUTPUT_PATH = 'bcim/'

THEME = 'theme'
CSS_FILE = 'main.css'

TIMEZONE = 'America/New_York'
DEFAULT_DATE_FORMAT = '%m/%d - %H:%M'

#DEFAULT_LANG = 'en'

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None

# Blogroll
#LINKS =  (('Pelican', 'http://getpelican.com/'),
#          ('You can modify those links in your config file', '#'),)

# Social widget
#SOCIAL = (('You can add links in your config file', '#'),
#          ('Another social link', '#'),)

DEFAULT_PAGINATION = 10

# Uncomment following line if you want document-relative URLs when developing
#RELATIVE_URLS = True
