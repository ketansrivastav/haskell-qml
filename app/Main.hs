{-# LANGUAGE OverloadedStrings #-}
import qualified Graphics.QML as QML
import qualified Data.Text as T
import Control.Concurrent.STM
import System.FilePath

-- Simple STM state for text transformation
newtype TextState = TextState (TVar T.Text)

-- Initialize STM state
newTextState :: IO TextState
newTextState = TextState <$> newTVarIO ""

-- Get current text
getText :: TextState -> IO T.Text
getText (TextState tvar) = readTVarIO tvar

-- Set text and return transformed version
setText :: TextState -> T.Text -> IO T.Text
setText (TextState tvar) newText = do
    let transformed = T.toUpper newText
    atomically $ writeTVar tvar transformed
    return transformed

main :: IO ()
main = do
    putStrLn "Starting STM Text Transform App..."
    
    -- Initialize STM state  
    textState <- newTextState
    
    -- Create signal for updates
    updateSignal <- QML.newSignalKey :: IO (QML.SignalKey (IO ()))
    
    -- Create QML class with SELF property (key fix!)
    qmlClass <- QML.newClass [
        -- CRITICAL: Self property for QML access  
        QML.defPropertyRO "self" (\obj -> return (obj :: QML.ObjRef ())),
        
        -- Input text property (read/write)
        QML.defPropertySigRW' "inputText" updateSignal
            (\_ -> getText textState)
            (\obj newText -> do
                transformed <- setText textState newText
                QML.fireSignal updateSignal obj
                putStrLn $ "Transformed: " ++ T.unpack newText ++ " -> " ++ T.unpack transformed
                return ()),
                
        -- Output text property (read-only, shows transformed text)
        QML.defPropertySigRO' "outputText" updateSignal $ \_ -> do
            getText textState
        ]
    
    -- Create object instance
    qmlObj <- QML.newObject qmlClass ()
    putStrLn "QML object created with STM text transformation"
    
    -- Run QML engine
    putStrLn "Starting QML engine..."
    QML.runEngineLoop QML.defaultEngineConfig {
        QML.initialDocument = QML.fileDocument ("qml" </> "main.qml"),
        QML.contextObject = Just $ QML.anyObjRef qmlObj
    }
    
    putStrLn "App finished"
