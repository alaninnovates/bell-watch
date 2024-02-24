import Foundation

extension Date {
  init(_ dateString: String) {
    let dateStringFormatter = DateFormatter()
    dateStringFormatter.dateFormat = "MM/dd/yyyy"
    dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
    let date = dateStringFormatter.date(from: dateString)!
    self.init(timeInterval: 0, since: date)
  }
  func dayOfWeek() -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    let longDate = dateFormatter.string(from: self)
    if longDate == "Sunday" {
      return "Sun"
    } else if longDate == "Monday" {
      return "Mon"
    } else if longDate == "Tuesday" {
      return "Tue"
    } else if longDate == "Wednesday" {
      return "Wed"
    } else if longDate == "Thursday" {
      return "Thu"
    } else if longDate == "Friday" {
      return "Fri"
    } else if longDate == "Saturday" {
      return "Sat"
    } else {
      return nil
    }
  }
  func getTimeObject() -> Time {
    let timeParts = self.formatted(
      .dateTime
        .locale(.init(identifier: "en_UK"))
        .hour(.twoDigits(amPM: .omitted))
        .minute()
        .second()
    ).split(separator: ":")
    let hour = Int(timeParts[0])!
    let minute = Int(timeParts[1])!
    let second = Int(timeParts[2])!
    return Time(hour, minute, second)
  }
  func dateIsBetween(_ from: Date, _ to: Date) -> Bool {
    // only compare the date part, not the time part
    let calendar = Foundation.Calendar.current
    let fromWithoutHMS = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: from)!
    let toWithoutHMS = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: to)!
    let selfWithoutHMS = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    return selfWithoutHMS >= fromWithoutHMS && selfWithoutHMS <= toWithoutHMS
  }
}

/*
Example calendar:

* Default Week
Sun weekend
Mon schedule-a
Tue schedule-b
Wed schedule-c
Thu schedule-b
Fri schedule-c
Sat weekend

* Special Days
11/11/2016 holiday # Veteran's Day
11/23/2016 holiday # Teacher Service Day
11/24/2016 holiday # Thanksgiving Day
11/25/2016 holiday
12/14/2016 finals-wed
12/15/2016 finals-thu
12/16/2016 finals-fri
12/19/2016-01/02/2017 holiday # Holiday Recess
01/03/2017 holiday # Teacher Service Day
01/04/2017-01/06/2017 normal
01/16/2017 holiday # MLK Day
02/20/2017-02/24/2017 holiday # Winter Recess
03/08/2017 communication-even
03/09/2017 communication-odd
*/

struct DefaultDay {
  let day: String
  let scheduleId: String
}

struct SpecialDay {
  let from: Date
  let to: Date
  let scheduleId: String
  let name: String?
}

struct Calendar {
  let defaultWeek: [DefaultDay]
  let specialDays: [SpecialDay]
}

func parseCalendar(_ calendarStr: String) -> Calendar {
  var defaultWeek: [DefaultDay] = []
  var specialDays: [SpecialDay] = []
  let schedules = calendarStr.split(separator: "*")
  //    print(schedules)
  for schedule in schedules {
    let lines = schedule.split(separator: "\r\n")
    //        print(lines)
    let name = String(lines[0].dropFirst())
    //        print("cal name", name)
    if name == "Default Week" {
      for line in lines[1...] {
        let parts = line.split(separator: " ")
        defaultWeek.append(DefaultDay(day: String(parts[0]), scheduleId: String(parts[1])))
      }
    } else if name == "Special Days" {
      // format: start(-end) cal_name # name
      for line in lines[1...] {
        let splitByHashtag = line.split(separator: "#")
        //                print("splitByHashtag: ", splitByHashtag)
        let parts = splitByHashtag[0].split(separator: " ")
        //                print("parts: ", parts)
        let dateParts = parts[0].split(separator: "-")
        let from = Date(String(dateParts[0]))
        var to: Date?
        if dateParts.count == 1 {
          to = from
        } else {
          to = Date(String(dateParts[1]))
        }
        //                print("from: ", from, "to: ", to!)
        specialDays.append(
          SpecialDay(
            from: from, to: to!, scheduleId: String(parts[1]),
            name: splitByHashtag.count == 1 ? nil : String(splitByHashtag[1].dropFirst())))
        //                print("appended")
      }
    }
  }
  return Calendar(defaultWeek: defaultWeek, specialDays: specialDays)
}

//let testCalStr = "* Default Week\r\nSun weekend\r\nMon schedule-a\r\nTue schedule-b \r\nWed schedule-c\r\nThu schedule-b\r\nFri schedule-c\r\nSat weekend\r\n\r\n* Special Days\r\n11/11/2016 holiday # Veteran's Day\r\n11/23/2016 holiday # Teacher Service Day\r\n11/24/2016 holiday # Thanksgiving Day\r\n11/25/2016 holiday\r\n12/14/2016 finals-wed\r\n12/15/2016 finals-thu\r\n12/16/2016 finals-fri\r\n12/19/2016-01/02/2017 holiday # Holiday Recess\r\n01/03/2017 holiday # Teacher Service Day\r\n01/04/2017-01/06/2017 normal\r\n01/16/2017 holiday # MLK Day\r\n02/20/2017-02/24/2017 holiday # Winter Recess\r\n"
// print(parseCalendar(testCalStr))

