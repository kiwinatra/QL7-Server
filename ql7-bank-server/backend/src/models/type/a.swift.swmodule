let transferData = try req.content.decode(Transaction.Create.self)
guard transferData.amount > 0 else { throw Abort(.badRequest, reason: "Amount must be positive")
} let senderAccount = try await req.user.accounts .first(or: .notFound, where: \.$id == senderAccountID) let receiverAccount = try await Account.query(on: req.db) .filter(\.$accountNumber == transferData.receiverAccountNumber) .first(or: .notFound) let transaction = try await Transaction.createTransfer( amount: transferData.amount, currency: transferData.currency, senderAccount: senderAccount, receiverAccount: receiverAccount, description: transferData.description, on: req.db
) return transaction.toPublic( senderNumber: senderAccount.accountNumber, receiverNumber: receiverAccount.accountNumber
)