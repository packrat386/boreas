boreas
------

Boreas is a simple weather forecast front-end, powered by the NOAA National Weather Service.

You can check out my instance at [here](https://boreas.packrat386.com).

## Running Boreas

Boreas is available as a prepackaged docker image on the [GitHub Container Registry](https://github.com/packrat386/boreas/pkgs/container/boreas). You can get the latest version by running:

```
docker pull ghcr.io/packrat386/boreas:latest
```

The image is configured to serve HTTP on port 3000, which you can then map to whatever local port you like. For example:

```
docker run -p 127.0.0.1:8080:3000 ghcr.io/packrat386/boreas:latest
```

This command will run the boreas container serving HTTP on 127.0.0.1:8080.

It is recommended that you run boreas behind a reverse proxy such as nginx to handle HTTPS.

## Development

To install the gems Boreas depends on, run `bundle install`

You can run the unit tests with `bundle exec rspec`

You can run the linter with `bundle exec standardrb`. The `--fix` flag will automatically fix most linter issues.

## Contributing

If you would like to contribute to Boreas, GitHub Issues and Pull Requests on this repository are the best way to get my attention. Be nice or I'll probably just ignore you.

## Licensing

This software is licensed under the MIT license. Detailed terms can be found in LICENSE.txt in this repo.

## Further Reading

* [NOAA National Weather Service API Docs](https://www.weather.gov/documentation/services-web-api)
* [US Census Bureau Geocoding API Docs](https://geocoding.geo.census.gov/geocoder/Geocoding_Services_API.html)




