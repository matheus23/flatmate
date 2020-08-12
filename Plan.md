# Plan

## Step 1: The Shopping List

* [X] Hardcode shopping list items in Elm app
* [ ] Add Kinto JS lib
  - [ ] Make sure TS defs work / TS works (VS Code checks might be enough)
* [ ] Local Kinto ?
* [ ] Hardcode Auth
* [ ] Create buckets etc. in admin interface, hardcode bucket ids etc.
* [ ] Ports to KintoJs
* [ ] Dynamic (/synced) shopping list :)

* [ ] Design shopping list (?)

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
