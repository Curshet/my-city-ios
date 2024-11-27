# ![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Beginning/BeginningIcon.png?ref_type=heads) Начало работы

**Примечание:** данный документ является продолжением гайда "Onboarding", подлежит регулярным обновлениям (при необходимости), может содержать ряд неточностей и/или неактуальную информацию.


## ![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Beginning/Xcode.png?ref_type=heads) iOS

В обязательном порядке необходимо **выполнить клонирование** Git-репозитория проекта под названием "cabinet-new" и **переключиться на ветку "dev"** для возможности выполнения дальнейших действий по настройке/сборке проекта.


## 1. Локация iOS-версии приложения в репозитории проекта: cabinet-new/mobile/ios.

По умолчанию рекомендуется **использовать самую свежую (Release)** версию Xcode IDE.


## 2. Работа с проектом осуществляется через файл с расширением ".xcworkspace".

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Beginning/WorkSpaceFile.png?ref_type=heads)


## 3. В проекте используется Swift Package Manager, что предполагает некоторое ожидание (перед первым запуском сборки проекта) в течение автоматической загрузки требуемых зависимостей.

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Beginning/PackagesPreparing.png?ref_type=heads)


## 4. Подключение/настройка возможности сборки проекта на устройстве.

**4.1.** Зарегистрировать (в случае отсутствия) собственный профиль Apple ID на сайте компании Apple.

**4.2.** Получить UDID требуемого для подключения устройства, используя любой сторонний сервис.

**4.3.** Создать файл запроса подписи сертификата (CSR) –> см. пункты далее.

**4.3.1.** Запустить системное приложение (macOS) "Связка ключей" -> "Ассистент сертификации" -> "Запросить сертификат у бюро сертификации".

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Beginning/CertificateRequestOne.png?ref_type=heads)

**4.3.2.** В появившемся разделе указываем адрес эл. почты собственного профиля Apple ID, "Общее имя" (произвольный набор символов), "Адрес e-mail БС" (пустое значение), выбираем "Сохранен на диске" и сохраняем (локально) полученный файл.

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Beginning/CertificateRequestTwo.png?ref_type=heads)

**4.4.** Обратиться к ответственному лицу за получением файла сертификата и файла профиля разработчика, предоставив UDID устройства (пункт 4.2) и файл CSR (пункт 4.3).

**4.5.** Получив файл сертификата (с расширением ".cer") и файл профиля разработчика (с расширением ".mobileprovision") от ответственного лица, добавить полученный сертификат в системное приложение (macOS) "Связка ключей". При возможном запросе пароля в процессе добавления сертификата, требуется ввести пароль текущего пользователя операционной системы.

**4.6.** Подключить требуемое устройство к компьютеру с помощью провода. 

**4.7.** "Project" –> "Targets" –> "my isp" –> "Signing and Capabilities" –> "All", отключаем параметр "Automatically manage signing", импортируем полученный файл профиля разработчика (пункт 4.4).

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Beginning/DevProfileImporting.png?ref_type=heads)

**4.8.** Выбираем импортированный профиль разработчика в "Provisioning Profile".

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Beginning/DevProfileChoosing.png?ref_type=heads)

**4.9.** В списке доступных устройств выбираем необходимое и выполняем сборку проекта. В случае возникновения ошибок необходимо проверить (при необходимости повторить) проделанные шаги, начиная с пункта 4.3.

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Beginning/DeviceChoosing.png?ref_type=heads)


## 5. Подключение к программе тестирования (Test Flight).

**5.1.** Скачать и установить приложение "TestFlight" в App Store.

**5.2.** Выполнить вход в "TestFlight" с помощью собственного профиля Apple ID.

**5.3.** Обратиться к ответственному лицу для получения пригласительного кода на зарегистрированную эл. почту профиля Apple ID, с которого был выполнен вход в приложение "TestFlight".

**5.4.** Ввести пригласительный код в соответствующий раздел.

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Beginning/TestFlightInvite.png?ref_type=heads)

