


# Haskell And QML Boilerplate using HsQML

## What It Does

- Type in the textbox → **Instantly transforms to UPPERCASE** in the label below
- **Thread-safe** state management using STM (Software Transactional Memory)
- **Real-time** property binding between Haskell and QML
- Clean, minimal codebase demonstrating functional reactive programming

##  Architecture Overview

### High-Level Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   QML Frontend  │◄──►│  HsQML Bridge   │◄──►│  STM Backend    │
│                 │    │                 │    │                 │
│ • TextBox       │    │ • Self Property │    │ • TVar T.Text   │
│ • Label         │    │ • Property Bind │    │ • Atomic Ops    │
│ • Real-time UI  │    │ • Signal System │    │ • Thread-safe   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Core Components

#### 1. **STM Backend** 
```haskell
-- Pure STM state management
newtype TextState = TextState (TVar T.Text)

newTextState :: IO TextState        -- Initialize empty TVar
getText :: TextState -> IO T.Text   -- Read current state  
setText :: TextState -> T.Text -> IO T.Text  -- Transform & store
```

**Purpose:** Thread-safe text storage and transformation
- **TVar** ensures atomic updates across threads
- **Pure functions** for state operations
- **Uppercase transformation** happens here

#### 2. **HsQML Bridge**
```haskell
-- The connector between QML and Haskell
qmlClass <- QML.newClass [
    QML.defPropertyRO "self" (\obj -> return obj),
    
    QML.defPropertySigRW' "inputText" updateSignal   -- Bidirectional
        (\_ -> getText textState)                    -- Read from STM
        (\obj newText -> do                          -- Write to STM
            transformed <- setText textState newText
            QML.fireSignal updateSignal obj),
            
    QML.defPropertySigRO' "outputText" updateSignal  -- Read-only
        (\_ -> getText textState)
]
```

**Purpose:** Bridges QML ↔ Haskell communication
- **Self Property** - Solves HsQML's contextObject bug
- **Property System** - Exposes STM state to QML
- **Signal System** - Notifies QML of state changes
- **Bidirectional Binding** - QML writes, Haskell transforms, QML reads

#### 3. **QML Frontend**
```qml
property var backend: self  // Uses self property fix

TextField {
    onTextChanged: {
        backend.inputText = text  // Write to Haskell STM
    }
}

Text {
    text: backend.outputText     // Read from Haskell STM
}
```

**Purpose:** User interface with real-time binding
- **Property Binding** - Automatic UI updates
- **Event Handling** - Captures user input
- **Data Display** - Shows transformed results

### Data Flow

```
User Types "hello"
       ↓
┌─────────────────┐
│ QML TextField   │ onTextChanged triggered
│ text: "hello"   │
└─────────────────┘
       ↓
┌─────────────────┐
│ HsQML Bridge    │ backend.inputText = "hello"
│ Property Write  │
└─────────────────┘
       ↓
┌─────────────────┐
│ STM Backend     │ setText("hello") → T.toUpper → "HELLO"
│ Transform Logic │ atomically $ writeTVar tvar "HELLO"
└─────────────────┘
       ↓
┌─────────────────┐
│ HsQML Bridge    │ QML.fireSignal updateSignal
│ Signal System   │
└─────────────────┘
       ↓
┌─────────────────┐
│ QML Label       │ backend.outputText reads "HELLO"
│ text: "HELLO"   │ UI automatically updates
└─────────────────┘
```

## 📁 Project Structure

```
haskell-qml-todo/
├── app/
│   └── Main.hs              # STM backend + HsQML bridge (66 lines)
├── qml/
│   └── main.qml             # QML interface (98 lines)
├── haskell-qml-todo.cabal   # Minimal dependencies
└── README.md                # This file
```

## 🛠️ Prerequisites

### System Requirements
- **Haskell** with GHC 9.6.7+
- **Cabal** 3.10+
- **Qt 5.15.3** (Qt5Core, Qt5Gui, Qt5Widgets, Qt5Network, Qt5Qml, Qt5Quick)
- **HsQML 0.3.6.1** (compatible with Qt5 only, not Qt6)

### Installing Dependencies

#### Ubuntu/Debian
```bash
# Install Qt5 development libraries
sudo apt-get install qtbase5-dev qtdeclarative5-dev qtquickcontrols2-5-dev

# Install Haskell Stack (if not already installed)
curl -sSL https://get.haskellstack.org/ | sh
```

#### macOS
```bash
# Install Qt5 via Homebrew
brew install qt@5

# Add Qt5 to PATH
export PATH="/usr/local/opt/qt@5/bin:$PATH"
```

## Building and Running


###  Build the Project
```bash
# Install dependencies and build
cabal update
cabal build

# Or build with explicit dependencies
cabal install --dependencies-only
cabal build
```

### 3. Run the Application
```bash
# Run the STM text transform app
cabal run haskell-qml-todo
```

### Alternative Build Commands
```bash
# Clean build
cabal clean && cabal build

