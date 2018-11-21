# sqitch
Simple sqitch docker wrapper based on alpine

This is very basic Docker wrapper for wonderfull tool called sqitch -> https://sqitch.org

Usage:

You should inherit your image from this one, or just extend your Dockerfile like that:

```
ADD docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ADD src/ /src/
WORKDIR /src

ENTRYPOINT ["/docker-entrypoint.sh" ]

``` 

Then mount /src on hostsystem where sqitch layout (migrations) are stored. 
Please be notified it's better to have different plans for structure and code (if you are using stored procedures). 
This approach very convinient if you want update your database code without recreation of whole database.

docker-entrypoint.sh could be like that
```
#!/bin/sh

cd /src
task="$1"
export PGPASSWORD="$PGDATABASE_PASSWORD"

# we will generate sqitch.conf here we have only production section
cat > sqitch.conf << EOL
[core]
    engine = pg
[target "production"]
    uri = db:pg://$PGDATABASE_USER:$PGPASSWORD@$PGDATABASE_HOST/$PGDATABASE_NAME
EOL
# waiting for postgres up
while ! psql -h$PGDATABASE_HOST -U$PGDATABASE_USER -d$PGDATABASE_NAME -c "select 1" > /dev/null
do
    echo "$(date) - still trying to connect to PostgreSQL host: $PGDATABASE_HOST, user: $PGDATABASE_USER, password: $PGDATABASE_PASSWORD, database: $PGDATABASE_NAME"
    sleep 5
done
echo "$(date) - connected successfully"

case $task in
    deploy)
        sqitch deploy production
        ;;
    revert)
        if [ "$#" -ne 1 ]; then
            sqitch revert production $2
        else
            sqitch revert production
        fi
        ;;
    test)
        if [ "$#" -ne 1 ]; then
            pg_prove -h$PGDATABASE_HOST -U$PGDATABASE_USER -d$PGDATABASE_NAME ./test/$2.sql
        else
            pg_prove -h$PGDATABASE_HOST -U$PGDATABASE_USER -d$PGDATABASE_NAME ./test/*.sql
        fi
        ;;
    code)
        if [ "$#" -ne 1 ]; then
            /code.sh $2
        else
            /code.sh
        fi
        ;;
    *)
        ;;
esac

```

