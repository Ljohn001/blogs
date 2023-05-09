#!/bin/bash
#
git add .
git commit -m "update blogs"
git push origin hexo

# hexo clean && hexo deploy
hexo clean && hexo g deploy