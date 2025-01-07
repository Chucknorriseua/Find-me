//
//  RecordsCell.swift
//  Find me
//
//  Created by Евгений Полтавец on 20/12/2024.
//
import SwiftUI

struct RecordsCell: View {
    
    
    @State private var isPlay: Bool = false
    @State private var voice: CGFloat = 0.0
    @State var records: FindMeUser
    @State var selectedRecords: String? = nil
    @StateObject var audiioViewModel: AudioRecorderViewModel
    @State private var showShareSheet = false

    
    var body: some View {
        VStack {
            LazyVStack(spacing: 10) {
                ForEach(Array(records.records.enumerated()), id: \.element) { index, record in
                    HStack(alignment: .bottom, spacing: 10) {
                        VStack(alignment: .leading) {
                            Text("Record  \(index + 1):   \(record)")
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .lineLimit(1)
                            if audiioViewModel.selectedRecords == record && audiioViewModel.isPlayAudiooo {
                                VStack {
                                    HStack {
                                        Text(audiioViewModel.currentTimeFormatted)
                                            .foregroundColor(Color.white)
                                            .font(.system(size: 16))
                                        Spacer()
                                    }
                                    ProgressView(value: audiioViewModel.progress, total: 1.0)
                                        .progressViewStyle(.linear)
                                        .tint(Color.white)
                                        .scaleEffect(x: 1, y: 2, anchor: .center)
                                }
                            } else {
                                Text("\(format(records.date))")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.white)
                            }
                        }
                        Spacer()
                        HStack {
                            if audiioViewModel.selectedRecords != record || !audiioViewModel.isPlayAudiooo {
                                Button {
                                    Task {
                                        let savedURL = await audiioViewModel.downloadAudioFromURL(urlString: record)
                                        if let savedURL = savedURL {
                                            audiioViewModel.audioFileURL = savedURL
                                            showShareSheet = true
                                        } else {
                                            print("Failed dowload file.")
                                        }
                                    }
                                } label: {
                                    Image(systemName: "square.and.arrow.up.circle.fill")
                                }
                            } else {
                             
                                Button {
                                    withAnimation(.snappy(duration: 1)) {
                                        if audiioViewModel.isPlayAudiooo {
                                            audiioViewModel.pauseAudio()
                                        } else {
                                            audiioViewModel.resumeAudio()
                                        }
                                    }
                                } label: {
                                    Image(systemName: "pause.circle.fill")
                                }
                            }
                            
                            Button(action: {
                                withAnimation(.snappy(duration: 1)) {
                                    if audiioViewModel.selectedRecords == record {
                                        if audiioViewModel.isPlayAudiooo {
                                            audiioViewModel.stopAudioPlayer()
                                        } else {
                                            audiioViewModel.resumeAudio()
                                        }
                                    } else {
                                        audiioViewModel.selectedRecords = record
                                        Task {
                                            await audiioViewModel.audioPlayer(url: URL(string: record), record: record)
                                        }
                                    }
                                }
                            }) {
                                Image(systemName: audiioViewModel.selectedRecords == record && audiioViewModel.isPlayAudiooo ? "stop.circle.fill" : "play.circle.fill")
                                
                            }
                            
                        }.font(.largeTitle)
                            .foregroundStyle(Color.white)
                        
                    }.frame(maxWidth: .infinity)
                        .padding(.all, 14)
                        .background(.ultraThinMaterial.opacity(0.2))
                        .cornerRadius(20)
                }
            }.sheet(isPresented: $showShareSheet) {
                if let fileURL = audiioViewModel.audioFileURL {
                    ShareSheet(activityItems: [fileURL], excludedActivityTypes: nil)
                } else {
                    Text("not found")
                }
            }
        }
    }
    func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM, HH:mm"
        return formatter.string(from: date)
    }
}


