
# Project's Tech-Stack
- **Backend**: Python 3.11 with UV package manager 0.8.11, Django 5.2
- **Database**: SQL (PostgreSQL)
- **Frontend**: Flutter 3.8.1 with Google Maps Flutter Plugin
- **Cloud Service**: Supabase (Free Cloud Database for PostgreSQL), Render (Backend Host)
- **External APIs**: OpenWeatherApi One Call API 2.5, OpenRouteService, Google Places API
- **Version Control**: Git, GitHub, GitHub Desktop (For those unfamiliar with Git Commands)
- **IDE**: Visual Studio Code

# Installation and Initial Set-Up
## 1. Install Python and UV package Manager
- Follow [this](https://www.youtube.com/watch?v=D2cwvpJSBX4) to install [Python 3.11](https://www.python.org/downloads/) for Visual Studio Code
- Follow [this](https://www.youtube.com/watch?v=6pttmsBSi8M&t=796s) to install UV manager 0.8.11

## 2. Install Flutter
- Follow [this](https://docs.flutter.dev/install/with-vs-code) to install Flutter SDK for VSCode

## Optional: Other Installations 
- [Github Desktop](https://desktop.github.com/download/): [Installation Tutorial](https://www.youtube.com/watch?v=_GETheHTQto)
- [Postman](https://www.postman.com/downloads/): [Installation Tutorial](https://www.youtube.com/watch?v=q8fHowK_qHQ)

## 3. Clone the Project
- Copy the GitHub repository URL:
```
    https://github.com/basistanevoel-png/Flood-Management-App
```
***Method 1**: Using Git*:
- Open **Git**, **Bash**, **PowerShell**, or any other terminal where Git is installed
- Navigate to the directory where you want to store the project using the terminal command:
```
cd path/to/your/projects
```
- Clone the repository using:
```
git clone https://github.com/basistanevoel-png/Flood-Management-App.git
```
- Navigate into the newly cloned repository:
```
cd Flood-Management-App
```
- Check if the repository was cloned successfully:
```
git status
```
***Method 2**: Using GitHub Desktop*:
- Open the Desktop App and press the "**Current Repository**" dropdown in the top-left corner of the workspace
- Within that dropdown, press "**Add**" and select "**Clone Repository...**"
- A pop-up window will show, go to the "**URL**" tab and paste the URL in the text field labelled "**URL or username/repository**"
- Choose a proper directory to clone the repository to your device locally thru the "**Choose...**" button beside the Local Path text field
- Press "**Clone**" and check the repository folder in File Explorer

## 4. Sync the Project Folders

***For the Backend Server***:
- Open File Explorer and go to this specific folder in the repository:
```
C:<Repo's Root Folder>\Flood-Management-App\Django\FloodMonitoring
```
- Open the folder in VSCode by typing in the repository:
```
code .
```
- After Opening the folder, open a terminal inside VSCode, and create an environment by typing and entering in the terminal:

```
uv venv
```
- After the virtual environment for python has been generated, sync the dependencies inside the project's .toml file using the command:
```
uv sync
```
***For the Frontend Server***:
- Open File Explorer and go to this specific folder in the repository:
```
C:<Repo's Root Folder>\Flood-Management-App\Flutter\FloodMonitoring
```
- Open the folder in VSCode by typing in the repository:
```
code .
```
- After Opening the folder, open a terminal inside VSCode, and sync the project's dependencies using:

```
flutter pub get
```
# Running the Projects
***Running the Django server***:
- Open the Django terminal listed earlier in VSCode
- Open a terminal and run either of the two commands
- *in debug or development mode*:
```
uv run manage.py runserver
```
- *in deployment mode (Using Gunicorn + Uvicorn + ASGI)*:
```
uv run uvicorn fdw_backend.asgi:application --host 0.0.0.0 --port 8000 (or any port available)
```
***Running the Flutter App***:
- **Prerequisite**: It is much more efficient to use an actual phone device to run the App instead of relying on browsers or an emulator. Make sure that your phone is in "**Development Mode**", has "**USB Debugging**" enabled, and is connected to your PC via a USB cord. ([Tutorial](https://www.youtube.com/watch?v=yxif9Tj8fDE))
- Open the Django terminal listed earlier in VSCode
- Open a terminal and run:
```
flutter run
```
- Go to your physical device and allow the installation to happen (If the device does not have a copy of the app installed prior)
***Creating a Release APK installer***:
- Open the Django terminal listed earlier in VSCode
- Open a terminal and run:
```
flutter build apk --release
```

# Environment Variables (In Django)
These are the list of environment vartiables in our Django folder. If in the future, you are to handle confidential information (service keys, emails/passwords linked to services, etc.), always put them in the .env file in the Django folder and integrate the service in such a way that the backend server only has access to the environment variables. Some variables are not used anymore, however, NEVER remove them, add "null" if value cannot be provided to these obsolete variables.

|Variable|Description|
|--------|-----------|
|IS_MOCK_STREAM|Boolean value; Obsolete(kinda); Decide if you want to use mock stream or listen to actual stream|
|SUPABASE_URL|string value; the supabase project url for the HTTP-based queries|
|SUPABASE_KEY|string value; the generated secret key for the project|
|OPENWEATHER_KEY|string value; the Openweather API Key for authorizing API calls|
|BROKER_URL|string value; Obsolete(kinda); the project's mqtt broker url|
|BROKER_PORT|string value; Obsolete(kinda); the port of the broker server|
|BROKER_USERNAME|string value; Obsolete(kinda); the username registered to the broker serve account|
|BROKER_PASSWORD|string value; Obsolete(kinda); the password registered to the broker serve account|
|TOPIC|string value; Obsolete(kinda); the topic of your broker; API endpoint where your backend will listen|
|NOMINATIM_EMAIL|string value; Obsolete(kinda); email to be used for the nominatim api call header|
|ORS_API_KEY|string value; the ORS key for route requests|
|GOOGLEMAPS_API_KEY|string value; the API key for using Places API services|
|SECRET_TOKEN_FOR_LISTENER|string value; The secret token that will be used to authenticate a call to the internal data collection API endpoint|

# Links to Services and Deployments
This is where we have currently deployed our system's database and backend server.
- [Render Cloud Server](https://dashboard.render.com/project/prj-d86uah6gvqtc73e3lrtg): **Note!** Render deploys the current version of the django folder in the 'main' branch so make sure that you merge your changes to the branch and manually redeploy it on Render
- [Supabase Cloud Database](https://supabase.com/dashboard/org/jsxtkithwbzoiyhxfobo?sort=created_desc)

# Resources and Documentation
It's best to use our project as a reference when reading through the materials linked below to better familiarize yourselves with how each component (Flutter App, Backend Django Server, etc.) are structured, and the purpose of each file/folder inside them.

### 1. Backend Stack
- [**Django** Documentation](https://docs.djangoproject.com/en/5.2/) (**Mandatory**)
- [**Supabase** Documentation](https://supabase.com/docs) (**Mandatory**)
- [Introduction to **RESTful APIs**](https://www.geeksforgeeks.org/node-js/rest-api-introduction/) (**Mandatory**)
- [**PostgreSQL** Documentation](https://www.postgresql.org/docs/) (*Optional*)

### 2. Frontend Stack
- [**Flutter** Documentation](https://docs.flutter.dev/ui) (**Mandatory**)
- [**Google Maps Flutter** Plugin Documentation](https://pub.dev/packages/google_maps_flutter) (**Mandatory**)

### 3. External API
*Not Strictly Mandatory, just be familiar with the return objects.*
- [OpenWeatherAPI One Call API v2.5](https://openweathermap.org/api/one-call-api)
- [OpenRouteService APIs Playground](https://openrouteservice.org/dev/#/api-docs/introduction)
- [Google's Places API Documentation](https://developers.google.com/maps/documentation/places/web-service)

### 4. AI/ML Tools
*Not Strictly Mandatory if you are not making changes to the model, otherwise READ THESE.*
- [**Scikit-Learn** Documentation](https://scikit-learn.org/0.21/documentation.html)
- [**Pandas** Documentation](https://pandas.pydata.org/docs/)
- [**Optuna** Documentation](https://optuna.readthedocs.io/en/stable/)
- [**XGBoost** Documentation](https://xgboost.readthedocs.io/en/stable/)
- [**Pickle Library** Documentation](https://xgboost.readthedocs.io/en/stable/)

# For Concerns...
For concerns, such as asking for the .env file and requesting admin access in Supabase and Render, Contact me thru:
- GMail: danedatuin.professional@gmail.com
- Facebook Messenger: https://www.facebook.com/dane.datuin354
