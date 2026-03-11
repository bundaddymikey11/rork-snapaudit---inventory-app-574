import Foundation

nonisolated struct CSVParseResult: Sendable {
    let headers: [String]
    let rows: [[String: String]]
    let rawText: String
    let filename: String
}

nonisolated struct CSVColumnMapping: Sendable {
    let keyColumn: String
    let qtyColumn: String
    let locationColumn: String?
    let zoneColumn: String?
}

nonisolated struct CSVRowMatch: Sendable {
    let skuOrNameKey: String
    let qty: Int
    let matchedSkuId: UUID?
    let locationName: String
    let zone: String
    var isMatched: Bool { matchedSkuId != nil }
}

nonisolated struct ParsedSKUInfo: Sendable {
    let id: UUID
    let sku: String
    let name: String
    /// Pre-normalized name for fast case-insensitive matching during import.
    let normalizedName: String

    init(id: UUID, sku: String, name: String) {
        self.id = id
        self.sku = sku
        self.name = name
        self.normalizedName = name.normalized
    }
}

nonisolated final class CSVImportService: Sendable {
    static let shared = CSVImportService()
    private init() {}

    func parse(text: String, filename: String) -> CSVParseResult {
        var lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard !lines.isEmpty else {
            return CSVParseResult(headers: [], rows: [], rawText: text, filename: filename)
        }

        let headers = parseCSVLine(lines.removeFirst())
        var rows: [[String: String]] = []

        for line in lines {
            let values = parseCSVLine(line)
            var dict: [String: String] = [:]
            for (i, header) in headers.enumerated() {
                dict[header] = i < values.count ? values[i].trimmingCharacters(in: .whitespaces) : ""
            }
            if !dict.values.allSatisfy({ $0.isEmpty }) {
                rows.append(dict)
            }
        }

        return CSVParseResult(headers: headers, rows: rows, rawText: text, filename: filename)
    }

    func applyMapping(
        rows: [[String: String]],
        mapping: CSVColumnMapping,
        skus: [ParsedSKUInfo]
    ) -> [CSVRowMatch] {
        rows.compactMap { row -> CSVRowMatch? in
            let key = row[mapping.keyColumn] ?? ""
            guard !key.isEmpty else { return nil }
            let qtyStr = row[mapping.qtyColumn] ?? "0"
            let qty = Int(qtyStr.replacingOccurrences(of: ",", with: "")) ?? 0
            let location = mapping.locationColumn.flatMap { row[$0] } ?? ""
            let zone = mapping.zoneColumn.flatMap { row[$0] } ?? ""
            let matchedId = findSKU(for: key, in: skus)?.id
            return CSVRowMatch(skuOrNameKey: key, qty: qty, matchedSkuId: matchedId, locationName: location, zone: zone)
        }
    }

    func findSKU(for key: String, in skus: [ParsedSKUInfo]) -> ParsedSKUInfo? {
        let normalizedKey = key.normalized
        // 1. Exact SKU match (case-insensitive)
        if let exact = skus.first(where: { $0.sku.normalized == normalizedKey }) { return exact }
        // 2. Exact product name match (normalized)
        if let exact = skus.first(where: { $0.normalizedName == normalizedKey }) { return exact }
        // 3. Partial SKU match
        if let partial = skus.first(where: {
            let s = $0.sku.normalized
            return s.contains(normalizedKey) || normalizedKey.contains(s)
        }) { return partial }
        // 4. Partial product name match
        if let partial = skus.first(where: {
            let n = $0.normalizedName
            return n.contains(normalizedKey) || normalizedKey.contains(n)
        }) { return partial }
        return nil
    }

    func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false
        let chars = Array(line)
        var i = 0

        while i < chars.count {
            let c = chars[i]
            if c == "\"" {
                if inQuotes && i + 1 < chars.count && chars[i + 1] == "\"" {
                    current.append("\"")
                    i += 2
                    continue
                }
                inQuotes.toggle()
            } else if c == "," && !inQuotes {
                result.append(current.trimmingCharacters(in: .whitespaces))
                current = ""
            } else {
                current.append(c)
            }
            i += 1
        }
        result.append(current.trimmingCharacters(in: .whitespaces))
        return result
    }
}
