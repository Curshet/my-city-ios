# ![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Formatting/FormattingIcon.png?ref_type=heads) style guide

**Примечание:** данный документ подлежит периодическим обновлениям (при необходимости), неуказанные случаи требуют предварительного согласования с командой и последующего процесса внесения изменений. 


## ![](https://git.sevstar.net/ssdev/cabinet-new/-/raw/dev/mobile/ios/Release/Documentation.docc/Resources/Beginning/Xcode.png?ref_type=heads) iOS

Именование конструкций происходит с использованием стиля **"camelCase"** без числовых/символьных значений. При этом именование типов, файлов, директорий проекта начинается **с заглавной буквы**.


## Константы и переменные

<details>
  <summary> Attributed </summary>

    @objc let value
    
    @Published let value

</details>

<details>
  <summary> Bool </summary>

  Именование желательно начинать с префикса "is".

    let isTrue

    let isFalse

</details>

<details>
  <summary> Collections </summary>

    let emptyArray = [Type]()

    let array = [1, 2, 3]

    let emptySet = Set<Hashable>()

    let set: Set<Type> = [1, 2, 3]

    let emptyDictionary = [Hashable : Type]()

    let dictionary = ["One" : 1, "Two" : 2, "Three" : 3]

</details>

<details>
  <summary> Computed </summary>

    var value: Type {
        "Value"
    }
  ____________________________________

    var value: Type {
        let valueOne = TypeOne()
        let valueTwo = TypeTwo()
        let valueThree = valueOne + valueTwo
        return valueThree
    }
  ____________________________________
  
    var value: Type {
        get {
            "Value"
        }
    
        set {
            newValue
        }
    }

  ____________________________________

    var value: Type {
        willSet {
            newValue
        }
    
        didSet {
            oldValue
        }
    }

</details>


## Функции

Желательно **избегать** в теле исполняемой функции **объявление вложенных**, существенно усложняющих чтение инструкций (допускается использование **не более 2-х замыкающих функций**, не предусматривающих использование дополнительных уровней вложенности).

<details>
  <summary> Attributed </summary>

    @objc func action()
    
    @MainActor func action()

</details>

<details>
  <summary> Bool </summary>

  Именование желательно начинать с префикса "is".

    func isTrue() -> Bool

    func isFalse() -> Bool

</details>

<details>
  <summary> 1 аргумент </summary>

    func action(_ argument: Type)

</details>

<details>
  <summary> 6 (и более) аргументов </summary>

  Необходимо использовать отдельную **структуру данных** в качестве главного аргумента (предпочтительно) либо **typealias** (исключение, практикующееся крайне редко).

    struct Type {
        let name: String
        let age: Int
        let profession: String
        let status: String
        let isActive: Bool
        let isOnline: Bool
    }

    func action(_ argument: Type)

</details>

<details>
  <summary> Возвращаемое значение </summary>

    func action() -> Type {
        Type()
    }

  ____________________________________

    func action() -> Type {
        let oneValue = TypeOne()
        let twoValue = TypeTwo()
        let threeValue = oneValue + twoValue
        return threeValue
    }

</details>


## Замыкания

Желательно **избегать** использование **вложенных друг в друга** замыкающих функций, существенно усложняющих чтение инструкций (допускается **не более 2-х уровней** вложенности).

Неуказанные случаи идентичны правилам **функций**.

<details>
  <summary> Attributed </summary>

    @objc var action: () -> Void
    
    @MainActor var action: () -> Void 

</details>

<details>
  <summary> Bool </summary>

  Именование желательно начинать с префикса "is".

    var isTrue: () -> Bool

</details>

<details>
  <summary> Trailing syntax </summary>

  Желательно указывать замыкание как **Optional Type** (в качестве аргумента/переменной) без использования атрибута **@escaping** (при наличии возможности и условия, когда не происходит ухудшения понимания общего лог. смысла выполняемой инструкции).
    
    func action(_ argument: Type, _ completion: (() -> Void)?)

    action(argument) {
        print("Message")
    }

  ____________________________________

    func action(_ argument: Type, action: (() -> Void)?, completion: (() -> Void)?)

    func action(argument) {
        print("Start")
    } completion: {
        print("End")
    }

</details>

<details>
  <summary> Без аргументов </summary>

    var closure: () -> Void = {
        print("Message")
    }

</details>

<details>
  <summary> 1 аргумент </summary>

    var closure: (Int) -> Void = {
        print("Message: \($0)")
    }

</details>

