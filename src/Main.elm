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
import Webnative
import Webnative.Types as Webnative
import Wnfs



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


base : Wnfs.Base
base =
    Wnfs.AppData baseParams


baseParams : { name : String, creator : String }
baseParams =
    { creator = "matheus23-test"
    , name = "Flatmate"
    }


appPath : List String
appPath =
    [ "private", "Apps", baseParams.creator, baseParams.name ]



---- UPDATE ----


type Msg
    = NoOp
    | RedirectToLobby
    | InitializedWebnative (Result Json.Error Webnative.State)
    | GotWnfsResponse Webnative.Response


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )

        RedirectToLobby ->
            ( model
            , Cmd.batch
                [ Webnative.redirectToLobby Webnative.CurrentUrl
                    (Just
                        { app = Just baseParams
                        , fs = Nothing
                        }
                    )
                    |> Ports.webnativeRequest
                ]
            )

        InitializedWebnative result ->
            case result of
                Err error ->
                    -- TODO Errors
                    ( model
                    , Cmd.none
                    )

                Ok state ->
                    case state of
                        Webnative.NotAuthorised _ ->
                            notAuthenticated model

                        Webnative.AuthCancelled _ ->
                            notAuthenticated model

                        Webnative.AuthSucceeded _ ->
                            authenticated model

                        Webnative.Continuation _ ->
                            authenticated model

        GotWnfsResponse response ->
            case Wnfs.decodeResponse (\_ -> Err "No tags to parse") response of
                Ok ( n, _ ) ->
                    never n

                _ ->
                    -- TODO: Errors
                    ( model, Cmd.none )


authenticated : Model -> ( Model, Cmd Msg )
authenticated model =
    ( { model | page = ShoppingList }
    , Wnfs.ls base { path = appPath, tag = "LsAppPath" }
        |> Ports.wnfsRequest
    )


notAuthenticated : Model -> ( Model, Cmd Msg )
notAuthenticated model =
    ( { model | page = SignIn }
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
    Sub.batch
        [ Ports.initializedWebnative
            (Json.decodeValue Webnative.decoderState >> InitializedWebnative)
        , Ports.wnfsResponse GotWnfsResponse
        ]
