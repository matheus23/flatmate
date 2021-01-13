module Main exposing (..)

import Browser
import FeatherIcons
import Html
import Html.Styled exposing (text)
import Json.Decode as Json
import Ports
import Random
import UUID exposing (UUID)
import View.Common as View
import Webnative.Types as Webnative



---- MODEL ----


type alias Model =
    { uuidSeeds : UUID.Seeds
    , page : Page
    }


type Page
    = Loading
    | SignIn
    | ShoppingList


type alias Flags =
    { randomness : { r1 : Int, r2 : Int, r3 : Int, r4 : Int } }


init : Flags -> ( Model, Cmd Msg )
init { randomness } =
    ( { uuidSeeds =
            { seed1 = Random.initialSeed randomness.r1
            , seed2 = Random.initialSeed randomness.r2
            , seed3 = Random.initialSeed randomness.r3
            , seed4 = Random.initialSeed randomness.r4
            }
      , page = Loading
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = NoOp
    | RedirectToLobby
    | InitializedWebnative (Result Json.Error Webnative.State)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )

        RedirectToLobby ->
            ( model
            , Ports.redirectToLobby ()
            )

        InitializedWebnative result ->
            case result of
                Err error ->
                    -- TODO Handle errors
                    ( model
                    , Cmd.none
                    )

                Ok state ->
                    case state of
                        Webnative.NotAuthorised _ ->
                            ( { model | page = SignIn }
                            , Cmd.none
                            )

                        Webnative.AuthCancelled _ ->
                            ( { model | page = SignIn }
                            , Cmd.none
                            )

                        Webnative.AuthSucceeded _ ->
                            ( { model | page = ShoppingList }
                            , Cmd.none
                            )

                        Webnative.Continuation _ ->
                            ( { model | page = ShoppingList }
                            , Cmd.none
                            )



---- VIEW ----


view : Model -> Html.Html Msg
view model =
    Html.Styled.toUnstyled
        (View.desktopScaffolding
            (case model.page of
                Loading ->
                    [ View.loadingScreen
                        { message = "Trying to log in..." }
                    ]

                SignIn ->
                    [ View.signinScreen
                        { onSignIn = RedirectToLobby }
                    ]

                ShoppingList ->
                    View.appShell
                        [ View.shoppingList
                            [ View.shoppingListItem { checked = True, content = [ text "Milk" ] }
                            , View.shoppingListItem { checked = False, content = [ text "Butter" ] }
                            , View.shoppingListItem { checked = False, content = [ text "Eggs" ] }
                            , View.shoppingListItem { checked = True, content = [ text "Screwdriver" ] }
                            , View.shoppingListItem { checked = False, content = [ text "Avocado" ] }
                            , View.shoppingListItem { checked = True, content = [ text "Cherries" ] }
                            ]
                        , View.shoppingListActions
                            [ View.shoppingListActionButton []
                                { icon = FeatherIcons.trash2
                                , name = "Clear Checked"
                                }
                            ]
                        ]
            )
        )



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = \msg model -> update msg model
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Ports.initializedWebnative
        (Json.decodeValue Webnative.decoderState >> InitializedWebnative)
