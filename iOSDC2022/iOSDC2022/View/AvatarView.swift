//
//  AvatarView.swift
//  iOSDC2022
//
//  Created by 朱冰一 on 2022/09/07.
//

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
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundColor(tintColor)
            })
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .foregroundColor(tintColor)
        }
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView(tintColor: .white)
    }
}
