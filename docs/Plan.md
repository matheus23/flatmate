# Plan

* [X] Client-only shopping list
* [X] Get a better service worker for actual offline support
  - Cache all static files needed for running offline
* [ ] Figure out a good way for publishing/syncing for now.
  - Maybe show the user that a sync is in progress (some kind of spinner somewhere, like the cloud icons in zenkit)
  - Incorporate publish into the sync flow somehow.
  - Throttle .publish calls


## 'Backend'

* [ ] Write-only event log
* [ ] UUIDs for each device
* [ ] One directory per device named after its UUID
  - [ ] Contains 'rollup'/snapshot of consumed event log at some state (Maybe just some codec-ified elm value)
