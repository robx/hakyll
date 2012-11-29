--------------------------------------------------------------------------------
-- | Exports a datastructure for the top-level hakyll configuration
module Hakyll.Core.Configuration
    ( Verbosity (..)
    , Configuration (..)
    , shouldIgnoreFile
    , defaultConfiguration
    ) where


--------------------------------------------------------------------------------
import           Data.List          (isPrefixOf, isSuffixOf)
import           System.FilePath    (normalise, takeFileName)


--------------------------------------------------------------------------------
import           Hakyll.Core.Logger


--------------------------------------------------------------------------------
data Configuration = Configuration
    { -- | Directory in which the output written
      destinationDirectory :: FilePath
    , -- | Directory where hakyll's internal store is kept
      storeDirectory       :: FilePath
    , -- | Directory where hakyll finds the files to compile. This is @.@ by
      -- default.
      providerDirectory    :: FilePath
    , -- | Function to determine ignored files
      --
      -- In 'defaultHakyllConfiguration', the following files are ignored:
      --
      -- * files starting with a @.@
      --
      -- * files starting with a @#@
      --
      -- * files ending with a @~@
      --
      -- * files ending with @.swp@
      --
      -- Note that the files in @destinationDirectory@ and @storeDirectory@ will
      -- also be ignored. Note that this is the configuration parameter, if you
      -- want to use the test, you should use @shouldIgnoreFile@.
      --
      ignoreFile           :: FilePath -> Bool
    , -- | Here, you can plug in a system command to upload/deploy your site.
      --
      -- Example:
      --
      -- > rsync -ave 'ssh -p 2217' _site jaspervdj@jaspervdj.be:hakyll
      --
      -- You can execute this by using
      --
      -- > ./hakyll deploy
      --
      deployCommand        :: String
    , -- | Use an in-memory cache for items. This is faster but uses more
      -- memory.
      inMemoryCache        :: Bool
      -- | Verbosity for the logger
    , verbosity            :: Verbosity
    }


--------------------------------------------------------------------------------
-- | Default configuration for a hakyll application
defaultConfiguration :: Configuration
defaultConfiguration = Configuration
    { destinationDirectory = "_site"
    , storeDirectory       = "_cache"
    , providerDirectory    = "."
    , ignoreFile           = ignoreFile'
    , deployCommand        = "echo 'No deploy command specified'"
    , inMemoryCache        = True
    , verbosity            = Message
    }
  where
    ignoreFile' path
        | "."    `isPrefixOf` fileName = True
        | "#"    `isPrefixOf` fileName = True
        | "~"    `isSuffixOf` fileName = True
        | ".swp" `isSuffixOf` fileName = True
        | otherwise                    = False
      where
        fileName = takeFileName path


--------------------------------------------------------------------------------
-- | Check if a file should be ignored
shouldIgnoreFile :: Configuration -> FilePath -> Bool
shouldIgnoreFile conf path =
    destinationDirectory conf `isPrefixOf` path' ||
    storeDirectory conf `isPrefixOf` path' ||
    ignoreFile conf path'
  where
    path' = normalise path
