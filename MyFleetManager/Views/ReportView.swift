import SwiftUI
import UniformTypeIdentifiers
import UIKit
import PDFKit

struct ReportView: View {
    @ObservedObject var viewModel: FleetViewModel
    @StateObject private var reportViewModel = ReportViewModel()
    @State private var showingShareSheet = false
    @State private var showingPrintSheet = false
    @State private var showingPDFSheet = false
    @State private var reportText = ""
    @State private var isReportGenerated = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                // Filter Section
                Form {
                    Section(header: Text("Filter Options")) {
                        Picker("Status", selection: $reportViewModel.selectedStatus) {
                            Text("All").tag(Optional<VehicleStatus>.none)
                            ForEach([VehicleStatus.active, .needsRepair, .grounded, .returned], id: \.self) { status in
                                Text(status.rawValue.capitalized).tag(Optional(status))
                            }
                        }
                        
                        Picker("Ownership", selection: $reportViewModel.selectedOwnership) {
                            Text("All").tag(Optional<VehicleOwnership>.none)
                            ForEach([VehicleOwnership.owned, .rented, .amazonLeased], id: \.self) { type in
                                Text(type.rawValue.capitalized).tag(Optional(type))
                            }
                        }
                        
                        Toggle("Show Only Damaged Vehicles", isOn: $reportViewModel.showOnlyDamaged)
                        
                        DatePicker("Start Date", selection: Binding(
                            get: { reportViewModel.startDate ?? Date() },
                            set: { reportViewModel.startDate = $0 }
                        ), displayedComponents: .date)
                        
                        DatePicker("End Date", selection: Binding(
                            get: { reportViewModel.endDate ?? Date() },
                            set: { reportViewModel.endDate = $0 }
                        ), displayedComponents: .date)
                    }
                }
                .frame(height: 300)
                
                // Report Preview
                ScrollView {
                    Text(reportText)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                }
                
                // Action Buttons
                VStack(spacing: 15) {
                    HStack(spacing: 10) {
                        Button(action: generateReport) {
                            Label("Generate", systemImage: "doc.text")
                                .frame(minWidth: 100)
                        }
                        .buttonStyle(.bordered)
                        .disabled(isReportGenerated)
                        
                        Menu {
                            Button(action: { showingShareSheet = true }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            
                            Button(action: { showingPrintSheet = true }) {
                                Label("Print", systemImage: "printer")
                            }
                            
                            Button(action: { showingPDFSheet = true }) {
                                Label("Export PDF", systemImage: "doc.fill")
                            }
                        } label: {
                            Label("Export", systemImage: "square.and.arrow.up")
                                .frame(minWidth: 100)
                        }
                        .buttonStyle(.bordered)
                        .disabled(!isReportGenerated)
                    }
                    
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Return to Main Screen")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationTitle("Generate Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if !reportText.isEmpty {
                    ShareSheet(activityItems: [reportText])
                }
            }
            .sheet(isPresented: $showingPrintSheet) {
                if !reportText.isEmpty {
                    PrintSheet(reportText: reportText)
                }
            }
            .sheet(isPresented: $showingPDFSheet) {
                if !reportText.isEmpty {
                    PDFSheet(reportText: reportText)
                }
            }
        }
    }
    
    private func generateReport() {
        let filteredVehicles = reportViewModel.generateReport(from: viewModel.vehicles)
        reportText = reportViewModel.generateReportText(from: filteredVehicles)
        isReportGenerated = true
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct PrintSheet: UIViewControllerRepresentable {
    let reportText: String
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "Fleet Report"
        
        let formatter = UISimpleTextPrintFormatter(text: reportText)
        formatter.perPageContentInsets = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)
        
        printController.printInfo = printInfo
        printController.printFormatter = formatter
        
        DispatchQueue.main.async {
            printController.present(animated: true) { (_, completed, error) in
                DispatchQueue.main.async {
                    dismiss()
                }
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No update needed
    }
}

struct PDFSheet: UIViewControllerRepresentable {
    let reportText: String
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        
        // Create PDF document
        let pdfMetaData = [
            kCGPDFContextCreator: "MyFleetManager",
            kCGPDFContextAuthor: "Fleet Manager",
            kCGPDFContextTitle: "Fleet Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
            ]
            
            let attributedText = NSAttributedString(string: reportText, attributes: attributes)
            let textRect = CGRect(x: 72, y: 72, width: pageWidth - 144, height: pageHeight - 144)
            attributedText.draw(in: textRect)
        }
        
        // Create temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "FleetReport_\(Date().timeIntervalSince1970).pdf"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            
            // Share PDF
            let activityVC = UIActivityViewController(
                activityItems: [fileURL],
                applicationActivities: nil
            )
            
            // Exclude unnecessary activity types
            activityVC.excludedActivityTypes = [
                .assignToContact,
                .addToReadingList,
                .openInIBooks,
                .markupAsPDF,
                .postToFacebook,
                .postToTwitter,
                .postToWeibo,
                .postToFlickr,
                .postToVimeo,
                .postToTencentWeibo,
                .saveToCameraRoll,
                .copyToPasteboard,
                .airDrop
            ]
            
            // Add completion handler to clean up and dismiss
            activityVC.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
                // Clean up the temporary file
                try? FileManager.default.removeItem(at: fileURL)
                
                // Dismiss the sheet
                DispatchQueue.main.async {
                    dismiss()
                }
            }
            
            DispatchQueue.main.async {
                controller.present(activityVC, animated: true)
            }
        } catch {
            print("Error creating PDF: \(error)")
            // Dismiss on error
            DispatchQueue.main.async {
                dismiss()
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No update needed
    }
} 