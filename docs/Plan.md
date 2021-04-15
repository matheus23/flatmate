# Plan

* [X] Client-only shopping list
* [X] Get a better service worker for actual offline support
  - Cache all static files needed for running offline
* [ ] Figure out a good way for publishing/syncing for now.
  - Maybe show the user that a sync is in progress (some kind of spinner somewhere, like the cloud icons in zenkit)
  - Incorporate publish into the sync flow somehow.
  - ~~Throttle .publish calls~~ webnative already does that.
* [ ] Let's do conflict resolution
  - State is replicated in WNFS, event log of unpublished things is stored locally
    The events would look like "Add item *namehash*, *name*, *associated info* (index?)" and 
    "Move *namehash* to index X" (or maybe instead of an index, relative to other items?)
  - I worry about overrides on publish. I expect to do `loadFileSystem` before `publish`, but what if there's another devices' `publish` between these two calls causing a race condition?
  - What happens with item renames?
* [ ] Progressive login.

* [X] Identify elements by Hash
* [X] Publish only via button press
* [ ] Refresh via button press
  - [ ] Decode `Data.FileSystem` on initialisation. Switch to a more general `invoke` FFI. Add special `en/decodeUtf8` ports.
* [ ] Record an event log
* [ ] Before publishing, test whether the head diverged
* [ ] Add a "log error" message to get rid of lots of "Result String a" types in Msg
* [ ] Restructure the Model and what messages are ShoppingListMsg-es and what aren't