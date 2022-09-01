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
                VStack {
                    HStack {
                        Text(daySchedule.date.dayString)
                            .font(Font.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.gray)
                        Spacer()
                    }
                    ScrollView {
                        ForEach(Array(daySchedule.proposals.enumerated()), id: \.offset) { index, proposal in
                            ProposalCell(proposal: proposal)
                                .frame(height: 80)
                        }
                    }
                }.frame(width: 250)
            }
            .padding(.leading, 5)
            Spacer()
        }
        .background(Color.white)
    }
}

struct MyListView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView(schedule: Schedule())
    }
}
