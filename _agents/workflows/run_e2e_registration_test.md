---
description: Run the E2E Registration & Add Kid Workflow Test
---
# E2E Registration Workflow

 Whenever making major structural, layout, or backend changes to the authentication or dashboard flows, you must run the complete end-to-end registration test to confirm no regression has occurred. 

 This test performs a clean signup with a unique parent email, navigates to the admin dashboard, creates a new Kid account with a PIN, logs out, and then securely logs back in as that newly created Kid.

 ## How to Run

 Execute the following playwright script to automatically verify the end-to-end workflow:

 // turbo
 ```bash
 npm run test:e2e tests/registration_workflow.spec.ts
 ```

 Review the `test-results` folder if any failures or timeout errors occur during the process.
