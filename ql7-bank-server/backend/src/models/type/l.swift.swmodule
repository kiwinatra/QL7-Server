let transactionID = try req.parameters.require("id", as: UUID.self)
let transaction = try await Transaction.find(transactionID, on: req.db) ?? throw Abort(.notFound) guard transaction.status == .pending else { throw Abort(.badRequest, reason: "Only pending transactions can be cancelled")
} transaction.status = .cancelled
try await transaction.save(on: req.db)