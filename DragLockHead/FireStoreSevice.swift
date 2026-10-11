import Foundation

struct KeyInfo {
    let tier: String
    let expiry: String?
}

final class FirestoreService {
    static let shared = FirestoreService()
    private let projectId = "hlong-key-sever"

    func verify(key: String, device: String, completion: @escaping (Result<KeyInfo, Error>) -> Void) {
        let upper = key.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard let url = URL(string: "https://firestore.googleapis.com/v1/projects/\(projectId)/databases/(default)/documents:runQuery") else {
            completion(.failure(NSError(domain: "verify", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "URL invalid"])))
            return
        }

        let body: [String: Any] = [
            "structuredQuery": [
                "from": [["collectionId": "keys"]],
                "where": [
                    "compositeFilter": [
                        "op": "AND",
                        "filters": [
                            ["fieldFilter": [
                                "field": ["fieldPath": "key"],
                                "op": "EQUAL",
                                "value": ["stringValue": upper]
                            ]],
                            ["fieldFilter": [
                                "field": ["fieldPath": "active"],
                                "op": "EQUAL",
                                "value": ["booleanValue": true]
                            ]]
                        ]
                    ]
                ],
                "limit": 1
            ]
        ]

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        req.timeoutInterval = 12

        URLSession.shared.dataTask(with: req) { [weak self] data, _, error in
            guard let self = self else { return }

            if let error = error {
                completion(.failure(NSError(domain: "verify", code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Loi ket noi: \(error.localizedDescription)"])))
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                  let first = json.first,
                  let doc = first["document"] as? [String: Any],
                  let fields = doc["fields"] as? [String: Any] else {
                completion(.failure(NSError(domain: "verify", code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "KEY KHONG TON TAI HOAC DA BI KHOA"])))
                return
            }

            if let ef = fields["expiry"] as? [String: Any],
               let ts = ef["timestampValue"] as? String {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                var date = formatter.date(from: ts)
                if date == nil {
                    formatter.formatOptions = [.withInternetDateTime]
                    date = formatter.date(from: ts)
                }
                if let d = date, d < Date() {
                    completion(.failure(NSError(domain: "verify", code: 401,
                        userInfo: [NSLocalizedDescriptionKey: "KEY DA HET HAN"])))
                    return
                }
            }

            var devices: [String] = []
            if let df = fields["devices"] as? [String: Any],
               let arr = df["arrayValue"] as? [String: Any],
               let vals = arr["values"] as? [[String: Any]] {
                devices = vals.compactMap { $0["stringValue"] as? String }
            }
            if !devices.isEmpty && !devices.contains(device) {
                completion(.failure(NSError(domain: "verify", code: 403,
                    userInfo: [NSLocalizedDescriptionKey: "KEY DA DUNG TREN THIET BI KHAC"])))
                return
            }

            if devices.isEmpty, let docName = doc["name"] as? String {
                self.patchDevice(docName: docName, device: device)
            }

            let tier = (fields["tier"] as? [String: Any])?["stringValue"] as? String ?? "VIP"
            let expiry = (fields["expiry"] as? [String: Any])?["timestampValue"] as? String
            completion(.success(KeyInfo(tier: tier, expiry: expiry)))
        }.resume()
    }

    private func patchDevice(docName: String, device: String) {
        guard let url = URL(string: "https://firestore.googleapis.com/v1/\(docName)?updateMask.fieldPaths=devices") else { return }
        let body: [String: Any] = [
            "fields": ["devices": ["arrayValue": ["values": [["stringValue": device]]]]]
        ]
        var req = URLRequest(url: url)
        req.httpMethod = "PATCH"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: req).resume()
    }
}
