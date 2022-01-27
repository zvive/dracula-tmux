#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

fahrenheit=$1
city=$2
region=$3
location=$4

urlencode() {
  s="${1//'%'/%25}"
  s="${s//' '/%20}"
  s="${s//'"'/%22}"
  s="${s//'#'/%23}"
  s="${s//'$'/%24}"
  s="${s//'&'/%26}"
  s="${s//'+'/%2B}"
  s="${s//','/%2C}"
  s="${s//'/'/%2F}"
  s="${s//':'/%3A}"
  s="${s//';'/%3B}"
  s="${s//'='/%3D}"
  s="${s//'?'/%3F}"
  s="${s//'@'/%40}"
  s="${s//'['/%5B}"
  s="${s//']'/%5D}"
  printf %s "$s"
}
display_location() {
  urlencode=$1
  local weather_location
  if $location; then
    if [[ -n "$city" ]]; then
      weather_location="$city"
      if [[ -n "$region" ]]; then
        weather_location="$weather_location, $region"
      fi
    fi
  fi

  if $urlencode; then
    weather_location=$(urlencode "$weather_location")
  fi

  echo "$weather_location"
}

weather_attributes() {
  local scale
  if ! $fahrenheit; then
    scale="m"
  else
    scale="u"
  fi
  echo "?$scale&format=\"%C+%t\""
}

weather_link() {
  weather_location=$(display_location true)
  weather_link="wttr.in"
  if [[ -n "$weather_location" ]]; then
    weather_link="$weather_link/$weather_location"
  fi
  echo "$weather_link"
}

fetch_weather() {
  link=$(weather_link)
  attributes=$(weather_attributes)
  curl -sL "$link$attributes"
}

#get weather display
display_weather() {
  weather_information=$(fetch_weather)
  weather_condition=$(echo "$weather_information" | rev | cut -d ' ' -f2- | rev) # Sunny, Snow, etc
  temperature=$(echo "$weather_information" | rev | cut -d ' ' -f 1 | rev)
  temperature=${temperature/\"/}
  unicode=$(forecast_unicode "$weather_condition")

  echo "$unicode${temperature/+/} " # remove the plus sign to the temperature
}

forecast_unicode() {
  weather_condition=$(echo "$weather_condition" | awk '{print tolower($0)}')

  if [[ $weather_condition =~ 'snow' ]]; then
    echo '❄ '
  elif [[ (($weather_condition =~ 'rain') || ($weather_condition =~ 'shower')) ]]; then
    echo '☂ '
  elif [[ (($weather_condition =~ 'overcast') || ($weather_condition =~ 'cloud')) ]]; then
    echo '☁ '
  elif [[ $weather_condition = 'NA' ]]; then
    echo ''
  else
    echo '☀ '
  fi
}

main() {

  # process should be cancelled when session is killed
  output="$(display_weather)$(display_location false)"
  echo "$output"
}

#run main driver program
main
