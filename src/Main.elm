module Main exposing (..)

import Browser
import Effect exposing (Effect)
import Html
import Html.Styled
import List.Extra as List
import Ports
import View.ShoppingList



---- MODEL ----


type alias ViewItem =
    { checked : Bool
    , name : String
    , id : Ports.Id
    , entryId : Ports.Id
    }


type alias Model =
    { -- Für Carsten: 仕方がない :D
      items : List ViewItem
    , addItemInputValue : String
    }


init : ( Model, Effect )
init =
    ( { items = []
      , addItemInputValue = ""
      }
    , Effect.None
    )



---- UPDATE ----


type Msg
    = NoOp
    | ReceivedItemsUpdate (Ports.Receive Ports.Item)
    | ReceivedEntriesUpdate (Ports.Receive Ports.Entry)
    | OnAddItemInput String


update : Msg -> Model -> ( Model, Effect )
update msg model =
    case msg of
        NoOp ->
            ( model, Effect.None )

        ReceivedItemsUpdate items ->
            ( { model | items = itemsFromDb items }
            , Effect.None
            )

        ReceivedEntriesUpdate entries ->
            -- TODO: Update items' names
            ( { model | entries = entries }
            , Effect.None
            )


itemsFromDb :
    List Ports.Item
    -> List ViewItem
itemsFromDb items entries =
    Debug.todo ""



-- let
--     entryMap = Dict.fromList
---- VIEW ----


view : Model -> Html.Html Msg
view model =
    Html.Styled.toUnstyled
        (View.ShoppingList.view
            { shops =
                [ View.ShoppingList.shopGenericHeading
                , View.ShoppingList.itemList
                    (List.map
                        (\{ checked, name } ->
                            View.ShoppingList.item
                                { enabled = checked
                                , content =
                                    [ View.ShoppingList.itemAmount "10000000999999"
                                    , Html.Styled.text " "
                                    , Html.Styled.text name
                                    ]
                                }
                        )
                        model.items
                    )
                , View.ShoppingList.shopHeading "Dm"
                , View.ShoppingList.itemList []
                ]
            , actionSection =
                { addItemInputValue = model.addItemInputValue
                , onItemInput = OnAddItemInput
                , onItemAdd = NoOp
                , onClearItems = NoOp
                }
            }
        )



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init |> Tuple.mapSecond Effect.perform
        , update = \msg model -> update msg model |> Tuple.mapSecond Effect.perform
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        -- TODO Instead of NoOp, handle errors
        [ Ports.subscribeReceive Ports.codecItem NoOp ReceivedItemsUpdate
        , Ports.subscribeReceive Ports.codecEntry NoOp ReceivedEntriesUpdate
        ]