/*
Example schedule:

* schedule-a # All Periods
8:30 {Period 1}
9:20 Passing to {Period 2}
9:27 {Period 2}
10:17 Brunch
10:25 Passing to {Period 3}
10:32 {Period 3}
11:22 Passing to {Period 4}
11:29 {Period 4}
12:19 Lunch
12:54 Passing to {Period 5}
13:01 {Period 5}
13:51 Passing to {Period 6}
13:58 {Period 6}
14:48 Passing to {Period 7}
14:55 {Period 7}
15:45 Free

* schedule-b # Odd Block
8:30 {Period 1}
10:00 Brunch
10:08 Passing to {Period 3}
10:15 {Period 3}
11:45 Lunch
12:25 Passing to {Period 5}
12:32 {Period 5}
14:02 Passing to {Period 7}
14:09 {Period 7}
15:39 Free
*/

struct Time {
  let hour: Int
  let minute: Int
  let second: Int
  init(_ hour: Int, _ minute: Int) {
    self.hour = hour
    self.minute = minute
    self.second = 0
  }
  init(_ hour: Int, _ minute: Int, _ second: Int) {
    self.hour = hour
    self.minute = minute
    self.second = second
  }
  func toSeconds() -> Int {
    return hour * 60 * 60 + minute * 60 + second
  }
}

struct Period {
  let start: Time
  let name: String
}

struct Schedule {
  let id: String
  let name: String
  let periods: [Period]
}

func parseSchedules(_ scheduleStr: String) -> [Schedule] {
  var schedules: [Schedule] = []
  let lines = scheduleStr.split(separator: "\r\n\r\n")
  for line in lines {
    var periods: [Period] = []
    let parts = line.split(separator: "\r\n")
    //        print(parts)
    let line_0 = parts[0].dropFirst(2).split(separator: "#")
    let scheduleId = line_0[0].dropLast()
    let scheduleName = line_0[1].dropFirst()
    for line in parts[1...] {
      let parts = line.split(separator: " ", maxSplits: 1)
      let startParts = parts[0].split(separator: ":")
      // strip away any { and } from period name
      periods.append(
        Period(
          start: Time(Int(startParts[0])!, Int(startParts[1])!),
          name: String(parts[1].filter { !"{}".contains($0) })))
    }
    schedules.append(Schedule(id: String(scheduleId), name: String(scheduleName), periods: periods))
  }
  return schedules
}

//let testSchedulesStr = "* schedule-a # All Periods\r\n8:30 {Period 1}\r\n9:20 Passing to {Period 2}\r\n9:27 {Period 2}\r\n10:17 Brunch\r\n10:25 Passing to {Period 3}\r\n10:32 {Period 3}\r\n11:22 Passing to {Period 4}\r\n11:29 {Period 4}\r\n12:19 Lunch\r\n12:54 Passing to {Period 5}\r\n13:01 {Period 5}\r\n13:51 Passing to {Period 6}\r\n13:58 {Period 6}\r\n14:48 Passing to {Period 7}\r\n14:55 {Period 7}\r\n15:45 Free\r\n\r\n* schedule-b # Odd Block\r\n8:30 {Period 1}\r\n10:00 Brunch\r\n10:08 Passing to {Period 3}\r\n10:15 {Period 3}\r\n11:45 Lunch\r\n12:25 Passing to {Period 5}\r\n12:32 {Period 5}\r\n14:02 Passing to {Period 7}\r\n14:09 {Period 7}\r\n15:39 Free\r\n\r\n* schedule-c # Even Block\r\n8:30 {Period 2}\r\n10:00 Passing to Academic Collaboration Time\r\n10:07 Academic Collaboration Time\r\n11:00 Brunch\r\n11:08 Passing to {Period 4}\r\n11:15 {Period 4}\r\n12:45 Lunch\r\n13:25 Passing to {Period 6}\r\n13:32 {Period 6}\r\n15:02 Free\r\n\r\n* schedule-d # PM Modified Odd Block\r\n8:30 {Period 1}\r\n9:30 Passing to {Period 3}\r\n9:37 {Period 3}\r\n10:37 Brunch\r\n10:45 Passing to {Period 5}\r\n10:52 {Period 5}\r\n11:52 Passing to {Period 7}\r\n11:59 {Period 7}\r\n12:59 Lunch\r\n1:40 Free\r\n\r\n* schedule-e # PM Modified Even Block\r\n8:30 {Period 2}\r\n9:30 Passing to Academic Collaboration Time\r\n9:37 Academic Collaboration Time\r\n10:20 Brunch\r\n10:28 Passing to {Period 4}\r\n10:35 {Period 4}\r\n11:35 Passing to {Period 6}\r\n11:42 {Period 6}\r\n12:42 Lunch\r\n1:25 Free\r\n\r\n"
//print(parseSchedules(testSchedulesStr))
