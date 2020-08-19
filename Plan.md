# Plan

## Step 1: The Shopping List

* [ ] IMPORTANT: Setup testing with elm-platform-test
  - [X] Exchange commands for 'Effects'
  - [ ] Also mock subscriptions (need to figure out how to do that first)
  - [ ] Mock KintoJs in Elm
    - [ ] Figure out how/whether to do that
  - [ ] Write more UI tests

* [X] Hardcode shopping list items in Elm app
* [X] Add Kinto JS lib
  - [X] Make sure TS defs work / TS works (VS Code checks might be enough)
* [X] Local Kinto ?
* [ ] Hardcode Auth
* [ ] Create buckets etc. in admin interface, hardcode bucket ids etc.
  - [ ] Think through what collections we need, the schemas, etc.
  - [ ] Figure out how sorting shopping list items should work
* [ ] Ports to KintoJs
  - [X] First rudimentary port
  - [ ] Proper port structure
  - [ ] Send Json.Values through ports and validate records on the elm side (with some error handling)
* [X] Dynamic (/synced) shopping list :)

* [X] Design shopping list
  * [X] Transfer figma styles to tailwind config
  * [ ] Build static UI
  * [ ] Add 'user intention' hooks to view module for elm-program-test use

## Step 2: An Actual App

Routes
* [ ] Figure out auth flow
* [ ] Figure out flat creation flow
* [ ] Figure out ... ???
* [ ] Designs for above
* [ ] Implement routing
* [ ] Implementation


# (Eventual) Architecture

```
Elm -> HTTP -> Elm-Kinto
  1. -> Kinto Webserver
  2. -> Service Worker -> Kinto JS -> Kinto Webserver
```

Maybe this is a better design, maybe it's stupid. "Back of the head" thing.
