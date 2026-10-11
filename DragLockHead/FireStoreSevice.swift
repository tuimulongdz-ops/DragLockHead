import Foundation

struct KeyInfo {
    let tier: String
    let expiry: String?
}

final class FirestoreService {

    static let shared = FirestoreService()
    private let projectId = "hlong-key-sever"

    func verify(
        key: String,
        device: String,
        completion: @escaping (
            Result<KeyInfo, Error>
        ) -> Void
    ) {
        let upper = key
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .uppercased()

        let urlStr =
            "https://firestore.googleapis.com/v1"
            + "/projects/\(projectId)"
            + "/databases/(default)/documents:runQuery"

        guard let url = URL(string: urlStr) else {
            completion(.failure(NSError(
                domain: "v", code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "URL invalid"
                ]
            )))
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
                                "field": [
                                    "fieldPath": "key"
                                ],
                                "op": "EQUAL",
                                "value": [
                                    "stringValue": upper
                                ]
                            ]],
                            ["fieldFilter": [
                                "field": [
                                    "fieldPath": "active"
                                ],
                                "op": "EQUAL",
                                "value": [
                                    "booleanValue": true
                                ]
                            ]]
                        ]
                    ]
                ],
                "limit": 1
            ]
        ]

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        req.httpBody = try? JSONSerialization
            .data(withJSONObject: body)
        req.timeoutInterval = 12

        URLSession.shared.dataTask(
            with: req
        ) { [weak self] data, _, error in
            guard let self = self else { return }
            _ = self

            if error != nil {
                completion(.failure(NSError(
                    domain: "v", code: -2,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "Lỗi kết nối"
                    ]
                )))
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization
                    .jsonObject(with: data)
                    as? [[String: Any]],
                  let first = json.first,
                  let doc = first["document"]
                    as? [String: Any],
                  let fields = doc["fields"]
                    as? [String: Any]
            else {
                completion(.failure(NSError(
                    domain: "v", code: 404,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "KEY KHONG TON TAI"
                    ]
                )))
                return
            }

            if let ef = fields["expiry"]
                as? [String: Any],
               let ts = ef["timestampValue"]
                as? String {
                let f = ISO8601DateFormatter()
                f.formatOptions = [
                    .withInternetDateTime,
                    .withFractionalSeconds
                ]
                var d = f.date(from: ts)
                if d == nil {
                    f.formatOptions = [
                        .withInternetDateTime
                    ]
                    d = f.date(from: ts)
                }
                if let dd = d, dd < Date() {
                    completion(.failure(NSError(
                        domain: "v", code: 401,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "KEY DA HET HAN"
                        ]
                    )))
                    return
                }
            }

            var devs: [String] = []
            if let df = fields["devices"]
                as? [String: Any],
               let arr = df["arrayValue"]
                as? [String: Any],
               let vals = arr["values"]
                as? [[String: Any]] {
                devs = vals.compactMap {
                    $0["stringValue"] as? String
                }
            }

            if !devs.isEmpty && !devs.contains(device) {
                completion(.failure(NSError(
                    domain: "v", code: 403,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "KEY DA DUNG MAY KHAC"
                    ]
                )))
                return
            }

            if devs.isEmpty,
               let docName = doc["name"] as? String {
                FirestoreService.patchDevice(
                    docName: docName,
                    device: device
                )
            }

            let tier = (fields["tier"]
                as? [String: Any])?["stringValue"]
                as? String ?? "VIP"
            let exp = (fields["expiry"]
                as? [String: Any])?["timestampValue"]
                as? String

            completion(.success(
                KeyInfo(tier: tier, expiry: exp)
            ))
        }.resume()
    }

    private static func patchDevice(
        docName: String,
        device: String
    ) {
        let urlStr =
            "https://firestore.googleapis.com/v1/"
            + docName
            + "?updateMask.fieldPaths=devices"
        guard let url = URL(string: urlStr)
        else { return }

        let body: [String: Any] = [
            "fields": [
                "devices": [
                    "arrayValue": [
                        "values": [[
                            "stringValue": device
                        ]]
                    ]
                ]
            ]
        ]

        var req = URLRequest(url: url)
        req.httpMethod = "PATCH"
        req.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        req.httpBody = try? JSONSerialization
            .data(withJSONObject: body)

        URLSession.shared.dataTask(
            with: req
        ).resume()
    }
}
