import SwiftUI
import PhotosUI

struct AddDamageView: View {
    let vehicle: Vehicle
    @ObservedObject var viewModel: FleetViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var description = ""
    @State private var isNewDamage = true
    @State private var selectedImages: [UIImage] = []
    @State private var showingImageSourcePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Damage Details")) {
                    TextEditor(text: $description)
                        .frame(height: 100)
                    
                    Toggle("New Damage", isOn: $isNewDamage)
                }
                
                Section(header: Text("Photos")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(selectedImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            Button(action: { showingImageSourcePicker = true }) {
                                VStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.largeTitle)
                                    Text("Add Photo")
                                }
                                .frame(width: 100, height: 100)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Report Damage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveDamage()
                        dismiss()
                    }
                    .disabled(description.isEmpty)
                }
            }
            .sheet(isPresented: $showingImageSourcePicker) {
                ImageSourcePicker(image: Binding(
                    get: { selectedImages.last ?? UIImage() },
                    set: { newImage in
                        if let image = newImage {
                            selectedImages.append(image)
                        }
                    }
                ), onImagePicked: { _ in })
            }
        }
    }
    
    private func saveDamage() {
        let photos = selectedImages.compactMap { image -> VehiclePhoto? in
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
            return VehiclePhoto(imageData: imageData, description: "Damage photo")
        }
        
        viewModel.addDamage(to: vehicle, description: description, isNewDamage: isNewDamage, photos: photos)
    }
} 