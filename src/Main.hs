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

data Mapping = Mapping { key :: T.Text, url :: T.Text } deriving (Show)

instance FromRow Mapping where
  fromRow = Mapping <$> field <*> field


getIndexH connection = do
  shorts <- liftIO $ getListShortened connection
  (html . renderHtml) [shamlet|
  $doctype 5
  <html>
    <head>
      <title>Url Shortener
  <body>
    <h1>Shorten URL
    <form method="POST" action="/create">
      <input name="url">
      <button type="submit">Create shortcut
    <hr>
    <h1>List of shortened URLs (top 10)
    $if null shorts
      <p>No shortened URLs yet!
    $else
    <ul>
      $forall (count, url) <- shorts
        <li>#{count} --> #{url}
  |]



getListShortened :: Connection -> IO [(Integer, T.Text)]
getListShortened connection = do
  result <- query_
    connection
    "SELECT count(key) as count, url FROM mapping GROUP BY url ORDER BY count desc LIMIT 10" :: IO [(Integer, T.Text)]
  return result








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
  get "/"         (getIndexH connection)
  post "/create"  (postCreateH connection)
  get "/:key"     (getLookupH connection)


main = do
  bracket
    (open "mapping.db")
    close
    app
