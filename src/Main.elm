module Main exposing (..)

import Browser
import Browser.Navigation as Navigation
import Codec exposing (Codec)
import FeatherIcons
import Html
import Html.Styled exposing (text)
import Json.Decode as Json
import Ports
import Random
import UUID exposing (UUID)
import Url exposing (Url)
import View.Common as View
import Webnative
import Webnative.Types as Webnative
import Wnfs



---- MODEL ----


type alias Model =
    { uuidSeeds : UUID.Seeds
    , navKey : Navigation.Key
    , page : Page
    }


type Page
    = Loading String
    | SignIn
    | ShoppingList ShoppingListModel


type alias ShoppingListModel =
    { items : List { checked : Bool, name : String } }


type alias Flags =
    { randomness : { r1 : Int, r2 : Int, r3 : Int, r4 : Int } }


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init { randomness } _ navKey =
    ( { uuidSeeds =
            { seed1 = Random.initialSeed randomness.r1
            , seed2 = Random.initialSeed randomness.r2
            , seed3 = Random.initialSeed randomness.r3
            , seed4 = Random.initialSeed randomness.r4
            }
      , navKey = navKey
      , page = Loading "Trying to log in..."
      }
    , Cmd.none
    )


initShoppingList : ShoppingListModel
initShoppingList =
    { items =
        [ { checked = True, name = "Milk" }
        , { checked = False, name = "Butter" }
        , { checked = False, name = "Eggs" }
        , { checked = True, name = "Screwdriver" }
        , { checked = False, name = "Avocado" }
        , { checked = True, name = "Cherries" }
        , { checked = True, name = "This is a very, very, very long shopping list item. Why would anybody write this?" }
        , { checked = False, name = "This is a very, very, very long shopping list item.     And it has lots of spaces :)" }
        ]
    }


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
    | ShoppingListMsg ShoppingListMsg
    | WebnativeMsg WebnativeMsg
      -- Url
    | UrlRequest Browser.UrlRequest
    | UrlChanged Url


type ShoppingListMsg
    = CheckItem Int


type WebnativeMsg
    = RedirectToLobby
    | Initialized (Result Json.Error Webnative.State)
    | GotResponse Webnative.Response


type FileSystemAction
    = LoadedInitialState


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )

        ShoppingListMsg shoppingListMsg ->
            updateShoppingList shoppingListMsg model

        WebnativeMsg webnativeMsg ->
            updateWebnative webnativeMsg model

        UrlRequest _ ->
            ( model, Cmd.none )

        UrlChanged _ ->
            ( model, Cmd.none )


updateWebnative : WebnativeMsg -> Model -> ( Model, Cmd Msg )
updateWebnative msg model =
    case msg of
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

        Initialized result ->
            case result of
                Err _ ->
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

        GotResponse response ->
            case
                Wnfs.decodeResponse
                    (\tag ->
                        Codec.decodeString codecFileSystemAction tag
                            |> Result.mapError Json.errorToString
                    )
                    response
            of
                Ok ( LoadedInitialState, Wnfs.Utf8Content stateJson ) ->
                    case Codec.decodeString codecShoppingListModel stateJson of
                        Ok initialState ->
                            ( { model
                                | page = ShoppingList initialState
                              }
                            , Cmd.none
                            )

                        Err error ->
                            ( { model
                                | page = ShoppingList { items = [] }
                              }
                            , Ports.log ("Couldn't load state from wnfs:\n" ++ Json.errorToString error)
                            )

                Ok ( LoadedInitialState, _ ) ->
                    ( model, Ports.log "incorrect response type for 'LoadedInitialState'" )

                Err errorMsg ->
                    ( model, Ports.log ("got an error from wnfs: " ++ errorMsg) )


authenticated : Model -> ( Model, Cmd Msg )
authenticated model =
    ( { model | page = Loading "Reading saved shopping list" }
    , Wnfs.readUtf8 base
        { path = [ "state.json" ]
        , tag = Codec.encodeToString 0 codecFileSystemAction LoadedInitialState
        }
        |> Ports.wnfsRequest
    )


notAuthenticated : Model -> ( Model, Cmd Msg )
notAuthenticated model =
    ( { model | page = SignIn }
    , Cmd.none
    )


updateShoppingList : ShoppingListMsg -> Model -> ( Model, Cmd Msg )
updateShoppingList msg model =
    case model.page of
        ShoppingList shoppingList ->
            case msg of
                CheckItem indexToToggle ->
                    ( { model
                        | page =
                            ShoppingList
                                { shoppingList
                                    | items =
                                        shoppingList.items
                                            |> List.indexedMap
                                                (\index item ->
                                                    if index == indexToToggle then
                                                        { item | checked = not item.checked }

                                                    else
                                                        item
                                                )
                                }
                      }
                    , Cmd.none
                    )

        _ ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Browser.Document Msg
view model =
    { title = "Flatmate"
    , body =
        [ Html.Styled.toUnstyled
            (View.desktopScaffolding
                (case model.page of
                    Loading message ->
                        [ View.loadingScreen
                            { message = message }
                        ]

                    SignIn ->
                        [ View.signinScreen
                            { onSignIn = WebnativeMsg RedirectToLobby }
                        ]

                    ShoppingList shoppingList ->
                        View.appShell
                            [ shoppingList.items
                                |> List.indexedMap
                                    (\index { checked, name } ->
                                        View.shoppingListItem
                                            { checked = checked
                                            , onCheck = ShoppingListMsg (CheckItem index)
                                            , content = [ text name ]
                                            }
                                    )
                                |> View.shoppingList
                            , View.shoppingListActions
                                [ View.shoppingListActionButton []
                                    { icon = FeatherIcons.trash2
                                    , name = "Clear Checked"
                                    }
                                ]
                            ]
                )
            )
        ]
    }



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Browser.application
        { view = view
        , init = init
        , update = \msg model -> update msg model
        , subscriptions = subscriptions
        , onUrlRequest = UrlRequest
        , onUrlChange = UrlChanged
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Ports.initializedWebnative
            (Json.decodeValue Webnative.decoderState >> Initialized >> WebnativeMsg)
        , Ports.wnfsResponse (GotResponse >> WebnativeMsg)
        ]



-- Codecs


codecShoppingListModel : Codec ShoppingListModel
codecShoppingListModel =
    Codec.object ShoppingListModel
        |> Codec.field "items"
            .items
            (Codec.list
                (Codec.object (\checked name -> { checked = checked, name = name })
                    |> Codec.field "checked" .checked Codec.bool
                    |> Codec.field "name" .name Codec.string
                    |> Codec.buildObject
                )
            )
        |> Codec.buildObject


codecFileSystemAction : Codec FileSystemAction
codecFileSystemAction =
    Codec.custom
        (\cLoadedInitialState value ->
            case value of
                LoadedInitialState ->
                    cLoadedInitialState
        )
        |> Codec.variant0 "LoadedInitialState" LoadedInitialState
        |> Codec.buildCustom
