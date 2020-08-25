# Data Schema


## "Items": What is currently visible in the Shopping List

Common fields with "Suggestions":
* name: string, e.g. "Kauf  Milch", "nimm 2"
* amount: optional record
  - count: positive int, e.g. 2
  - prefix: string, e.g. ""
  - suffix: string, e.g. "liter"
  - index_in_name: optional positive int, e.g. 5
* shop: optional shop uuid
* last_entered: time
* previously_entered: list time

Unique fields to "Items":
* checked: boolean
* (added_by: user uuid)


### Action: Add an "Item" that already exists in a shopping list

-> Should warn the user and add nothing



## "Suggestions": What has ever been entered as an "Item"

Stores any shopping list entries ever entered to suggest to the user when entering new items and

* name: string, e.g. "Kauf  Milch", "nimm 2"
* amount: optional record
  - count: positive int, e.g. 2
  - prefix: string, e.g. ""
  - suffix: string, e.g. "liter"
  - index_in_name: optional positive int, e.g. 5
* shop: optional shop uuid
* last_entered: time
* previously_entered: list time


### Action: Add an item that has never been entered before


### Action: Add an item from the suggestions


### Action: "This is not an amount"

* By indicating in the shopping list UI, that a recognized amount is incorrectly recognized

Simple option:
* Just disable amounts for this item

Complicated option:
* Let the user adjust how amounts should be parsed (which number is an amount)


### Action: Delete

* By indicating in the UI, that a suggestions shouldn't be suggested in the future.



## Shops

* name: string
* uuid: uuid
* entry_order: list entry uuid


### Action: Adjusting Item Order

Before:

hidden uuid order:
* Maultaschen
* Milch
* Pfirsiche
* Butter
* Hefe
* Eier

actual shopping list:
* Milch
* Butter
* Eier

After: User drags 'Eier' above 'Milch' in UI

hidden uuid order:
* Maultaschen
* Eier
* Milch
* Pfirsiche
* Butter
* Hefe

actual shopping list:
* Eier
* Milch
* Butter


### Action: Add entry that has never occured before

* Added to end of actual shopping list
* Inserted to hidden uuid order after last uuid in current shopping list

Before:

hidden uuid order:
* Maultaschen
* Milch
* Pfirsiche
* Butter
* Hefe

actual shopping list:
* Milch
* Butter

After: User adds 'Eier'

hidden uuid order:
* Maultaschen
* Milch
* Pfirsiche
* Butter
* Eier
* Hefe

actual shopping list:
* Milch
* Butter
* Eier



## Kinto Bucket Setup

UI Schema builder: https://rjsf-team.github.io/react-jsonschema-form/

* preliminary, hardcoded bucket id: flatmate
* see the collection setup in tests/upload-schema-examples.mjs
