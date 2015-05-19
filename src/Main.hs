{-# Language OverloadedStrings, QuasiQuotes #-}

module Main where

import Web.Scotty
import qualified Data.Text.Lazy as T

import Text.Hamlet
import Text.Blaze.Html.Renderer.Text

import Database.SQLite.Simple
import Control.Applicative
import Control.Monad.IO.Class

import System.Random
import Control.Exception.Base (bracket)

data Mapping = Mapping T.Text T.Text


getIndexH = do
  (html . renderHtml) [shamlet|
  $doctype 5
  <html>
    <head>
      <title>Url Shortener
  <body>
    <form method="POST" action="/create">
      <input name="url">
      <button type="submit">Create shortcut
  |]


postCreateH connection = do
  url <- param "url"
  key <- liftIO $ createRandomKey 5
  liftIO $ execute connection
    "INSERT INTO mapping (key, url) VALUES (?, ?)"
    (key :: T.Text, url :: T.Text)
  html ("Created shortcut "
    `T.append` key
    `T.append`  " -> "
    `T.append` url)

getLookupH connection = do
  key <- param "key"
  result <- liftIO $ query
    connection
      "SELECT url FROM mapping WHERE key = ?"
      (Only (key :: T.Text))
  case result of
    [Only url]  -> redirect url
    _           -> html "Ooops!"



createRandomKey 0 = return ""
createRandomKey len = do
  randomChar <- randomRIO ('a', 'z')
  rest <- createRandomKey (len-1)
  return $ randomChar `T.cons` rest


app connection = scotty 3000 $ do
  get "/"         getIndexH
  post "/create"  (postCreateH connection)
  get "/:key"     (getLookupH connection)


main = do
  bracket
    (open "mapping.db")
    close
    app
