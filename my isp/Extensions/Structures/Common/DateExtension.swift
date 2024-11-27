import Foundation

extension Date: LoggingProtocol {
    
    var since1970: Int {
        Int(self.timeIntervalSince1970)
    }
    
    var sinceNow: Int {
        Int(self.timeIntervalSinceNow)
    }
    
    func convert(to target: Calendar.Component, file: String = #file, line: Int = #line) -> Int? {
        let calendar = Calendar.current

        switch target {
            case .era:
                return calendar.dateComponents([.era], from: self, to: self).era
            
            case .year:
                return calendar.dateComponents([.year], from: self, to: self).year
            
            case .yearForWeekOfYear:
                return calendar.dateComponents([.yearForWeekOfYear], from: self, to: self).yearForWeekOfYear
            
            case .weekOfYear:
                return calendar.dateComponents([.weekOfYear], from: self, to: self).weekOfYear
            
            case .quarter:
                return calendar.dateComponents([.quarter], from: self, to: self).quarter
            
            case .month:
                return calendar.dateComponents([.month], from: self, to: self).month
            
            case .weekOfMonth:
                return calendar.dateComponents([.weekOfMonth], from: self, to: self).weekOfMonth
            
            case .weekday:
                return calendar.dateComponents([.weekday], from: self, to: self).weekday
            
            case .weekdayOrdinal:
                return calendar.dateComponents([.weekdayOrdinal], from: self, to: self).weekdayOrdinal
            
            case .day:
                return calendar.dateComponents([.day], from: self, to: self).day
            
            case .hour:
                return calendar.dateComponents([.hour], from: self, to: self).hour
            
            case .minute:
                return calendar.dateComponents([.minute], from: self, to: self).minute
            
            case .second:
                return calendar.dateComponents([.second], from: self, to: self).second
            
            case .nanosecond:
                return calendar.dateComponents([.nanosecond], from: self, to: self).nanosecond
            
            default:
                logger.console(event: .error(info: "Unknown case of date converting: \(target)"), file: file, line: line)
                return nil
        }
    }
    
    func convert(to choise: DateType) -> String {
        let dateFormatter = DateFormatter()
        
        switch choise {
            case .dayMonthYear(let isYearTwoSymbols):
                dateFormatter.dateFormat = isYearTwoSymbols ? "dd.MM.yy" : "dd.MM.yyyy"
            
            case .monthYear:
                dateFormatter.dateFormat = "MM/yy"
            
            case .time:
                dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
            
            case .utf:
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        }
    
        return dateFormatter.string(from: self)
    }
    
}

// MARK: - DateType
enum DateType {
    case dayMonthYear(_ isYearTwoSymbols: Bool = false)
    case monthYear
    case time
    case utf
}
