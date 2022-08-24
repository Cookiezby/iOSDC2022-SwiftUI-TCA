import ComposableArchitecture
import SwiftUI

struct SidebarState: Equatable {
    var selectedDate: Date?
    var days: [Date] = []
}

enum SidebarAction: Equatable {
    case selectDate(Date)
}

struct SidebarEnvironment: Equatable {}

let sidebarReducer = Reducer<SidebarState, SidebarAction, SidebarEnvironment>.init { state, action, environement in
    switch action {
    case .selectDate(let date):
        state.selectedDate = date
        return .none
    }
}

struct SiderbarView: View {
    let store: Store<SidebarState, SidebarAction>
    var body: some View {
        WithViewStore(self.store) { viewStore in
            List{
                VStack(alignment: .leading){
                    Text("日付")
                        .font(Font.system(size: 12, weight: .bold))
                        .foregroundColor(Color.gray)
                    ForEach(Array(viewStore.days.enumerated()), id: \.offset) { index, element in
                        Button(action: {
                            viewStore.send(.selectDate(element))
                        }, label: {
                            HStack(alignment: .center, spacing: 8){
                                Image(systemName: "\(index).circle")
                                    .font(Font.system(size: 16))
                                    .foregroundColor(Color.blue)
                                Text("\(element.siderBarString)")
                                    .font(Font.system(size: 14))
                                Spacer()
                            }
                            .padding(.leading, 8)
                            
                        })
                        .buttonStyle(.plain)
                        .frame(height: 26)
                        .frame(maxWidth: .infinity)
                        .background(element == viewStore.selectedDate ? Color("SiderbarSelected") : Color.clear)
                        .cornerRadius(6)
                        
                       
                    }
                }
                
            }
        }
    }
}

struct SideBar_Previews: PreviewProvider {
    static var previews: some View {
        SiderbarView(store: Store<SidebarState, SidebarAction>(initialState: SidebarState(days: MockData.shared.days), reducer: sidebarReducer, environment: SidebarEnvironment()))
    }
}
