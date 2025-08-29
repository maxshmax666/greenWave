# API

## Lights

`GET /lights`
: Fetch all traffic lights with coordinates.

`POST /lights`
: Create or update a traffic light record. Body parameters:
  - `name` – optional label
  - `latitude` – decimal
  - `longitude` – decimal

## Phases

`POST /phases`
: Upload recorded phase cycles for a light. Body parameters:
  - `light_id` – light identifier
  - `phases` – array of `{ color, duration }`

`GET /phases?light_id=<id>`
: Retrieve stored phases for a light.

## Route

`GET /route?start=<lon>,<lat>&end=<lon>,<lat>`
: Returns route geometry between two coordinates using the OpenRouteService API. Requires the `ORS_API_KEY` header.
