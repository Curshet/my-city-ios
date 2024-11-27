# ![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Onboarding/OnboardingIcon.png?ref_type=heads) Onboarding

**Примечание:** данный документ подлежит регулярным обновлениям (при необходимости), а также может содержать ряд неточностей и/или неактуальную информацию.


## 1. Коммуникация в команде.

Осуществляется с помощью приложения "Telegram". 

Необходимо обратиться к **ответственному лицу (п.3)** и получить доступы ко всем корпоративным чатам компании, проекта и платформы, в которых находятся все необходимые участники рабочего процесса, так как именно в данных Telegram-чатах обозначаются актуальные события проекта на текущий момент времени.


## 2. Enterprise Resource Planning (ERP).

<details>
  <summary> Нажмите, чтобы показать ссылки </summary>

  * [ERP](https://erp.sevstar.net)
  * [Telegram-бот](https://t.me/sevstar_erp_bot)
  
</details>

Многофункциональная система ERP (см. скриншот) содержит в себе Task Manager, личную карточку сотрудника компании, зарплатные ведомости и ряд доп. документации компании.

Telegram-бот предназначен для оповещения в режиме реального времени о событиях ERP, на которые подписан сотрудник (задачи, уведомления компании). 

Подробную информацию необходимо уточнять у **ответственного лица (п.3)**.

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Onboarding/EnterpriseResourcesPlanning.png?ref_type=heads)


## 3. Получение доступа к ERP.

Необходимо обратиться к ответственному лицу для получения cоответствующего доступа, **предварительно выполнив пункт 3.1**.


**3.1.** Скачать и установить приложение "Google Authenticator" (либо аналогичное) в App Store либо Play Market. 

Вход в ERP компании возможен лишь при вводе временного сгенерированного приложением пароля (станет доступен после получения доступа к ERP).

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Onboarding/AuthenticatorOne.png?ref_type=heads)


## 4. Получение доступа к электронному документообороту (ЭДО).

Необходимо обратиться к ответственному лицу для получения cоответствующего доступа, **предварительно выполнив пункт 4.1**.

**4.1.** Скачать и установить приложение "Jump.Работа" в App Store либо Play Market.

Приложение позволяет формировать и отправлять все необходимые документы в соответствующие отделы компании в электронном виде. 

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Onboarding/JumpWork.png?ref_type=heads)


## 5. Ресурсы проекта.

<details>
  <summary> Нажмите, чтобы показать ссылки </summary>

  * [Репозиторий](https://git.sevstar.net/ssdev/cabinet-new)
  * [Документация (общая)](https://git.sevstar.net/ssdev/cabinet-new/-/wikis/home)
  * [Документация (iOS)](https://git.sevstar.net/ssdev/cabinet-new/-/tree/dev/mobile/ios/Release/Documentation.docc?ref_type=heads)
  * [Swagger](https://git.sevstar.net/ssdev/cabinet/-/blob/dev/swagger.json)
  * [Figma](https://www.figma.com/file/H9SqgcoQjEhPq9DPsnYvOw/%D0%9C%D0%BE%D0%B9-%D0%A1%D0%B5%D0%B2%D1%81%D1%82%D0%B0%D1%80)
  * [Сайт](https://sevstar.net/)
  
</details>


## 6. Система контроля версий (Git).

**6.1.** Обратиться к ответственному лицу, предварительно указав ему желаемое имя пользователя и адрес эл. почты для подключения доступа к репозиторию проекта.

**6.1.1.** Перейти на указанный адрес эл. почты и принять приглашение на получение доступа к репозиторию проекта.

**6.1.2.** Пройти шаги регистрации и в обязательном порядке включить двухфакторную аутентификацию при входе в систему, используя представленный QR-код (в разделе "Edit profile" -> "Account") для генерации приложением "Google Authenticator" (либо аналогичным) кода для последующих авторизаций.

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Onboarding/AuthenticatorTwo.png?ref_type=heads)

**6.1.3.** Сохранить Recovery Codes (представленные GitLab) после успешного проведения процедуры включения двухфакторной аутентификации.

**6.2.** В разделе сервиса GitLab ("Edit profile" -> "Access Tokens") необходимо создать Token (с произвольным именем), у которого будут назначены полные права и максимально возможное значение в графе "Expiration Date". 

**6.3.** После прохождения процесса создания Token, сохраняем/копируем его для дальнейшего использования.

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Onboarding/GitLabToken.png?ref_type=heads)


## 7. Настройка Git-клиента (на примере "GitKraken" с имеющейся коммерческой лицензией).

**7.1.** На главной странице "GitKraken" (раздел "GitKraken  Client") выбираем сервис GitLab.

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Onboarding/GitKrakenStart.png?ref_type=heads)

**7.2.** Выбираем "GitLab (Self-Managed)" и вставляем сохранённый Token (пункт 6.4) в соответствующий раздел Git-клиента.

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Onboarding/GitKrakenInit.png?ref_type=heads)
