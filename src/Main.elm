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
import UUID
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
    { inputValue : String
    , items : List { checked : Bool, name : String }
    }


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
    , inputValue = ""
    }


base : Wnfs.Base
base =
    Wnfs.AppData baseParams


baseParams : { name : String, creator : String }
baseParams =
    { creator = "matheus23-test"
    , name = "Flatmate"
    }



---- UPDATE ----


type Msg
    = NoOp
    | Heartbeat
    | ShoppingListMsg ShoppingListMsg
    | WebnativeMsg WebnativeMsg
      -- Url
    | UrlRequest Browser.UrlRequest
    | UrlChanged Url


type ShoppingListMsg
    = CheckItem Int
    | ClearCheckedClicked
    | ShoppingListInputSubmitted
    | ShoppingListInputChanged String


type WebnativeMsg
    = RedirectToLobby
    | Initialized (Result Json.Error Webnative.State)
    | GotResponse Webnative.Response


type FileSystemAction
    = LoadedInitialState
    | CheckedStateExists
    | CreatedInitialState ShoppingListModel
    | SavedState
    | ReloadedState


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )

        Heartbeat ->
            ( model
            , case model.page of
                ShoppingList _ ->
                    reloadState

                _ ->
                    Cmd.none
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
                            , Ports.log "Loaded from existing state."
                            )

                        Err error ->
                            ( model
                            , Cmd.batch
                                [ Ports.log
                                    ("Couldn't load state from wnfs:\n"
                                        ++ Json.errorToString error
                                        ++ "\nOverwriting with a clean state."
                                    )
                                , createInitialState initShoppingList
                                ]
                            )

                Ok ( LoadedInitialState, _ ) ->
                    ( model, Ports.log "unexpected response type for 'LoadedInitialState'" )

                Ok ( CheckedStateExists, Wnfs.Boolean exists ) ->
                    if exists then
                        ( { model | page = Loading "Loading saved shopping list" }
                        , loadInitialState
                        )

                    else
                        ( { model | page = Loading "Creating initial shopping list" }
                        , createInitialState initShoppingList
                        )

                Ok ( CheckedStateExists, _ ) ->
                    ( model, Ports.log "unexpected response type for 'CheckedStateExists'" )

                Ok ( SavedState, _ ) ->
                    ( model
                    , Cmd.batch
                        [ Ports.log "saving current state in wnfs."
                        , Wnfs.publish |> Ports.wnfsRequest
                        ]
                    )

                Ok ( CreatedInitialState shoppingList, _ ) ->
                    ( { model | page = ShoppingList shoppingList }
                    , Cmd.batch
                        [ Ports.log "Created initial state."
                        , Wnfs.publish |> Ports.wnfsRequest
                        ]
                    )

                Ok ( ReloadedState, Wnfs.Utf8Content stateJson ) ->
                    case Codec.decodeString codecShoppingListModel stateJson of
                        Ok state ->
                            ( { model
                                | page = ShoppingList state
                              }
                            , Ports.log "Reloaded state."
                            )

                        Err error ->
                            ( model
                            , Ports.log
                                ("Couldn't reload state from wnfs:\n"
                                    ++ Json.errorToString error
                                )
                            )

                Ok ( ReloadedState, _ ) ->
                    ( model, Ports.log "unexpected response type for 'ReloadedState'" )

                Err errorMsg ->
                    ( model, Ports.log ("got an error from wnfs: " ++ errorMsg) )


authenticated : Model -> ( Model, Cmd Msg )
authenticated model =
    ( { model | page = Loading "Looking for saved shopping list" }
    , checkStateExists
    )


notAuthenticated : Model -> ( Model, Cmd Msg )
notAuthenticated model =
    ( { model | page = SignIn }
    , Cmd.none
    )


checkStateExists : Cmd Msg
checkStateExists =
    Wnfs.exists base
        { path = [ "state.json" ]
        , tag = Codec.encodeToString 0 codecFileSystemAction CheckedStateExists
        }
        |> Ports.wnfsRequest


