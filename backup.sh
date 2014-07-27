heroku pgbackups:capture --expire
rm -r backups
mkdir backups
curl -o backups/latest.dump `heroku pgbackups:url`
pg_restore -d prwatch_development backups/latest.dump --verbose --clean --no-acl --no-owner -h localhost
rake db:migrate
rm -r backups