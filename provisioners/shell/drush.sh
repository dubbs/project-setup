# COMPOSER
if [ ! -f /usr/local/bin/composer ];then
  echo composer
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
fi

# DRUSH
# test if file exists and is a symlink
if [ ! -L /usr/local/bin/drush ];then
  echo drush
  /usr/local/bin/composer global require drush/drush:7.*
  ln -fs /root/.composer/vendor/bin/drush /usr/local/bin/drush
fi
