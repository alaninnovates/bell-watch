//
//  ContentView.swift
//  bell Watch App
//
//  Created by Alan Chen on 1/17/24.
//

import SwiftUI

struct ContentView: View {
    @State private var now: Date = Date()
    @State private var loaded: Bool = false
    @State private var calendar: Calendar = Calendar(defaultWeek: [], specialDays: [])
    @State private var schedules: [Schedule] = []
    // in seconds
    @State private var timeLeft: Int = 0
    @State private var totalTime: Int = 0
    @State private var periodName: String = ""
    @State private var scheduleName: String = ""
    // time tracking
    @State private var currPeriod: Period = Period(start: Time(0, 0), name: "")
    @State private var nextPeriod: Period = Period(start: Time(0, 0), name: "")
    @State private var lastPeriod: Bool = false
    
    var body: some View {
        let screenSize = WKInterfaceDevice.current().screenBounds
        let fontScale = screenSize.width / 208
        VStack {
            if !loaded || timeLeft <= 0 {
                Text("Syncing Schedule")
                    .font(
                        .system(
                            size: 30 * fontScale, weight: .regular,
                            design: .monospaced))
            } else {
                Text(
                    "\(String(format: "%02d", timeLeft / 3600)):\(String(format: "%02d", timeLeft % 3600 / 60)):\(String(format: "%02d", timeLeft % 60))"
                )
                .font(
                    .system(
                        size: 30 * fontScale, weight: .bold, design: .monospaced))
                Text(periodName)
                    .font(
                        .system(
                            size: 20 * fontScale, weight: .regular,
                            design: .monospaced))
                HStack {
                    Text("SCHEDULE")
                        .font(
                            .system(
                                size: 10 * fontScale, weight: .regular,
                                design: .monospaced))
                    Spacer()
                    Text(scheduleName)
                        .font(
                            .system(
                                size: 10 * fontScale, weight: .regular,
                                design: .monospaced))
                }.padding(.horizontal).frame(
                    width: screenSize.width * 0.8, height: screenSize.height * 0.1, alignment: .bottomTrailing
                )
                
            }
        }
        // .background(TimerArc(currentSeconds: timeLeft, totalSeconds: totalTime).fill(.gray).opacity(0.7).frame(width: screenSize.width * 0.8, height: screenSize.width * 0.8))
        .background(
            PartialRoundedRectangle(cornerRadius: 10, currentSeconds: timeLeft, totalSeconds: totalTime)
                .opacity(0.7).frame(width: screenSize.width * 0.85, height: screenSize.height * 0.8)
                .foregroundColor(getBorderColor())
        )
        .padding()
        .onReceive(timer) { _ in
            self.now = Date()
            update()
        }
    }
    func getBorderColor() -> Color {
        let colors = [Color.red, Color.orange, Color.yellow, Color.green]
        let color: Color
        if timeLeft <= 2 * 60 {
            color = colors[0]
        } else if timeLeft <= 5 * 60 {
            color = colors[1]
        } else if timeLeft <= 15 * 60 {
            color = colors[2]
        } else {
            color = colors[3]
        }
        return color
    }
    func fetchData() {
        guard let url = URL(string: "https://bell.plus/api/data/lahs") else { return }
        print(url)
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                if let rawSchool = try? decoder.decode(RawSchool.self, from: data) {
//                    print("RAW DATA", rawSchool)
                    let schedules = parseSchedules(rawSchool.schedules)
//                    print("SCHEDULES", schedules)
                    let calendar = parseCalendar(rawSchool.calendar)
//                    print("CALENDAR", calendar)
                    DispatchQueue.main.async {
                        self.schedules = schedules
                        self.calendar = calendar
                        self.loaded = true
                        print("fetched data")
                    }
                } else {
                    print("failed to decode", String(data: data, encoding: .utf8) ?? "no data")
                }
            }
        }.resume()
    }
    func getSchedule(_ id: String) -> Schedule? {
        for schedule in schedules {
            if schedule.id == id {
                return schedule
            }
        }
        return nil
    }
    func nowIsSpecialDay() -> SpecialDay? {
        for specialDay in calendar.specialDays {
            if now.dateIsBetween(specialDay.from, specialDay.to) {
                return specialDay
            }
        }
        return nil
    }
    func comparePeriodTime(_ currTime: Time, _ startTime: Time) -> Bool {
        if currTime.hour < startTime.hour {
            return false
        } else if currTime.hour == startTime.hour {
            if currTime.minute < startTime.minute {
                return false
            }
        }
        return true
    }
    func getCurrentPeriod() -> Period? {
        let specialDay = nowIsSpecialDay()
        if specialDay != nil {
            return nil
        } else {
            var day: DefaultDay = DefaultDay(day: "", scheduleId: "")
            for defaultDay in calendar.defaultWeek {
                print("default day: \(defaultDay.day), day of week: \(now.dayOfWeek() ?? "broken")")
                if defaultDay.day == now.dayOfWeek() {
                    day = defaultDay
                    break
                }
            }
            print("day: \(day.day)")
            let schedule = getSchedule(day.scheduleId)
            print("schedule: \(schedule!.name)")
            self.scheduleName = schedule!.name
            let periods = schedule!.periods
            var currPeriod = Period(start: Time(0, 0), name: "")
            var nextPeriod = Period(start: Time(0, 0), name: "")
            var lastPeriod = false
            for i in 0..<periods.count {
                if comparePeriodTime(self.now.getTimeObject(), periods[i].start) {
                    print("period: \(periods[i].name)")
                    currPeriod = periods[i]
                    if i + 1 < periods.count {
                        nextPeriod = periods[i + 1]
                    } else {
                        nextPeriod = periods[0]
                        lastPeriod = true
                    }
                }
            }
            self.periodName = currPeriod.name
            self.currPeriod = currPeriod
            self.nextPeriod = nextPeriod
            self.lastPeriod = lastPeriod
            return currPeriod
        }
    }
    func update() {
        if !loaded {
            fetchData()
            return
        }
        if lastPeriod {
            self.timeLeft =
            (86400 - currPeriod.start.toSeconds()) + nextPeriod.start.toSeconds()
            - (self.now.getTimeObject().toSeconds() - currPeriod.start.toSeconds())
            // total time between currPeriod and nextPeriod tomorrow
            self.totalTime = (86400 - currPeriod.start.toSeconds()) + nextPeriod.start.toSeconds()
        } else {
            self.timeLeft = nextPeriod.start.toSeconds() - self.now.getTimeObject().toSeconds()
            self.totalTime = nextPeriod.start.toSeconds() - currPeriod.start.toSeconds()
        }
        // print("but now also is", self.now)
        // print(self.now.)
        // print(timeLeft, self.now.getTimeObject().toSeconds())
        if timeLeft <= 0 {
            // get next period
            let specialDay = nowIsSpecialDay()
            if specialDay != nil {
                print("special day")
                let toWithoutHMS = Foundation.Calendar.current.date(
                    bySettingHour: 23, minute: 59, second: 59, of: specialDay!.to)!
                timeLeft = Int(toWithoutHMS.timeIntervalSince(self.now))
                periodName = specialDay!.name ?? "Special Day"
                scheduleName = getSchedule(specialDay!.scheduleId)!.name
            } else {
                print("normal day")
                let currPeriod = getCurrentPeriod()
                print(currPeriod!)
                //                periodName = currPeriod.name
            }
        }
    }
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
}

#Preview {
    ContentView()
}

struct RawMeta: Codable {
    let name: String
    let periods: [String]
}

struct RawSchool: Codable {
    let meta: RawMeta
    let correction: String
    let calendar: String
    let schedules: String
}
