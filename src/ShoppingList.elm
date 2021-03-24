module ShoppingList exposing (Item, ItemHash, ItemProperties, Items, codec, codecItem, empty, hash, insertAtEnd, map, traverse, update)

import Codec exposing (Codec)
import Dict
import IntDict exposing (IntDict)
import Murmur3


type alias WithItemProperties a =
    { a
        | checked : Bool
        , removed : Bool
    }


type alias Item =
    WithItemProperties
        { name : String }


type alias ItemProperties =
    WithItemProperties {}


type ItemHash
    = ItemHash Int


type Items
    = Items
        { items : IntDict Item

        -- List of hashes
        -- invariant: sort (IntDict.keys items) == sort order
        , order : List Int
        }


hash : Item -> ItemHash
hash { name } =
    ItemHash (Murmur3.hashString 0 name)


empty : Items
empty =
    Items
        { items = IntDict.empty
        , order = []
        }


insertAtEnd : Item -> Items -> Items
insertAtEnd item (Items { items, order }) =
    let
        (ItemHash itemHash) =
            hash item
    in
    Items
        { items = IntDict.insert itemHash item items
        , order =
            case List.partition ((==) itemHash) order of
                ( [], elems ) ->
                    elems ++ [ itemHash ]

                ( hashes, elems ) ->
                    elems ++ hashes
        }


translateChange : (ItemProperties -> ItemProperties) -> Item -> Item
translateChange changeProperties item =
    let
        newProperties =
            changeProperties
                { checked = item.checked
                , removed = item.removed
                }
    in
    { name = item.name
    , checked = newProperties.checked
    , removed = newProperties.removed
    }


update : (ItemProperties -> ItemProperties) -> ItemHash -> Items -> Items
update change (ItemHash itemHash) (Items list) =
    Items
        { list
            | items =
                IntDict.update
                    itemHash
                    (Maybe.map (translateChange change))
                    list.items
        }


map : (ItemProperties -> ItemProperties) -> Items -> Items
map change (Items list) =
    Items
        { list
            | items =
                IntDict.map
                    (\_ -> translateChange change)
                    list.items
        }


traverse : (Item -> List a) -> Items -> List a
traverse f (Items list) =
    let
        traverseHash itemHash =
            case IntDict.get itemHash list.items of
                Just item ->
                    f item

                Nothing ->
                    []
    in
    List.concatMap traverseHash list.order


codec : Codec Items
codec =
    Codec.object (\items order -> { items = items, order = order })
        |> Codec.field "items" .items (codecIntDict codecItem)
        |> Codec.field "order" .order (Codec.list Codec.int)
        |> Codec.buildObject
        |> Codec.map (\list -> Items list) (\(Items list) -> list)


codecItem : Codec Item
codecItem =
    Codec.object (\name checked removed -> { name = name, checked = checked, removed = removed })
        |> Codec.field "name" .name Codec.string
        |> Codec.field "checked" .checked Codec.bool
        |> Codec.field "removed" .removed Codec.bool
        |> Codec.buildObject


codecIntDict : Codec v -> Codec (IntDict v)
codecIntDict codecValue =
    Codec.dict codecValue
        |> Codec.map
            (\dict ->
                dict
                    |> Dict.toList
                    |> List.filterMap
                        (\( key, value ) ->
                            key
                                |> String.toInt
                                |> Maybe.map (\int -> ( int, value ))
                        )
                    |> IntDict.fromList
            )
            (\intDict ->
                intDict
                    |> IntDict.toList
                    |> List.map (\( key, value ) -> ( String.fromInt key, value ))
                    |> Dict.fromList
            )
