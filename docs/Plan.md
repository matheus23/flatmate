# Plan

## Step 1: The Shopping List

### UI

* [X] Design shopping list
* [X] Transfer figma styles to tailwind config
* [X] Build static UI
* [X] Think through data schemas
  - [X] Figure out how sorting shopping list items should work
* [X] Update Kinto.elm/Update elm code with new decoders
* [X] Make shopping list view dynamic, using new data schema
* [X] Update Schema
  - [X] add script that configures the schema at a kinto server
  - [X] rename entries to suggestions
  - [X] add attributes that entries have to items
  - [X] remove dependencies on entries from items
* [X] Use Http api for app, instead of ports
* [ ] Think about moving kintojs into SW
  - [ ] Need a route parser & builder
    - Use elm/url? Something like elm-codec with elm/url?
    - Use Platform.worker? Include elm in serviceworker.js?

* [ ] Update tests according to new elm code

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
