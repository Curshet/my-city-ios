# ![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Pipeline/PipelineIcon.png?ref_type=heads) Pipeline

**Примечание:** данный документ является продолжением гайда "Начало работы", подлежит регулярным обновлениям (при необходимости), может содержать ряд неточностей и/или неактуальную информацию.

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Pipeline/Pipeline.svg?ref_type=heads)


## 1. Формирование задачи.

**1.1.** В первую очередь задачу (в том числе как идею) на начальном этапе необходимо оценить по вероятным временным затратам и тех. возможности реализации.

**1.2.** После удовлетворительного прохождения этапа первичной оценки задачи ответственным лицом (при необходимости) выполняется её декомпозиция.

**1.3.** ERP.

Как правило, задача (с номером, описанием и/или комментарием) создаётся ответственным лицом в ERP. В качестве исключения, потенциальный исполнитель может создать задачу самостоятельно. На созданную задачу подписываются необходимые участники, которые получают уведомление о подписке в боте "Telegram". С этого момента задача считается закрепленной за указанными участниками.

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Pipeline/TaskTelegram.png?ref_type=heads)

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Pipeline/TaskDescription.png?ref_type=heads)

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Pipeline/TaskSubscribers.png?ref_type=heads)

Стоит учитывать, что уведомление бота "Telegram" может также поступить и в случае, связанном с общими новостями/задачами компании, что не всегда обязывает участников реагировать на данное уведомление.

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Pipeline/TelegramNotification.png?ref_type=heads)

**1.4.** Telegram.

После создания задачи в ERP ответственным лицом создаётся дполнительный чат "Telegram" в основной группе конкретной платформы с названием, содержащим номер задачи. В чате происходит (либо планируется) оценка, обсуждение деталей реализации, статус задачи и все сопутствующие вопросы. Каждый чат отдельной платформы может иметь свои особенности рабочего процесса. 

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Pipeline/TasksGroup.png?ref_type=heads)

**Примечание:** некоторых ситуациях, часть ответственных лиц может отсутствовать в чате "Telegram" и в таком случае уточняющие вопросы желательно обсуждать в ERP, обращаясь именно к этим лицам, если по каким-либо причинам нет возможности добавить их в текущий чат.

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Pipeline/TaskQuestion.png?ref_type=heads)


## 2. Реализация задачи.

**2.1.** Начало реализации.

**2.1.1.** В обязательном порядке перед началом работ участникам задачи необходимо дополнительно согласовать (и/или внести коррективы, предложения): макет дазайна User Interface **(актуально для мобильных платформ)**, условия задачи и ожидаемый результат, доп. детали (при наличии), вероятные сценарии, которые могут затруднять реализацию задачи.

**2.1.2.** При выполнении задачи создаётся ветка от основной ветки проекта под названием "dev" аналогично именованию Git Flow.

**2.1.3.** Именование веток производится следующим образом: 


    [ Git Flow ] / [ номер задачи ERP ] - [ платформа ] - [ название ветки/краткое описание задачи ]


![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Pipeline/GitBranch.png?ref_type=heads)

В случае, когда номер задачи отсутствует:

    [ Git Flow ] / [ платформа ] - [ название ветки/краткое описание задачи ]

* [Подробная инструкция](https://git.sevstar.net/ssdev/ci-snippets/-/wikis/git-rules) (раздел "Ветки")

**2.2.** Процесс реализации.

**2.2.1.** При написании кода (и реализации задачи в целом) необходимо придерживаться принятых в команде правил, касающихся архитектуры проекта, оформления коммитов, Code Style и общего Pipeiline.

**2.2.2.** Заголовок коммита начинается с тега (пункт 2.2.3). Коммит создаётся исключительно **на английском языке**, начиная с заглавной буквы без использования спец. символов (по возможности). Приветствуется создание коммитов с кратким описанием.

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Pipeline/GitCommit.png?ref_type=heads)

**2.2.3.** Теги (префиксы) коммитов.

<details>
  <summary> Теги, связанные с изменениями в коде </summary>

  * **Add:** Добавление нового кода и файлов.
  * **Fix:** Исправление ошибок.
  * **Feature:** Добавление функциональности в существующий код.
  * **Refactoring:** Улучшение структуры и читаемости существующего кода, не изменяя его функциональность.
  * **Optimize:** Улучшение производительности кода.

</details>

<details>
  <summary> Теги, связанные с изменениями в проекте и его организации </summary>

  * **Add:** Добавление файлов.
  * **Replace:** Перемещение файлов.
  * **Remove:** Удаление файлов.
  * **Update:** Обновление сторонних библиотек, инфраструктуры проекта.
  * **Style:** Изменения, связанные со стилем кода, не влияющие на его функциональность.
  * **Merge:** Добавлений изменений с других веток, решение Merge-конфликтов. 

</details>

<details>
  <summary> Теги, связанные с тестированием, документацией, локализацией </summary>

  * **Test:** Добавление или изменение тестов.
  * **Docs:** Обновление или добавление документации и комментариев.
  * **Localization:** Добавление или обновление переводов и локализаций.

</details>

**2.3.** Завершение реализации.

