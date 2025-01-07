//
//  RecordSettingsCell.swift
//  Find me
//
//  Created by Евгений Полтавец on 27/12/2024.
//

import SwiftUI
import UIKit

struct RecordSettingsCell: View {
    
    
    @State private var voice: CGFloat = 0.0
    @State var records: String
    @State var date: Date
    @State var count: Int
    @StateObject var audiioViewModel: AudioRecorderViewModel
    @State private var showShareSheet = false
    @State private var isDeleteRecord = false
    var delete: ()->()

  
    var body: some View {
        VStack {
            LazyVStack(spacing: 10) {
                    HStack(alignment: .bottom, spacing: 10) {
                        VStack(alignment: .leading) {
                            Text("Record \(count):  \(records)")
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .lineLimit(1)
                            
                            if audiioViewModel.selectedRecords == records && audiioViewModel.isPlayAudiooo {
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
                                Text("\(format(date))")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.white)
                            }
                        }.padding(.bottom, 10)
                            .padding(.leading, 4)
                        Spacer()
                        HStack {
                            if audiioViewModel.selectedRecords != records || !audiioViewModel.isPlayAudiooo {
                                Button {
                                    Task {
                                        let savedURL = await audiioViewModel.downloadAudioFromURL(urlString: records)
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
                                    if audiioViewModel.selectedRecords == records {
                                 
                                        if audiioViewModel.isPlayAudiooo {
                                            audiioViewModel.stopAudioPlayer()
                                        } else {
                                            audiioViewModel.resumeAudio()
                                        }
                                    } else {
                                        audiioViewModel.selectedRecords = records
                                        Task {
                                            await audiioViewModel.audioPlayer(url: URL(string: records), record: records)
                                        }
                                    }
                                }
                            }) {
                                Image(systemName: audiioViewModel.selectedRecords == records && audiioViewModel.isPlayAudiooo ? "stop.circle.fill" : "play.circle.fill")
                            }
                            if audiioViewModel.selectedRecords != records || !audiioViewModel.isPlayAudiooo {
                                Button {
                                    withAnimation(.snappy(duration: 1)) {
                                        
                                        isDeleteRecord = true
                                        audiioViewModel.selectedRecords = records
                                        delete()
                                    }
                                } label: {
                                    Image(systemName: "trash.circle.fill")
                                }
                            }
                        }.font(.largeTitle)
                            .foregroundStyle(Color.white)
                            .padding(.vertical, 14)
                        
                    }.frame(maxWidth: .infinity)
                    .overlay(alignment: .center, content: {
                        if isDeleteRecord {
                            ZStack(content: {
                                Text("removed")
                                    .font(.title2.bold())
                                    .foregroundColor(Color.white)
                            })
                            .frame(maxWidth: .infinity, maxHeight: 70)
                            .background(Color.red.opacity(0.3))
                        }
                    })
                    .background(.ultraThinMaterial.opacity(1))
                        .cornerRadius(20)
                        .padding(.horizontal, 6)
                
            }.disabled(isDeleteRecord)
            .sheet(isPresented: $showShareSheet) {
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
//
//#Preview(body: {
//    RecordSettingsCell(records: "sssss" , date: Date(), count: 1, audiioViewModel: AudioRecorderViewModel.shared, delete: {})
//})
