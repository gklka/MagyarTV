//
//  StreamResolver.swift
//  MagyarTVWatch
//
//  Copyright © 2026. GKSoftware. All rights reserved.
//

import Foundation

enum StreamResolverError: LocalizedError {
    case network(String)
    case missingStreamURL

    var errorDescription: String? {
        switch self {
        case .network(let reason):
            return reason
        case .missingStreamURL:
            return "Nem található a csatorna URL-je"
        }
    }
}

// Resolves the live HLS stream URL the same way as MenuController.m: loads the
// mediaklikk player page and extracts the "file" entry of its "playlist" JSON.
enum StreamResolver {
    private static let playerReferer = "https://player.mediaklikk.hu/playernew/"

    static func liveStreamURL(forChannel channelName: String) async throws -> URL {
        let urlString = "https://player.mediaklikk.hu/playernew/player.php?video=\(channelName)live&noflash=yes&osfamily=iOS&osversion=11.0&browsername=Safari&browserversion=11.0&title=\(channelName)&conteintid=\(channelName)live&embedded=0"
        guard let channelURL = URL(string: urlString) else {
            throw StreamResolverError.missingStreamURL
        }

        var request = URLRequest(url: channelURL)
        request.setValue(playerReferer, forHTTPHeaderField: "Referer")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw StreamResolverError.network(error.localizedDescription)
        }

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
            throw StreamResolverError.network("HTTP \(httpResponse.statusCode)")
        }

        guard let html = String(data: data, encoding: .utf8) else {
            throw StreamResolverError.missingStreamURL
        }

        let playlistSplit = html.components(separatedBy: "\"playlist\":")
        guard playlistSplit.count > 1 else {
            throw StreamResolverError.missingStreamURL
        }

        let fileSplit = playlistSplit[1].components(separatedBy: "\"file\": \"")
        guard fileSplit.count > 1 else {
            throw StreamResolverError.missingStreamURL
        }

        let urlSplit = fileSplit[1].components(separatedBy: "\",\n")
        guard urlSplit.count > 1 else {
            throw StreamResolverError.missingStreamURL
        }

        let unescaped = urlSplit[0].replacingOccurrences(of: "\\", with: "")
        guard let liveStreamURL = URL(string: unescaped) else {
            throw StreamResolverError.missingStreamURL
        }

        return liveStreamURL
    }
}
