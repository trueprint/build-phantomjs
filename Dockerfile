FROM debian:latest

ARG GIT_SHA=5d99f2a7da4820f015fb5af89be3fb66f3a868d3
ARG REPO=git://github.com/ariya/phantomjs.git

# Dependencies we just need for building phantomjs
ENV buildDependencies\
  wget unzip python build-essential g++ flex bison gperf\
  ruby perl libssl-dev libpng-dev git libx11-xcb-dev

# Dependencies we need for running phantomjs
ENV phantomJSDependencies\
  libicu-dev libfontconfig1-dev libjpeg-dev libfreetype6 openssl libsqlite3-dev

# Installing phantomjs
RUN \
    # Installing dependencies
    echo "$REPO/commit/$GIT_SHA" \
&&  apt-get update -yqq \
&&  apt-get install -fyqq ${buildDependencies} ${phantomJSDependencies} 

RUN git clone ${REPO} \
&&  cd phantomjs \
&&  git config --global user.email "you@example.com" \
&&  git config --global user.name "Your Name" \
&&  git checkout ${GIT_SHA} \
&&  git cherry-pick d42ddc8af3de627b6d4e749536f8746ad17f88f5 \
&&  git submodule init \
&&  git submodule update \
    # Building phantom
&&  ./build.py --confirm --silent --release \
    # Removing everything but the binary
&&  ls -A | grep -v bin | xargs rm -rf \
    # Symlink phantom so that we are able to run `phantomjs`
&&  ln -s /phantomjs/bin/phantomjs /usr/local/share/phantomjs \
&&  ln -s /phantomjs/bin/phantomjs /usr/local/bin/phantomjs \
&&  ln -s /phantomjs/bin/phantomjs /usr/bin/phantomjs \
    # Removing build dependencies, clean temporary files
&&  apt-get purge -yqq ${buildDependencies} \
&&  apt-get autoremove -yqq \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    # Checking if phantom works
&&  phantomjs -v

CMD \
    echo "phantomjs binary is located at /phantomjs/bin/phantomjs"\
&&  echo "just run 'phantomjs' (version `phantomjs -v`)"