<details>
  <summary> от 2 до 5 аргументов </summary>

    var closure: (String, Int) -> Void = { (name, age) in
        print("Name: \(name), age: \(age)"))
    }

</details>


## Функции высшего порядка

**1.** Желательно писать логику обработки в теле замыкания одной строкой. В противном случае - использовать отдельный метод обработки данных.

<details>
  <summary> Пример </summary>

    let array = [1, 2, 3]
    let result = array.map { someAction($0) }

</details>

**2.** При использовании комбинации функций высшего порядка, желательно, результат каждой из них помещать в отдельную константу/переменную (допускается использование **не более 2-х функций** подряд).

<details>
  <summary> Пример </summary>

    let array = [1, 2, 3]
    let map = array.map { String($0) }
    let filter = map.filter { !$0.isEmpty }
    let reduce = filter.reduce("", +)

</details>


## Инициализаторы

При создании инициализитора желательно делать **видимым** имя каждого его аргумента. Неуказанные случаи идентичны правилам **функций и использованию в классах**. 

<details>
  <summary> Пример </summary>

    init(netwotkManager: NetwotkManagerProtocol, connectionManager: ConnectionManagerProtocol, storage: StorageProtocol, dataSource: DataSourceProtocol, dataCache: DataCacheProtocol)

</details>


## Операторы

<details>
  <summary> Мат. операции </summary>

    let plus = 55 + 33
    let minus = 55 - 33
    let division = 55 / 33
    let remainder = 55 % 2
    let multiplication = 55 * 33

</details>

<details>
  <summary> Сравнение </summary>

    let isEqual = plus == minus
    let isTrue = plus != minus
    let isLess = minus <= plus
    let isBigger = plus >= minus

</details>

<details>
  <summary> Range </summary>

    let range = 0..<777
    let range = 0...777

</details>

<details>
  <summary> Bool </summary>

    let isTrue = true || false
    let isTrue = true && false

</details>


## Операторы условий

Желательно **избегать** использование **вложенных друг в друга** операторов условий, существенно усложняющих чтение инструкций.

В большинстве случаев  вместо конструкции **if -> else** рекомендуется использовать: **guard**, **switch**, **тернарный оператор**.

<details>
  <summary> if </summary>

    if isTrue {
        print("True")
    }

  ____________________________________

    if let one, let two, let three, let four {
        print("True")
        return
    }

</details>

<details>
  <summary> guard </summary>

    guard isTrue else { return value }

  ____________________________________

    guard let one, let two, let three, let four else { return }

  ____________________________________

    guard isTrue else {
        print("False")
        return
    }

</details>

<details>
  <summary> switch </summary>

    switch 4 {
        case 1:
            print("One")
    
        case 2:
            return

        case 3:
            fallthrough
    
        case 4:
            break
    }
    
</details>

<details>
  <summary> Ternary </summary>

  Не рекомендуется использовать оператор в операциях, связанных с изменениями (мутациями) данных.

    let isTernary = isTrue ? "True" : "False"

</details>


## Числа

<details>
  <summary> Нулевые значения </summary>

    let integer: Int
    let float: Float
    let double: Double

    integer = .zero
    float = .zero
    double = .zero

  ____________________________________

    let integer = 0
    let float = 0.0
    let double = 0.0

</details>

<details>
  <summary> Ненулевые значения </summary>

    let integer: Int
    let float: Float
    let double: Double

    integer = 50
    float = 50.0
    double = 50.0

  ____________________________________

    let integer = 50
    let float = Float(50)
    let double = Double(50)

</details>


## Extension

Неуказанные случаи идентичны правилам **классов**.

<details>
  <summary> Пример </summary>

    extension Type {

      func action() {
          print("Message")
      }

    }

</details>


## Protocol

В проекте не практикуется/не рекомендуется использование **typealias**, однако допускается, что некоторые случаи могут быть исключением из рекомендации. 

Неуказанные случаи идентичны правилам **классов** за исключением наличия пробелов между фигурными скобками при объявлении типа.

<details>
  <summary> Пример </summary>

    protocol SomePrоtocol: AnyObject, Protocol {
      associatedtype TypeOne
      associatedtype TypeTwo
    
      var variableOne: TypeOne { get }
      var variableTwo: TypeTwo { get set }
    
      func actionOne()
      func actionTwo()
    }

</details>


## Enumeration

Неуказанные случаи идентичны правилам **классов** за исключением наличия пробелов между фигурными скобками при объявлении типа.

<details>
  <summary> Пример </summary>

