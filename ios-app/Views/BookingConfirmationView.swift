import SwiftUI

struct BookingConfirmationView: View {
    @StateObject var viewModel: BookingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.confirmation.status)
                .font(.title2.bold())

            optionSummary

            if let driver = viewModel.confirmation.driver {
                driverSummary(driver)
            }

            Spacer()
        }
        .padding(20)
        .navigationTitle("Booking")
    }

    private var optionSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.confirmation.option.name)
                .font(.headline)

            Text("\(viewModel.confirmation.option.price) • \(viewModel.confirmation.option.appName)")
                .foregroundStyle(.secondary)

            Text("Arriving in \(viewModel.confirmation.option.etaMinutes) min")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func driverSummary(_ driver: DriverInfo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Driver")
                .font(.headline)
            Text(driver.name)
            Text(driver.vehicle)
            Text("Plate: \(driver.licensePlate)")
            Text("Driver ETA: \(driver.etaMinutes) min")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        BookingConfirmationView(viewModel: BookingViewModel())
    }
}
