module Tests exposing (..)

import Test exposing (..)
import UI.ShoppingList


all : Test
all =
    concat
        [ UI.ShoppingList.all
        ]
