# Core Test Cases

## 1.1 Create a new document using the main menu
- Preconditions: the app is running.
- Steps: `File -> New...`
- Expected result: 
	* A new document window opens with an empty list. 
	* Window title - "Untitled" 

## 1.2 Create a new document using a shortcut
- Preconditions: the app is running.
- Steps: `Cmd + N`
- Expected result: 
	* A new document window opens with an empty list. 
	* Window title - "Untitled"

===

## 2.1 Open an existing document using the main menu
- Preconditions: the app is running.
- Steps: `File -> Open...` -> Select an existing document file with the `.nlist` extension.
- Expected result: The selected document window opens.

## 2.2 Open an existing document using a shortcut
- Preconditions: the app is running.
- Steps: `Cmd + O` -> Select an existing document file with the `.nlist` extension.
- Expected result: The selected document window opens.

===

## 3.1 Close a saved document using the main menu
- Preconditions:
	* A document is open.
	* The document is saved.
- Steps: `File -> Close`
- Expected result: The document window is closed.

## 3.2 Close a saved document using a shortcut
- Preconditions:
	* A document is open.
	* The document is saved.
- Steps: `Cmd + W`
- Expected result: The document window is closed.

## 3.3 Close an unsaved document using a shortcut
- Preconditions:
	* A new document is open.
	* The document has unsaved changes.
- Steps: `Cmd + W`
- Expected result: The save confirmation dialog is shown.
