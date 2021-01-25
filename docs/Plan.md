# Plan

* [X] Client-only shopping list
* [ ] Get a better service worker for actual offline support
  - Cache all static files needed for running offline
  - Don't fetch from cache when online. Let http caching do its job
  - Don't accidentally never replace the service worker with a new version (because the service worker prevents a new version of itself from being fetched)
  - Don't overcache. Don't cache everything. Figure out some kind of cache whitelist that makes sense. Maybe do it by hand for now.
* [ ] Figure out a good way for publishing/syncing for now.
  - Maybe show the user that a sync is in progress (some kind of spinner somewhere, like the cloud icons in zenkit)
  - Incorporate publish into the sync flow somehow.


## 'Backend'

* [ ] Write-only event log
* [ ] UUIDs for each device
* [ ] One directory per device named after its UUID
  - [ ] Contains 'rollup'/snapshot of consumed event log at some state (Maybe just some codec-ified elm value)
