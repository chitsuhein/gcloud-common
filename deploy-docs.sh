#/bin/bash

# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ev

# This script takes the doc contents that exist under the `src` directory and
# pushes them to a the `src` directory in the gh-pages branch of the target
# repos (gcloud-node, gcloud-php, etc...)

# Only execute this script if this is a push to master.
if [ "${TRAVIS_BRANCH}" != "master" ] || [ "${TRAVIS_PULL_REQUEST}" != "false" ]
  then exit 0
fi

function deploy_docs {
  # Install dependencies & run the build (minify, concatenate dependencies, etc.)
  cd site
  npm install & bower install
  gulp build

  # Pull down the target client library's gh-pages branch.
  git submodule add -f -b gh-pages https://${GH_OAUTH_TOKEN}@github.com/$1 gh-pages
  cd gh-pages

  # Remove the old site content. We're going to replace it.
  if [ -d src ]
    then git rm -rf src
  fi

  # `gulp build` earlier built the `dist` directory:
  #   ../
  #     dist/
  #       index.html
  #       src/
  #         *.js
  #         *.css
  cp -R ../dist/* .

  # Commit and push using the encrypted GitHub oauth token.
  git add src
  git add index.html
  git config user.name "selfiebot"
  git commit -m "Pushing a doc site update

  https://github.com/GoogleCloudPlatform/gcloud-common/commit/${TRAVIS_COMMIT}"
  git push https://${GH_OAUTH_TOKEN}@github.com/$1 HEAD:gh-pages
}

deploy_docs "googlecloudplatform/gcloud-node"