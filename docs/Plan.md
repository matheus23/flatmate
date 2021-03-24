# Plan

* [X] Client-only shopping list
* [X] Get a better service worker for actual offline support
  - Cache all static files needed for running offline
* [ ] Figure out a good way for publishing/syncing for now.
  - Maybe show the user that a sync is in progress (some kind of spinner somewhere, like the cloud icons in zenkit)
  - Incorporate publish into the sync flow somehow.
  - Throttle .publish calls
* [ ] Let's do conflict resolution
  - State is replicated in WNFS, event log of unpublished things is stored locally
    The events would look like "Add item *namehash*, *name*, *associated info* (index?)" and 
    "Move *namehash* to index X" (or maybe instead of an index, relative to other items?)
  - I worry about overrides on publish. I expect to do `loadFileSystem` before `publish`, but what if there's another devices' `publish` between these two calls causing a race condition?
  - What happens with item renames?
* [ ] Progressive login.

* [ ] Identify elements by Hash
* [ ] Publish only via button press
* [ ] Record an event log
* [ ] Before publishing, test whether the head diverged
