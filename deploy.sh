#!/bin/bash
#
git add .
git commit -a -m "update blogs"
git push origin hexo

# hexo clean && hexo deploy
hexo clean && hexo generate && hexo deploy
