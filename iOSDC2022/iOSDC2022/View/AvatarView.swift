import SwiftUI

struct AvatarView: View {
    var urlString: String?
    var tintColor: Color
    var body: some View {
        if let urlString, let url = URL(string: urlString){
            AsyncImage(url: url, content: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                },
            placeholder: {
                placeHolder
            })
        } else {
            placeHolder
        }
    }
    
    private var placeHolder: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .foregroundColor(tintColor)
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView(tintColor: .white)
    }
}
