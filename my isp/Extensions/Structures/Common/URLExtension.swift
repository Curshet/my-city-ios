import UIKit

extension URL {
    
    // MARK: - Server
    enum Server {
        static let testing = "https://billing-test.sevstar.net:39443/api/"
        static let production = "https://my.sevtech.org/api/"
        static let prefix = UIApplication.isDebug ? testing : production
        static let telegramAuthorization = prefix + "super_account/register_account/tg"
        static let firstAuthorization = prefix + "super_account/2step/first"
        static let phoneAuthorization = prefix + "super_account/2step/send_code"
        static let phoneCodeAuthorization = prefix + "super_account/register_account"
        static let pushTokenRegister = prefix + "push/register/v3"
        static let deviceInformation = prefix + "super_account/device_information"
        static let supportContacts = prefix + "super_account/contacts"
        static let openTheDoor = prefix + "intercom/sip/open"
        static let streamIntercom = prefix + "intercom/sip/stream"
    }
    
}

extension URL {
    
    // MARK: - Service
    enum Service {
        static let prefix = "https://"
        static let appStore = prefix + "www.apple.com/app-store"
        static let telegramBot = prefix + "t.me/sevtech_auth_bot?start=sevtech"
        static let telegramSupport = prefix + "t.me/SevStar_Bot"
        static let whatsAppSupport = prefix + "api.whatsapp.com/send/?phone=79788990000&text&app_absent=0"
        static let viberSupport = prefix + "sevstar.net/viber-chat"
    }
    
}

extension URL {
    
    // MARK: - Universal
    enum Universal {
        static let prefix = "https://sevtech.org/mobileLink/"
        static let telegramBot = "backToLogin?params="
        static let sbp = "sbp?link="
        static let paymentSuccess = "payment/success"
        static let paymentError = "payment/error"
        static let intercom = "intercom/"
    }
    
}

extension URL {
    
    // MARK: - System
    enum System {
        static let tel = "tel://"
        static let sms = "sms://"
        static let mail = "mailto:"
        static let music = "maps://"
        static let videos = "videos://"
        static let maps = "maps://"
        static let calendar = "calshow://"
        static let contacts = "contacts://"
        static let facetime = "facetime://"
        static let store = "itms-apps://"
    }
    
}

extension URL {
    
    // MARK: - Settings
    enum Settings {
        static let prefix = "App-prefs:"
        static let general = prefix + "General"
        static let keyboard = prefix + "General&path=Keyboard"
        static let date = prefix + "General&path=DATE_AND_TIME"
        static let autolock = prefix + "General&path=AUTOLOCK"
        static let language = prefix + "General&path=INTERNATIONAL"
        static let updating = prefix + "General&path=SOFTWARE_UPDATE_LINK"
        static let about = prefix + "General&path=About"
        static let reset = prefix + "General&path=Reset"
        static let airplaneMode = prefix + "AIRPLANE_MODE"
        static let bluetooth = prefix + "Bluetooth"
        static let wifi = prefix + "WIFI"
        static let facetime = prefix + "FACETIME"
        static let notes = prefix + "NOTES"
        static let notifications = prefix + "NOTIFICATIONS_ID"
        static let phone = prefix + "Phone"
        static let photos = prefix + "Photos"
        static let sounds = prefix + "Sounds"
        static let store = prefix + "STORE"
        static let wallpaper = prefix + "Wallpaper"
        static let storage = prefix + "CASTLE&path=STORAGE_AND_BACKUP"
    }
    
}
