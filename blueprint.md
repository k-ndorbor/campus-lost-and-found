# Campus Lost and Found System Blueprint

## Project Overview

This project is a Campus Lost and Found System Flutter application with Firebase integration. The app will allow users to report lost and found items, view listings, and manage their reported items.

## Project Outline

*   **Styling and Design:** Implement the UI based on the provided Figma design, ensuring responsiveness and adherence to Material Design principles. Use the `google_fonts` package for typography as shown in the design.
*   **Features:**
    *   User Authentication (Firebase Authentication)
    *   Reporting Lost Items (Firebase Firestore)
    *   Reporting Found Items (Firebase Firestore)
    *   Viewing Lost Items (Firebase Firestore)
    *   Viewing Found Items (Firebase Firestore)
    *   Managing User's Items (Firebase Firestore)
    *   Image Upload for Items (Cloudinary)

## Current Request Plan
1. Set up Firebase in the project. (Completed)
2. Add necessary dependencies for Firebase, Google Fonts, and Go Router. (Added)
3. Create a basic theme based on the Figma design. (Created and Refined)
4. Implement the navigation structure using `go_router`. (Configured)
5. Implement the UI for the Home Screen based on the Figma design. (Implemented)
6. Implement the UI for the Lost Items Screen based on the Figma design. (Implemented)
7. Implement the UI for the Found Items Screen based on the Figma design. (Implemented)
8. Implement the UI for the Add Item Screen based on the Figma design. (Implemented)
9. Implement Firebase Authentication (login and signup screens, go_router configuration, and authentication logic). (Implemented)
10. Address errors in main.dart. (Addressed)
11. Integrate Firebase Firestore (data models, saving items from AddItemScreen, fetching and displaying items in LostItemsScreen and FoundItemsScreen). (Integrated)
12. Implement Cloudinary image upload (dependencies, image picking and upload in AddItemScreen, displaying images in LostItemsScreen and FoundItemsScreen). The implementation in AddItemScreen was updated to use unsigned uploads with `Cloudinary.unsignedConfig` to fix an error. Remember to replace the placeholder upload preset name and be cautious about using unsigned uploads in production. (Implemented)
13. Implement Cloudinary image upload: Corrected implementation in AddItemScreen to use the default `Cloudinary()` constructor and set properties for unsigned uploads, fixing the previous error.
14. Implement Item Detail Screen (route, navigation from list screens, data fetching and display). (Implemented)