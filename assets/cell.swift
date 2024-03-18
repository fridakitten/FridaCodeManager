import SwiftUI
import Combine

struct cell: View {
    @State var credit: String
    @State var role: String
    @State var url: String
    var body: some View {
        HStack {
            AsyncImageLoaderView(urlString: url, width: 50, height: 50)
            .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 2)
            Spacer()
            VStack {
                Text(credit)
                    .foregroundColor(.primary)
                    .font(.system(size: 14, weight: .bold))
                Text(role)
                    .foregroundColor(.secondary)
                    .font(.system(size: 12, weight: .semibold))
            }
            .frame(width: 200)
            Spacer()
        }
    }
}

struct AsyncImageLoaderView: View {
    @StateObject private var imageLoader = ImageLoader()
    private let urlString: String
    private let width: CGFloat?
    private let height: CGFloat?

    init(urlString: String, width: CGFloat? = nil, height: CGFloat? = nil) {
        self.urlString = urlString
        self.width = width
        self.height = height
    }

    private var url: URL? {
        URL(string: urlString)
    }

    var body: some View {
        if let uiImage = imageLoader.image {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: width, height: height)
                .cornerRadius(360)
        } else {
            ProgressView()
                .aspectRatio(contentMode: .fit)
                .frame(width: width, height: height)
                .onAppear {
                    if let url = url {
                        imageLoader.loadImage(from: url)
                    }
                }
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    private var cancellable: AnyCancellable?

    init() {
        cancellable = AnyCancellable {}
    }

    func loadImage(from url: URL) {
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .compactMap { UIImage(data: $0) }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] loadedImage in
                      self?.image = loadedImage
                  })
    }
}