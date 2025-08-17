let accountID = try req.parameters.require("accountID", as: UUID.self)
let transactions = try await Transaction.getAccountTransactions( accountID: accountID, on: req.db
) return try transactions.map { transaction in let senderNumber = try await transaction.$senderAccount.get(on: req.db).accountNumber let receiverNumber = try await transaction.$receiverAccount.get(on: req.db).accountNumber return transaction.toPublic( senderNumber: senderNumber, receiverNumber: receiverNumber )
}