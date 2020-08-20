module Main exposing (..)

import Browser
import Effect exposing (Effect)
import Html
import Html.Styled
import List.Extra as List
import Ports
import View.ShoppingList



---- MODEL ----


type alias Model =
    { shoppingItems : List { title : String, id : Ports.Id }
    , inputText : String
    }


init : ( Model, Effect )
init =
    ( { shoppingItems = []
      , inputText = ""
      }
    , Effect.None
    )



---- UPDATE ----


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Effect )
update msg model =
    case msg of
        NoOp ->
            ( model, Effect.None )



---- VIEW ----


view : Model -> Html.Html Msg
view model =
    Html.Styled.toUnstyled
        (View.ShoppingList.view
            { shops =
                [ View.ShoppingList.shopGenericHeading
                , View.ShoppingList.itemList
                    [ View.ShoppingList.item
                        { enabled = True
                        , content =
                            [ Html.Styled.text "Milch, "
                            , View.ShoppingList.itemAmount "2"
                            ]
                        }
                    , View.ShoppingList.item
                        { enabled = True
                        , content =
                            [ View.ShoppingList.itemAmount "12"
                            , Html.Styled.text " Eier"
                            ]
                        }
                    , View.ShoppingList.item
                        { enabled = True, content = [ Html.Styled.text "Zwiebeln" ] }
                    , View.ShoppingList.item
                        { enabled = False
                        , content = [ Html.Styled.text "2 Joghurt" ]
                        }
                    ]
                , View.ShoppingList.shopHeading "Dm"
                , View.ShoppingList.itemList []
                ]
            , actionSection =
                { addItemInputValue = ""
                , onItemInput = \_ -> NoOp
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
subscriptions _ =
    Sub.none
