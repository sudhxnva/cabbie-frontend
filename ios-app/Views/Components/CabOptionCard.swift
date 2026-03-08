import SwiftUI

struct CabOptionCard: View {
    let option: CabOption
    let onBookRide: (CabOption) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(option.name)
                    .font(.headline)
                Spacer()
                Text(option.price)
                    .font(.headline)
            }

            Text("\(option.etaMinutes) min away • \(option.appName)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Book Ride") {
                onBookRide(option)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