**2.3.1.** При завершении реализации нового функционала либо исправлении критичных багов **(актуально для мобильных платформ)**, связанных исключительно/в том числе с User Interface, необходимо в обязательном порядке отправлять скриншоты реализованного User Interface в канал "Telegram" под названием **"Тестирование интерфейсов"**. Скриншоты отправляются с согласованного (командой) списка устройств/симуляторов в светлом/тёмном оформлении (при необходимости) с указанием номера задачи и кратким описанием изменений. Далее следует ожидать конечного согласования полученного результата с дизайнером/ответственными лицами.

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Pipeline/InterfaceTestingChannel.png?ref_type=heads)

**2.3.2.** При успешном прохождении пункта 2.3.1 создаётся Merge Request в основную ветку проекта "dev", а также выполняется сборка приложения с текущей ветки задачи для последующей передачи приложения в команду тестирования ПО.

**2.3.3.** После создания и загрузки сборки приложения (версию которой необходимо уточнять у ответственного лица), необходимо оповестить команду тестирования ПО (в чат "Telegram") о начале тестирования сборки с указанием номера сборки и внесённых изменений.

**2.3.4.** Merge Request.

При создании Merge Request необходимо придерживаться следующего именования:


    [ ERP-номер задачи ] - [ платформа ] - [ описание задачи ]


![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Pipeline/MergeRequestNameOne.png?ref_type=heads)

В случае, когда номер задачи отсутствует:


    [ Git Flow ] - [ платформа ] - [ описание задачи ]


![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Pipeline/MergeRequestNameTwo.png?ref_type=heads)

* [Подробная инструкция](https://git.sevstar.net/ssdev/ci-snippets/-/wikis/git-rules) (раздел "Запросы на слияние")

**2.3.5.** Приветствуется краткое описание Merge Request на русском языке с целью ускорения/облегчения последующего процесса Code Review.

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Pipeline/MergeRequestDescription.png?ref_type=heads)

**2.3.6.** Установка лейблов c указанием актуального статуса Merge Request.

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Pipeline/GitLabels.png?ref_type=heads)

<details>
  <summary> Needs a code review </summary>

    Статус устанавливает автор Merge Request.

 **Назначение:** необходимо проведение Code Review.

 **Сценарий:** Merge Request полностью готов/оформлен.

</details>

<details>
 <summary> Code review process </summary>

    Статус устанавливает Reviewer.

 **Назначение:** необходимо проведение Code Review.

 **Сценарий:** проводится процесс Code Review, а также обсуждаются решения и исправляются замечания (при их наличии). Этот статус Merge Request не меняется до тех пор, пока не будет получен "Approve" от всех установленных участников процесса Code Review.
Исправление замечаний, полученных от команды тестирования ПО, запускает цикл заново с необходимости проведения Code Review . В таком случае желательно указать участникам Code Review любым доступным способом какую именно часть кодовой базы необходимо пересмотреть, если основной этап Code Review ранее уже был пройден.

</details>

<details>
  <summary> Testing </summary>

    Статус устанавливает автор Merge Request.

 **Назначение:** процесс тестирования.

 **Сценарий:** указывается необходимость либо фактическое проведение тестирования. Данный статус Merge Request может одновременно находиться в комбинации с другими статусами.

</details>

<details>
  <summary> Ready to merge </summary>

    Статус устанавливает автор Merge Request (в некоторых/редких случаях иное ответственное лицо).

 **Назначение:** готово к выполнению Merge.

 **Сценарий:** при успешном прохождении вышеперечисленных этапов Merge Request, но при наличии причин, не связанных с реализацией задачи в рамках конкретной платформы, устанавливается данный статус, говорящий о том, что всё готово к выполнению Merge, но по каким-то причинам (которые известны автору или иному ответственному лицу) для данного Merge Request временно не будет выполнен Merge.

</details>

**2.3.7.** В случае, когда автором был создан Merge Request, но по каким-либо причинам не готов/должным образом не оформлен, то в таком случае Reviewer и лейбл статуса Merge Request не устанавливаются, но при этом добавляется префикс **"Draft:"** в название Merge Request.

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Pipeline/MergeRequestDraft.png?ref_type=heads)

**2.3.8.** В обязательном порядке необходимо устанавливать следующие настройки Merge Request:

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Pipeline/MergeRequestSettings.png?ref_type=heads)

## 3. Завершение задачи.

**3.1.** После успешного прохождения этапов _согласования User Interface **(актуально для мобильных платформ)**, тестирования и Code Review_, ответственным за задачу разработчиком выполняется слияние текущей ветки задачи с веткой разработки проекта "dev". 

**3.2.** Необходимо убедиться, что влитая ветка задачи была успешно удалена из репозитория проекта и, при необходимости, удалить её вручную, также как и все имеющиеся лейблы статуса Merge Request.


## 4. Time tracking.

Ежедневно исполнителю в соответствующих полях ERP необходимо указывать количество часов, затраченных на выполнение задач, за которыми он закреплён.

* [Подробная инструкция](https://git.sevstar.net/ssdev/ci-snippets/-/wikis/time-tracking)

![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Pipeline/TimeTracking.png?ref_type=heads)

