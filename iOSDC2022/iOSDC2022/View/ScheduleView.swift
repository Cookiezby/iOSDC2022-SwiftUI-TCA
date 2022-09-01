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
        #if os(macOS)
        HStack(spacing: 5){
            ForEach(schedule.daySchedules) { daySchedule in
                VStack {
                    HStack {
                        Text(daySchedule.date.dayString)
                            .font(Font.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.gray)
                        Spacer()
                    }
                    ScrollView {
                        ForEach(Array(daySchedule.proposals.enumerated()), id: \.offset) { index, proposal in
                            ProposalCell(proposal: proposal)
                                .frame(height: 80)
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(.leading, 10)
        .background(Color.white)
        #elseif os(iOS)
        iOSScheduleView(usePageTab: UIDevice.current.userInterfaceIdiom == .phone) {
            ForEach(schedule.daySchedules) { daySchedule in
                VStack(spacing: 5){
                    HStack {
                        Text(daySchedule.date.dayString)
                            .font(Font.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.gray)
                        Spacer()
                    }
                    ScrollView {
                        ForEach(Array(daySchedule.proposals.enumerated()), id: \.offset) { index, proposal in
                            ProposalCell(proposal: proposal)
                                .frame(height: 80)
                        }
                    }
                }
            }
            .padding(.leading, 5)
            .padding(.trailing, 5)
            .background(Color.white)
        }
        #endif
    }
    
    @ViewBuilder
    func iOSScheduleView<Content>(
        usePageTab: Bool,
        content: @escaping () -> Content
    ) -> some View where Content: View {
        if usePageTab {
            TabView {
                content()
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            }
            #if os(iOS)
            .tabViewStyle(PageTabViewStyle())
            #endif
        } else {
            HStack(spacing: 5){
                content()
            }
            .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
        }
    }
}

struct MyListView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView(schedule: Schedule())
    }
}
