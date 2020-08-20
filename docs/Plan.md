# Plan

## Step 1: The Shopping List

### UI

* [X] Design shopping list
* [X] Transfer figma styles to tailwind config
* [X] Build static UI
* [X] Think through data schemas
  - [X] Figure out how sorting shopping list items should work
* [ ] Update Kinto.elm/Update elm code with new decoders
* [ ] Update tests according to new elm code
* [ ] Make shopping list view dynamic, using new data schema

### UI Specification

* [X] Setup testing with elm-platform-test
* [X] Exchange commands for 'Effects'
* [X] Also mock subscriptions (need to figure out how to do that first)
* [ ] Add 'user intention' hooks to View.ShoppingList module for elm-program-test use
  - [ ] Add Test.Html.Query-ies for useful sections to View.ShoppingList for use with Program.within in tests
  - [ ] Add 'intention' hooks: Utilities like `addShoppingListItem : String -> ProgramTest`
* [ ] Fully specify UI using tests
* [ ] Mock KintoJs in Elm
  - [ ] Figure out how/whether to do that
    - It's possible via getOutgoingPortValues

### Backend integration

* [X] Hardcode shopping list items in Elm app
* [X] Add Kinto JS lib
  - [X] Make sure TS defs work / TS works (VS Code checks might be enough)
* [X] Local Kinto ?
* [ ] Hardcode Auth
* [ ] Create buckets etc. in admin interface, hardcode bucket ids etc.
  - [ ] Maybe: Script for initializing the correct schema at kinto
* [ ] Ports to KintoJs
  - [X] First rudimentary port
  - [ ] Proper port structure
  - [ ] Send Json.Values through ports and validate records on the elm side (with some error handling)
* [X] Dynamic (/synced) shopping list :)

## Step 2: An Actual App

Routes
* [ ] Figure out auth flow
* [ ] Figure out flat creation flow
  - [ ] Figure out kinto premissions
* [ ] Figure out history/logs & undo
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
