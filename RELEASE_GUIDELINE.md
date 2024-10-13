# Release Guideline
I made this so the next Chariz releases wont have bugs.

## Getting Started
A Chariz release should not be some experimental build of FridaCodeManager. It should be a fully debuged version that is fully tested using the testing guideline down there. It should pass all of these points! If it doesnt pass each of these point the build of FridaCodeManager is concidered being not qualified for Chariz! We take our users seriously and want that they get what they think they get!

## Test Checklist
- Compiling
  - No Errors
  - No Warnings
- App
  - Basic/Home
    - Opens without a crash
    - Opens without transparent background
    - Ensure that the app has a container
    - Ensure that the app has its needed entitlements
    - Ensure that about page, the changelog and the build all do have the matching version of the build
    - Ensure that the changelog is formatted probably
      - Ensure that the changelog is scrollable
    - Ensure creating projects with all available Schemes work
      - Ensure that all schemes are available to the user
      - Ensure that you cannot create a project without `Application Name` or `Bundle Identifier`
    - Ensure importing projects does work
      - Ensure that existing projects when re-imported do get a different unique user identifier assigned
  - Projects
    - Ensure that projects list appropriately
      - Ensure projects can be exported with the result of a document share view + ensure that the file can actually be exported (.sproj)
      - Ensure projects apps can be exported with the same result. (.ipa)
      - Ensure projects can be removed
      - Ensure projects preferences can be opened
    - Project Preferences
      - Ensure that the title is the projects name
      - Ensure all NavigationLinks have the correct title and SFSymbol
      - Ensure all NavigationLinks work and link to the correct destination view
      - Ensure all Views of these NavigationLinks work correctly (please test all buttons and features!)
    - Ensure that projects root can be opened correctly
    - File Manager
      - Ensure that folders are listed first and then files
      - Ensure that files do have the correct/comfortable colors
      - Ensure that the characters in the files are corectly + comfortably scaled
      - Ensure opening sub directories works
      - Ensure opening files work (Code Editor)
      - Ensure the Menu in the top right corner does work
        - It should show in the project root a build and a create button
        - It should show in the project sub directories only the create button
    - Code Editor (for the test please use a file that has maximum 400 lines)
      - Ensure that the file opens without any type of flickering or glitching
      - Ensure that highlighting works correctly
      - Ensure that the keyboard opens when you press on the code
      - Ensure that the ToolBar works correctly
        - It should be directly over the keyboard
        - Ensure that it shows its toolbar elements correctly
        - Ensure that the buttons do what they are supposed to do
        - Ensure that the Line counter work
          - It should show a Number and now n/a
          - It should show the exact Line number the Cursor is on
          - It should update when the cursor gets dragged
      - Ensure that the code is correctly highlighted for the filetype
    - SeansBuild
      - Ensure that Compiling works
        - Ensure that it can compile C, C++, Objective-C and Objective-C++
        - Ensure that it can combine all of the above mentioned languages
        - Ensure that the file finder and frameworks finder work
          - Both should ignore "Resources" folder by default
          - File finder should find all C, C++. Objective-C and Objective-C++ files
        - Ensure that the API works
          - Ensure RootHelperPoC from 1.4.x is compilable
          - Ensure it works as explained on https://fridacodemanager.github.io/userguide/adv.html
      - Ensure that the build system logs its logs probably
