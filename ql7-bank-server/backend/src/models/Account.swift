import Vapor
import Fluent
final class Account: Model, Content {
    static let schema = "accounts"
    @ID(key: .id)
    var id: UUID?
    @Field(key: "account_number")
    var accountNumber: String
    @Field(key: "balance")
    var balance: Double
    @Field(key: "currency")
    var currency: String
    @Field(key: "type")
    var type: AccountType
    @Field(key: "status")
    var status: AccountStatus
    @Parent(key: "user_id")
    var user: User
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    init() {}
    init(
        id: UUID? = nil,
        accountNumber: String,
        balance: Double,
        currency: String,
        type: AccountType,
        status: AccountStatus,
        userID: User.IDValue
    ) {
        self.id = id
        self.accountNumber = accountNumber
        self.balance = balance
        self.currency = currency
        self.type = type
        self.status = status
        self.$user.id = userID
    }
}

enum AccountType: String, Codable {
    case checking 
    case savings 
    case credit 
    case deposit 
    case investment 
}

enum AccountStatus: String, Codable {
    case active
    case frozen
    case closed
    case restricted
}

extension Account {
    struct Migration: AsyncMigration {
        func prepare(on database: Database) async throws {
            try await database.schema(Account.schema)
                .id()
                .field("account_number", .string, .required)
                .field("balance", .double, .required)
                .field("currency", .string, .required)
                .field("type", .string, .required)
                .field("status", .string, .required)
                .field("user_id", .uuid, .required, .references("users", "id"))
                .field("created_at", .datetime)
                .field("updated_at", .datetime)
                .unique(on: "account_number")
                .create()
        }
        func revert(on database: Database) async throws {
            try await database.schema(Account.schema).delete()
        }
    }
}

extension Account {
    struct Create: Content {
        var type: AccountType
        var currency: String
    }
    struct Public: Content {
        var id: UUID?
        var accountNumber: String
        var balance: Double
        var currency: String
        var type: AccountType
        var status: AccountStatus
        var createdAt: Date?
    }
    func toPublic() -> Public {
        Public(
            id: id,
            accountNumber: accountNumber,
            balance: balance,
            currency: currency,
            type: type,
            status: status,
            createdAt: createdAt
        )
    }
}

extension Account {
    static func findByAccountNumber(_ number: String, on db: Database) async throws -> Account? {
        try await Account.query(on: db)
            .filter(\.$accountNumber == number)
            .first()
    }
    static func getUserAccounts(userID: UUID, on db: Database) async throws -> [Account] {
        try await Account.query(on: db)
            .filter(\.$user.$id == userID)
            .all()
    }
}