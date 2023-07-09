# vdirsyncer

### Sync Remote

1. Install synchronize with Remote/Cloud calendar

    ```bash
    pip3 install --upgrade-strategy eager vdirsyncer
    ```

#### Google Calendar

##### Google API Manger

1. Create new project in Google API Manager

    1. [Google Api Manager](https://console.developers.google.com/)
        * Project Name: {NAME}-{NUMBER}
        * Location: _Optional_
        * Click <kbd> Create </kbd>

            ![new project in google api manager](./img/google_api_manager_new_project.jpg)

    2. API and Service Home Page

        ![api and service homepage](./img/google_api_manager_home_page.jpg)

    3. Click <kbd> + ENABLE APIS AND SERVICE </kbd>

        ![enable apis and service](./img/google_api_manager_enable_service.jpg)

2. Enable **CalDav API** for google calendar API access

    1. API Library homepage

        ![API library homepage](./img/google_api_manager_api_library.jpg)

    2. Search **CalDav API**

        ![search caldav api](./img/api_libray_search_caldav_api.jpg)

    3. Click to enable **CalDav API**

        ![click to enable](./img/api_library_caldav_api_click_enable.jpg)

    4. Success enable **CalDav API**

        ![enabled CalDav API](./img/caldav_api_success_enabled.jpg)

3. Enable Authorize Credentials

    1. Click left side-bar **Credentials**

        ![click credentials](./img/click_credentials.jpg)

    2. Click <kbd> + CREATE CREDENTIALS </kbd> and <kbd> + OAuth client ID </kbd>

        ![create oauth client id](./img/create_credentials.jpg)

    3. Click <kbd> CONFIGURE CONSENT SCREEN </kbd>

        ![configure consent screen](./img/oauth_client_conf_consent_screen.jpg)

    4. Create OAuth consent screen with **External** and click <kbd> CREATE </kbd>

        ![create oauth consent screen](./img/oauth_consent_screen_create.jpg)

        1. Edit app registration
            * App Name: _required_
            * User Email: _required_
            * Develops Email: _required_

            ![edit app registration](./img/oauth_consent_screen_edit_app_registration.jpg)

        2. Scopes
            * click <kbd> Save and Confirm </kbd>

            ![edit app scopes](./img/edit_app_reg_scopes.jpg)

        3. Test Users

            * click <kbd> Save and Confirm </kbd>

            ![edit app testusers](./img/edit_app_reg_test_user.jpg)

        4. Summary

            ![edit app summary](./img/edit_app_reg_summary.jpg)

4. Enable Web Application

    1. Click left side-bar **Credentials**

        ![click credentials](./img/click_credentials.jpg)

    2. Click <kbd> + CREATE CREDENTIALS </kbd> and <kbd> + OAuth client ID </kbd> then select **Web Application**

        ![select oauth client id web application](./img/oauth_client_id_app_type_web_app.jpg)

    3. Create **Web Application**

        * **redirect URLs**: `http://127.0.0.1` [^u1]

        ![create web application](./img/oauth_client_id_app_type_web_app_create.jpg)

    4. Created OAuth Client for **Web application**

        * `Client ID` + `Client secret`

        ![created oauth client for web application](./img/oauth_client_created.jpg)

##### Unix-Like System

1. Create vdirsyncer configuration file

    ```bash
    mkdir -p ~/.config/vdirsyncer
    touch ~/.config/vdirsyncer/config
    ```
2. Copy the contents below into configuration file

    * `client_id` and `client_secret` is created from _OAuth Client for Web Application_

        ![created oauth client for web application](./img/oauth_client_created.jpg)

    ```bash
    cat <<-EOF > ~/.config/vdirsyncer/config
    [general]
    status_path = "~/.calendars/status"

    [pair personal_sync]
    a = "personal"
    b = "personallocal"
    collections = ["from a", "from b"]
    metadata = ["color"]

    [storage personal]
    type = "google_calendar"
    token_file = "~/.vdirsyncer/google_calendar_token"
    client_id = "241086233307-rdb38l3lfa7bjlfetgsg0lg2bp47hgmc.apps.googleusercontent.com"
    client_secret = "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"

    [storage personallocal]
    type = "filesystem"
    path = "~/.calendars/"
    fileext = ".ics"
    EOF
    ```

3. Discover google calendar via CalDav APIs

    * `personal_sync` is discover pair, please refer in configuration file above.

    ```bash
    vdirsyncer discover personal_sync
    ```

4. Select google account

    ![select google account](./img/discover_account.jpg)

    * click _Advanced_ and click <kbd> Go to \<api name\> (unsafe) </kbd>

        ![continue with unsafe](./img/google_hasnt_verified_this_app.jpg)

    * Continue access calendar with APIs

        ![continue access with api](./img/api_access.jpg)

    * Success obtained token

        ![success obtained token](./img/success_obtain_token.jpg)

5. Sync Google Calendar

    ```bash
    vdirsyncer sync
    ```

6. add category for each imported contents

    * append into `~/.config/khal/config` depending on contents of `~/.calendars/`

        ```bash
        [[ ${NAME} ]]
        path = "~/.calendars/${content_file}"
        color = blue
        ```

[^u1]: http://127.0.0.1: redirect url will discover by **vdirsyncer** with random port number
