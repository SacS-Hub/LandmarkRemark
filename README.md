#  Landmark Remark 

An native iOS app based on location tagging where a user can tag a remark/note at their current location. This added remark/note will be visible to self and all the other users. 

Below are few of the high level features:

1. As a user (of the application) I can see my current location on a map 
2. As a user I can save a short note at my current location
3. As a user I can see notes that I have saved at the location they were saved on the map
4. As a user I can see the location, text, and user-name of notes other users have saved
5. As a user I have the ability to search for a note based on contained text or user-name

## Solution

While designing the given requirement, below implicit requirements were considered during the implementation 
1. Login/Logout mechanism to allow controlled access to the application.
2. Search remarks/notes based on the both user and notes.
3. List/Table view to display all the notes details
4. Timestamp associated with each remark/note
5. Separate action to view/filter notes specific to current logged in user

Each user story were broken into tasks to better plan the development. 

## Approach
1. MVVM architecture was chosen for better separation of concerns.
2. Followed delegation design pattern for interaction between View and ViewModel
3. Implemented Unit Test to test service class

## Technology Used
 ### Tools
 1. IDE: Xcode 12.5.1
 2. Language: Swift 5
 3. Dependency Manager: Cocoapod
 4. Backend support: Firebase Auth, Firebase UI and Firebase Database.

## Efforts
It took a total of 15-17 hours to develop this applicaton which involves below:
1. Analysis and solutionising - Appox. 2 hrs
2. Integrating Firebase components - Approx. 2 hrs
3. UI development - Approx. 4hrs
4. Firebase service integration for login, database etc. - Approx. 3hrs
5. Testing app functinality in simulator & device - Approx. 1.5hrs
6. Bug fixes - Approx. 1hr 
7. Code optimization - 1.5 hrs
8. Writing few unit test cases - 1 hr

## Known Limitations

There are few limitiation with this solution
1. It has few Firebase related warning.
2. More unit test cases could have been written
3. Annonation representation could have been improved by providing more color option 
4. Login via FB will only work on simulator as the app requires appstore approval for live FB login.
5. Login via phone number works only for hard code phone numbers due to free subscription
#### use +97430092324 and 455321 as verification code

Although the app covers all the 5 backlog user stories below good-to-have feature was not achieved due to time constraints.
1. A small information icon ("i") in Annotation view to show multiline remark/note in a secondary view. However, this remark/note can be viewed in full in list/table view.
2. Distance info of each remark/note from the current location.
3. UI can be improved even better especially the annotation image i.e. pin
4. Animated transition while switching between map and list/table view 
5. Firebase Crashlytics could have been leveraged to get insight of app issues and crashes


    
