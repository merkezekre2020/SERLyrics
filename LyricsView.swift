import SwiftUI

struct LyricsView: View {
    @StateObject var viewModel: LyricsViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color.gray.opacity(0.65)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    header
                    lyricsList
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
            }
            .navigationTitle("SERLyric")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Yenile") {
                        viewModel.refresh()
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text(viewModel.track?.title ?? "Çalan parça yok")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            Text(viewModel.track?.artist ?? "")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(.ultraThinMaterial.opacity(0.18), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var lyricsList: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Sözler yükleniyor...")
                    .tint(.white)
                    .foregroundStyle(.white)
                    .frame(maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .frame(maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 14) {
                            ForEach(viewModel.lyrics) { line in
                                Text(line.text.isEmpty ? "..." : line.text)
                                    .font(.system(size: 22, weight: line.id == viewModel.activeLineID ? .bold : .regular))
                                    .foregroundStyle(line.id == viewModel.activeLineID ? .white : .white.opacity(0.45))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                    .id(line.id)
                                    .animation(.easeInOut(duration: 0.18), value: viewModel.activeLineID)
                            }
                        }
                        .padding(.vertical, 24)
                    }
                    .onChange(of: viewModel.activeLineID) { _, activeID in
                        guard let activeID else { return }
                        withAnimation(.easeInOut(duration: 0.25)) {
                            proxy.scrollTo(activeID, anchor: .center)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
