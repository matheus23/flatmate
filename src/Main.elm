module Main exposing (..)

import Browser
import Browser.Navigation as Navigation
import Codec exposing (Codec)
import FeatherIcons
import FileSystem
import Html.Styled exposing (text)
import Json.Decode as Json
import Ports
import Procedure
import Procedure.Program
import Random
import ShoppingList
import Tailwind.Utilities
import UUID
import Url exposing (Url)
import View.Common as View
import View.ShoppingList
import Webnative.Types



---- MODEL ----


type alias Model =
    { uuidSeeds : UUID.Seeds
    , navKey : Navigation.Key
    , page : Page
    , procedureModel : Procedure.Program.Model Msg
    , isPublishing : Bool
    , isDirty : Bool
    }


type Page
    = Loading String
    | SignIn
    | ShoppingList ShoppingListModel


type alias ShoppingListModel =
    { inputValue : String
    , list : ShoppingList.Items
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
      , procedureModel = Procedure.Program.init
      , isPublishing = False
      , isDirty = False
      }
    , Cmd.none
    )


initShoppingList : ShoppingListModel
initShoppingList =
    { list = ShoppingList.empty
    , inputValue = ""
    }



---- UPDATE ----


type Msg
    = NoOp
    | RedirectToLobby
    | Initialized (Result Json.Error Webnative.Types.State)
    | Heartbeat
    | ShoppingListMsg ShoppingListMsg
    | StateJsonExists (Result String Bool)
    | LoadedInitialState (Result String String)
    | CreatedInitialState (Result String ShoppingListModel)
    | SavedState (Result String ())
    | ReloadedState (Result String String)
    | Published (Result String FileSystem.CID)
    | ClickUploadIcon
      -- Url
    | UrlRequest Browser.UrlRequest
    | UrlChanged Url
      -- elm-procedure
    | ProcedureMsg (Procedure.Program.Msg Msg)


type ShoppingListMsg
    = CheckItem ShoppingList.ItemHash
    | ClearCheckedClicked
    | ShoppingListInputSubmitted
    | ShoppingListInputChanged String


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

        RedirectToLobby ->
            ( model
            , Ports.redirectToLobby ()
            )

        Initialized result ->
            case result of
                Err error ->
                    ( model
                    , Ports.log ("Error during webnative initialisation: " ++ Json.errorToString error)
                    )

                Ok state ->
                    case state of
                        Webnative.Types.NotAuthorised _ ->
                            notAuthenticated model

                        Webnative.Types.AuthCancelled _ ->
                            notAuthenticated model

                        Webnative.Types.AuthSucceeded _ ->
                            authenticated model

                        Webnative.Types.Continuation _ ->
                            authenticated model

        StateJsonExists result ->
            case result of
                Ok exists ->
                    if exists then
                        ( { model | page = Loading "Loading saved shopping list" }
                        , FileSystem.readUtf8 "private/Apps/matheus23-test/Flatmate/state.json"
                            |> Procedure.try ProcedureMsg LoadedInitialState
                        )

                    else
                        ( { model | page = Loading "Creating initial shopping list" }
                        , createInitialState initShoppingList
                        )

                Err error ->
                    ( model
                    , Ports.log ("Error during StateJsonExists: " ++ error)
                    )

        LoadedInitialState result ->
            case result of
                Ok stateJson ->
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
                                    (String.join "\n"
                                        [ "Couldn't load state from wnfs:"
                                        , Json.errorToString error
                                        , "Overwriting with a clean state."
                                        ]
                                    )
                                , createInitialState initShoppingList
                                ]
                            )

                Err error ->
                    ( model
                    , Ports.log ("Error during LoadedInitialState: " ++ error)
                    )

        CreatedInitialState result ->
            case result of
                Ok shoppingList ->
                    ( { model
                        | page = ShoppingList shoppingList
                        , isPublishing = True
                      }
                    , Cmd.batch
                        [ Ports.log "Created initial state."
                        , FileSystem.publish
                            |> Procedure.try ProcedureMsg Published
                        ]
                    )

                Err error ->
                    ( model
                    , Ports.log ("Error during CreatedInitialState: " ++ error)
                    )

        SavedState result ->
            case result of
                Ok _ ->
                    ( { model
                        | isDirty = True
                      }
                    , Ports.log "Saving current state in wnfs."
                    )

                Err error ->
                    ( model
                    , Ports.log ("Error during SavedState: " ++ error)
                    )

        ReloadedState result ->
            case result of
                Ok stateJson ->
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

                Err error ->
                    ( model
                    , Ports.log ("Error during ReloadedState: " ++ error)
                    )

        Published result ->
            case result of
                Ok _ ->
                    ( { model | isPublishing = False }
                    , Cmd.none
                    )

                Err error ->
                    ( model
                    , Ports.log ("Error during publishing: " ++ error)
                    )

        ClickUploadIcon ->
            ( { model
                | isPublishing = True
                , isDirty = False
              }
            , FileSystem.publish
                |> Procedure.try ProcedureMsg Published
            )

        UrlRequest _ ->
            ( model, Cmd.none )

        UrlChanged _ ->
            ( model, Cmd.none )

        ProcedureMsg procedureMsg ->
            Procedure.Program.update procedureMsg model.procedureModel
                |> Tuple.mapFirst (\procedureModel -> { model | procedureModel = procedureModel })


authenticated : Model -> ( Model, Cmd Msg )
authenticated model =
    ( { model | page = Loading "Looking for saved shopping list" }
    , FileSystem.exists "private/Apps/matheus23-test/Flatmate/state.json"
        |> Procedure.try ProcedureMsg StateJsonExists
    )