Допускается использование не более 3-х аргументов в качестве **associated values**. В противном случае необходимо использовать отдельную **структуру данных** в качестве главного аргумента (предпочтительно) либо **typealias** (исключение, практикующееся крайне редко).

    enum SomeEnum {
      case one
      case two(Int)
      case three(name: String, age: Int)

      indirect case five(SomeEnum)
      indirect case six(target: SomeEnum, pieces: Int) 
      indirect case seven(with: SomeEnum, number: Int, items: Int)
    }

</details>


## Structure

Неуказанные случаи идентичны правилам **классов** за исключением наличия пробелов между фигурными скобками при объявлении типа.

<details>
  <summary> Пример </summary>

    struct SomeStruct {
      let one: Type
      let two: Type
      let three: Type 
    }

</details>


## Class

В проекте не практикуется/не рекомендуется использование **вложенных типов**, однако допускается, что некоторые случаи могут быть исключением из рекомендации. 

<details>
  <summary> Static variables </summary>

    class SomeClass {
      static let one = "One"
      static let two = "Two"
      static let three = "Three"
    }

</details>

<details>
  <summary> Attributed </summary>

    @objc class SomeClass

    @MainActor class SomeClass

</details>

<details>
  <summary> Singleton </summary>

    final class SomeClass: Protocol {

      static let entry = SomeClass()

      private init() {}

    }

</details>

Переменные, функции в теле класса (актуально для всех типов) и его расширениях, использующие **одинаковые атрибуты, область видимости и иные общие признаки**, подлежат визуальной **группировке**.

<details>
  <summary> Пример </summary>

    class SomeClass: Parent, Prоtocol {

      static let value = "Value"
      static var value = "Value"

      static private let value = "Value"
      static private var value = "Value"

      static var value: String {
          "Value"
      }

      class var value: String {
          "Value"
      }

      static private var value: String {
          "Value"
      }

      class private var value: String {
          "Value"
      }

      static func action() {
          print("Message")
      }

      class func action() {
          print("Message")
      }

      static private func action() {
          print("Message")
      }

      class private func action() {
          print("Message")
      }

      weak var value: Type?
      let value: Type
      @objc let value: Type
      var value: Type
      @Published var value: Type
      private(set) var value: Type
      @Published private(set) var value: Type
      fileprivate(set) var value: Type
      @Published fileprivate(set) var value: Type

      fileprivate let value: Type
      @objc fileprivate let value: Type
      fileprivate var value: Type
      @Published fileprivate var value: Type

      var value: String {
          "Value"
      }

      override class var value: String {
          "Value"
      }

      override var value: String {
          "Value"
      }

      private weak var value: Type?
      private let value: Type
      @objc private let value: Type 
      private var value: Type
      @Published private var value: Type

      private var value: String {
          "Value"
      }

      init(service: Type, storage: Type, manager: Type, cache: Type, encoder: Type) {
        self.service = service
        self.storage = storage
        self.manager = manager
        self.cache = cache
        self.encoder = encoder
        super.init()
      }
    
      init?() {
        initializating()
      }
    
      convenience init() {
        initializating()
      }

      required init() {
        initializating()
      }
    
      required init?() {
        initializating()
      }

      private func action() {
        print("Message")
      }

      fileprivate func action() {
        print("Message")
      }

      override class func action() {
        print("Message")
      }

      override func action() {
        super.action()
        print("Message")
      }

      func action() {
        print("Message")
      }

      @objc func action() {
        print("Message")
      }

      deinit {
        print("Message")
      }

    }

</details>

Как правило, тело класса (может быть актуально для всех типов) обладает наибольшим объёмом кодовой базы и зачастую нуждается в визуальной **сепарации** по логическим блокам **с помощью расширений**. В равной степени **сепарация** необходима **при объявлении дополнительных типов** в файлах проекта.

<details>
  <summary> Пример </summary>

    class SomeClass: Parent, Protocol {

      private let value: NewType

      init(value: NewType) {
        self.value = value
        super.init()
      }

      override func action() {
        super.action()
        print("Message")
      }

      deinit {
        print("Message")
      }

    }

    // MARK: Private
    private extension SomeClass {

      func continue() {
        print("Message")
      }

      func restart() {
        print("Message")
      }

    }

    // MARK: Public
    extension SomeClass {

      func stop() {
        print("Message")
      }

    }

    // MARK: Protocol
    extension SomeClass {

      func start() {
        print("Message")
      }

    }

    // MARK: - NewType
    struct NewType {
      let value: Int
      let identifier: String
    }

</details>

