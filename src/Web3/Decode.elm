module Web3.Decode exposing (..)

import BigInt exposing (BigInt)
import Json.Decode as Decode exposing (Decoder)
import Hex
import Time exposing (Time)
import Web3.Utils exposing (remove0x)


stringInt : Decoder Int
stringInt =
    resultToDecoder String.toInt


hexInt : Decoder Int
hexInt =
    resultToDecoder (remove0x >> Hex.fromString)


bigInt : Decoder BigInt
bigInt =
    resultToDecoder (BigInt.fromString >> Result.fromMaybe "Error decoding hex to BigInt")


hexTime : Decoder Time
hexTime =
    resultToDecoder (remove0x >> Hex.fromString >> Result.map toFloat)


hexBool : Decoder Bool
hexBool =
    let
        isBool n =
            case n of
                "0x0" ->
                    Ok False

                "0x1" ->
                    Ok True

                _ ->
                    Err <| "Error decoding " ++ n ++ "as bool."
    in
        resultToDecoder isBool


resultToDecoder : (String -> Result String a) -> Decoder a
resultToDecoder strToResult =
    let
        convert n =
            case strToResult n of
                Ok val ->
                    Decode.succeed val

                Err error ->
                    Decode.fail error
    in
        Decode.string |> Decode.andThen convert