notAuthenticated : Model -> ( Model, Cmd Msg )
notAuthenticated model =
    ( { model | page = SignIn }
    , Cmd.none
    )


createInitialState : ShoppingListModel -> Cmd Msg
createInitialState shoppingList =
    FileSystem.writeUtf8 "private/Apps/matheus23-test/Flatmate/state.json"
        (Codec.encodeToString 4 codecShoppingListModel shoppingList)
        |> Procedure.try ProcedureMsg (Result.map (\_ -> shoppingList) >> CreatedInitialState)


saveState : ShoppingListModel -> Cmd Msg
saveState shoppingList =
    FileSystem.writeUtf8 "private/Apps/matheus23-test/Flatmate/state.json"
        (Codec.encodeToString 4 codecShoppingListModel shoppingList)
        |> Procedure.try ProcedureMsg SavedState


reloadState : Cmd Msg
reloadState =
    FileSystem.readUtf8 "private/Apps/matheus23-test/Flatmate/state.json"
        |> Procedure.try ProcedureMsg ReloadedState


updateShoppingList : ShoppingListMsg -> Model -> ( Model, Cmd Msg )
updateShoppingList msg model =
    case model.page of
        ShoppingList shoppingList ->
            case msg of
                CheckItem itemHash ->
                    let
                        newShoppingList =
                            { shoppingList
                                | list =
                                    ShoppingList.update
                                        (\item ->
                                            { item | checked = not item.checked }
                                        )
                                        itemHash
                                        shoppingList.list
                            }
                    in
                    ( { model | page = ShoppingList newShoppingList }
                    , saveState newShoppingList
                    )

                ClearCheckedClicked ->
                    let
                        newShoppingList =
                            { shoppingList
                                | list =
                                    ShoppingList.map
                                        (\item ->
                                            if item.checked then
                                                { item | removed = True }

                                            else
                                                item
                                        )
                                        shoppingList.list
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
                                | list =
                                    shoppingList.list
                                        |> ShoppingList.insertAtEnd
                                            { name = trimmedValue
                                            , checked = False
                                            , removed = False
                                            }
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
                            { onSignIn = RedirectToLobby }
                        ]

                    ShoppingList shoppingList ->
                        let
                            renderedShoppingListItems =
                                shoppingList.list
                                    |> ShoppingList.traverse
                                        (\item ->
                                            if item.removed then
                                                []

                                            else
                                                [ View.ShoppingList.item
                                                    { checked = item.checked
                                                    , onCheck = ShoppingListMsg (CheckItem (ShoppingList.hash item))
                                                    , content = [ text item.name ]
                                                    }
                                                ]
                                        )
                        in
                        View.appShell
                            { headerIcons =
                                [ View.ShoppingList.headerIcon
                                    { icon = FeatherIcons.uploadCloud
                                    , onClick = ClickUploadIcon
                                    , disabled = model.isPublishing || not model.isDirty
                                    , styles = View.when model.isPublishing [ Tailwind.Utilities.animate_ping ]
                                    }

                                -- , View.ShoppingList.headerIcon
                                --     { icon = FeatherIcons.refreshCw
                                --     , disabled = False
                                --     , styles = [ Tailwind.Utilities.animate_spin ]
                                --     }
                                ]
                            , main =
                                [ if List.isEmpty renderedShoppingListItems then
                                    View.ShoppingList.emptyState

                                  else
                                    View.ShoppingList.view renderedShoppingListItems
                                , View.ShoppingList.actions
                                    (if List.isEmpty renderedShoppingListItems then
                                        []

                                     else
                                        [ View.ShoppingList.actionButton []
                                            { icon = FeatherIcons.trash2
                                            , name = "Clear Checked"
                                            , onClick = ShoppingListMsg ClearCheckedClicked
                                            }
                                        ]
                                    )
                                , View.ShoppingList.itemInputSpacer
                                , View.ShoppingList.itemInput []
                                    { onSubmit = ShoppingListMsg ShoppingListInputSubmitted
                                    , onInput = ShoppingListMsg << ShoppingListInputChanged
                                    , value = shoppingList.inputValue
                                    }
                                ]
                            }
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
subscriptions model =
    Sub.batch
        [ Ports.initializedWebnative
            (Json.decodeValue Webnative.Types.decoderState >> Initialized)
        , Procedure.Program.subscriptions model.procedureModel
        ]



-- Codecs


codecShoppingListModel : Codec ShoppingListModel
codecShoppingListModel =
    Codec.oneOf
        codecShoppingListModelV2
        [ codecShoppingListModelV1
            -- Convert old format to new format and vice versa
            |> Codec.map
                (\{ items } ->
                    { inputValue = ""
                    , list =
                        List.foldl
                            (\item list ->
                                list
                                    |> ShoppingList.insertAtEnd
                                        { name = item.name
                                        , checked = item.checked
                                        , removed = False
                                        }
                            )
                            ShoppingList.empty
                            items
                    }
                )
                (\shoppingListModel ->
                    { items =
                        shoppingListModel.list
                            |> ShoppingList.traverse
                                (\item ->
                                    if item.removed then
                                        []

                                    else
                                        [ { checked = item.checked, name = item.name } ]
                                )
                    }
                )
        ]


codecShoppingListModelV2 : Codec ShoppingListModel
codecShoppingListModelV2 =
    Codec.object (ShoppingListModel "")
        |> Codec.field "list" .list ShoppingList.codec
        |> Codec.buildObject


codecShoppingListModelV1 : Codec { items : List { checked : Bool, name : String } }
codecShoppingListModelV1 =
    Codec.object (\items -> { items = items })
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
