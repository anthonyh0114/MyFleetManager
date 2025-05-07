import SwiftUI
import AVFoundation

struct ImageSourcePicker: View {
    @Binding var image: UIImage?
    var onImagePicked: (UIImage) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var showingCameraAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header Section
                VStack(spacing: 10) {
                    Text("Add Photo to Vehicle Record")
                        .font(.headline)
                    Text("Choose how you want to add a photo")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Photo Options
                List {
                    Section {
                        Button(action: {
                            #if targetEnvironment(simulator)
                            showingCameraAlert = true
                            #else
                            showingCamera = true
                            #endif
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                Text("Take Photo")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Button(action: { showingPhotoLibrary = true }) {
                            HStack {
                                Image(systemName: "photo.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                Text("Choose from Library")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                // Bottom Section
                VStack(spacing: 10) {
                    Text("Your photo will be saved to the vehicle record")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Back") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(image: $image, onImageCaptured: onImagePicked)
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            ImagePicker(image: $image, onImagePicked: onImagePicked)
        }
        .alert("Camera Not Available", isPresented: $showingCameraAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The camera is not available in the simulator. Please use a physical device to take photos, or choose from the photo library.")
        }
    }
} 