loadInitialState : Cmd Msg
loadInitialState =
    Wnfs.readUtf8 base
        { path = [ "state.json" ]
        , tag = Codec.encodeToString 0 codecFileSystemAction LoadedInitialState
        }
        |> Ports.wnfsRequest


createInitialState : ShoppingListModel -> Cmd Msg
createInitialState shoppingList =
    Wnfs.writeUtf8 base
        { path = [ "state.json" ]
        , tag = Codec.encodeToString 0 codecFileSystemAction (CreatedInitialState shoppingList)
        }
        (Codec.encodeToString 4 codecShoppingListModel shoppingList)
        |> Ports.wnfsRequest


saveState : ShoppingListModel -> Cmd Msg
saveState shoppingList =
    Wnfs.writeUtf8 base
        { path = [ "state.json" ]
        , tag = Codec.encodeToString 0 codecFileSystemAction SavedState
        }
        (Codec.encodeToString 4 codecShoppingListModel shoppingList)
        |> Ports.wnfsRequest


reloadState : Cmd Msg
reloadState =
    Wnfs.readUtf8 base
        { path = [ "state.json" ]
        , tag = Codec.encodeToString 0 codecFileSystemAction ReloadedState
        }
        |> Ports.wnfsRequest


updateShoppingList : ShoppingListMsg -> Model -> ( Model, Cmd Msg )
updateShoppingList msg model =
    case model.page of
        ShoppingList shoppingList ->
            case msg of
                CheckItem indexToToggle ->
                    let
                        newShoppingList =
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
                    in
                    ( { model | page = ShoppingList newShoppingList }
                    , saveState newShoppingList
                    )

                ClearCheckedClicked ->
                    let
                        newShoppingList =
                            { shoppingList
                                | items =
                                    shoppingList.items
                                        |> List.filter (not << .checked)
                            }
                    in
                    ( { model | page = ShoppingList newShoppingList }
                    , saveState newShoppingList
                    )

                ShoppingListInputSubmitted ->
                    let
                        trimmedValue =
                            String.trim shoppingList.inputValue

                        newShoppingList =
                            { shoppingList
                                | items =
                                    shoppingList.items
                                        ++ [ { name = trimmedValue
                                             , checked = False
                                             }
                                           ]
                                , inputValue = ""
                            }
                    in
                    if String.isEmpty trimmedValue then
                        ( model, Cmd.none )

                    else
                        ( { model | page = ShoppingList newShoppingList }
                        , saveState newShoppingList
                        )

                ShoppingListInputChanged value ->
                    ( { model | page = ShoppingList { shoppingList | inputValue = value } }
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
                                    , onClick = ShoppingListMsg ClearCheckedClicked
                                    }
                                ]
                            , View.shoppingListInputSpacer
                            , View.shoppingListInput []
                                { onAdd = ShoppingListMsg ShoppingListInputSubmitted
                                , onInput = ShoppingListMsg << ShoppingListInputChanged
                                , value = shoppingList.inputValue
                                }
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
        , Ports.heartbeat (\_ -> Heartbeat)
        ]



-- Codecs


codecShoppingListModel : Codec ShoppingListModel
codecShoppingListModel =
    Codec.object (ShoppingListModel "")
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
        (\cLoadedInitialState cCheckedStateExists cCreatedInitialState cSavedState cReloadedState value ->
            case value of
                LoadedInitialState ->
                    cLoadedInitialState

                CheckedStateExists ->
                    cCheckedStateExists

                CreatedInitialState a ->
                    cCreatedInitialState a

                SavedState ->
                    cSavedState

                ReloadedState ->
                    cReloadedState
        )
        |> Codec.variant0 "LoadedInitialState" LoadedInitialState
        |> Codec.variant0 "CheckedStateExists" CheckedStateExists
        |> Codec.variant1 "CreatedInitialState" CreatedInitialState codecShoppingListModel
        |> Codec.variant0 "SavedState" SavedState
        |> Codec.variant0 "ReloadedState" ReloadedState
        |> Codec.buildCustom
