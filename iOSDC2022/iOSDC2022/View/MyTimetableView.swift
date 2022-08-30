import SwiftUI
import ComposableArchitecture

struct MyTimetableState: Equatable {
    
}

enum MyTimetableAction {
    
}

struct MyTimatableEnvironment {
    
}


struct MyTimetableView: View {
    var myTimetable: MyTimetable
    var body: some View {
        HStack {
            ForEach(myTimetable.dayTimetables) { dayTimetable in
               
                ScrollView {
                    VStack {
                        Text(dayTimetable.date.dayString)
                        ForEach(Array(dayTimetable.proposals.enumerated()), id: \.offset) { index, proposal in
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
        MyTimetableView(myTimetable: MyTimetable())
    }
}
