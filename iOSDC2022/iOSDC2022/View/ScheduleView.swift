import SwiftUI
import ComposableArchitecture

struct MyTimetableState: Equatable {
    
}

enum MyTimetableAction {
    
}

struct MyTimatableEnvironment {
    
}


struct ScheduleView: View {
    var schedule: Schedule
    var body: some View {
        HStack {
            ForEach(schedule.daySchedules) { daySchedule in
               
                ScrollView {
                    VStack {
                        Text(daySchedule.date.dayString)
                        ForEach(Array(daySchedule.proposals.enumerated()), id: \.offset) { index, proposal in
                            ProposalCell(proposal: proposal)
                                .frame(height: 80)
                        }
                    }.frame(width: 200)
                }
                
            }
            Spacer()
        }
    }
}

struct MyListView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView(schedule: Schedule())
    }
}
