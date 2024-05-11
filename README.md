# ZTronDataModel

This module is at the core of ZombieTron/Core packages suite. It defines the SQLite tables that model the relationships between game studios, their games, the maps for each game, the tabs a game is composed of, the tools for each tab, and most importantly it defines the structure of carousels, offering a persistance framework for the settings of each image. 

This package also defines triggers that propagate updates and deletion appropriately through the table, and a more convenient interface to SQLite transactions and statements execution, as well as abstracting the rest of the application from knowing the database name. 

Each table is thoroughly documented in its own swift file, as well as their respective triggers, with expected behavior and a list of constraints that are expected to be satisfied throughout the whole app but aren't enforced via SQL, and those that are. 

## Usage Warnings

The structure of the tables is subject to variations. The programmer commits to the interfaces defined under ZTronDataModel / Extentions / CRUD / DBMS.CRUD.READ Models, in the sense that existing fields will be supported long term and not be removed, and their semantics and representation will not be altered. Though, the owner grants himself the right to add new fields in the future to such interfaces.

This package defines under ZTronDataModel / Extentions / CRUD the API for database crud operations and it's strongly recommended to not perform said operations bypassing the existing interface, because that'd cause the dependent code to be fragile with respect to changes of this package's tables definitions.

The methods defined in this package aren't executed inside a transaction by default. CRUD operations are potentially expensive since they involve read/write from secondary memory, therefore it's good practice to invoke it through a background thread. Though you can't push updates to SwiftUI `View`s from threads other than main. Calls to methods that cause `View` updates should be wrapped like this:

```
DispatchQueue.main.async {
    // Perform method that updates View
}
```

## Testing state

This package is currently being tested. Heuristically the code is running properly under operative circumstances. 

## Future direction

1. Depending on the concrete implementation of the carousel's view, support for svg outlines asset names might be added to replace the need for OutlineShape. This would allow for SVG caching, positively impacting performance.
2. New CRUD operations will be added as needed during coding.
3. Adding support for callbacks for successful/failed transaction and SQL statements in general.
4. Create a serial queue to push transactions to, so that they're guaranteed to be executed in the same order as their calls.
