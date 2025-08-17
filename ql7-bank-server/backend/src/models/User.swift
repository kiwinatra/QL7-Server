import Vapor
import Fluent
import JWT
final class User: Model, Content, Authenticatable { static let schema = "users" @ID(key: .id) var id: UUID? @Field(key: "email") var email: String @Field(key: "password_hash") var passwordHash: String @Field(key: "first_name") var firstName: String @Field(key: "last_name") var lastName: String @Field(key: "phone") var phone: String? @Field(key: "is_email_verified") var isEmailVerified: Bool @Field(key: "role") var role: UserRole @Field(key: "status") var status: UserStatus @Timestamp(key: "created_at", on: .create) var createdAt: Date? @Timestamp(key: "updated_at", on: .update) var updatedAt: Date? @Timestamp(key: "last_login_at", on: .none) var lastLoginAt: Date? @Children(for: \.$user) var accounts: [Account] init() {} init( id: UUID? = nil, email: String, passwordHash: String, firstName: String, lastName: String, phone: String? = nil, isEmailVerified: Bool = false, role: UserRole = .user, status: UserStatus = .active ) { self.id = id self.email = email self.passwordHash = passwordHash self.firstName = firstName self.lastName = lastName self.phone = phone self.isEmailVerified = isEmailVerified self.role = role self.status = status }
} enum UserRole: String, Codable { case user case admin case support case auditor } enum UserStatus: String, Codable { case active case suspended case pending } extension User { struct Migration: AsyncMigration { func prepare(on database: Database) async throws { try await database.schema(User.schema) .id() .field("email", .string, .required) .field("password_hash", .string, .required) .field("first_name", .string, .required) .field("last_name", .string, .required) .field("phone", .string) .field("is_email_verified", .bool, .required) .field("role", .string, .required) .field("status", .string, .required) .field("created_at", .datetime) .field("updated_at", .datetime) .field("last_login_at", .datetime) .unique(on: "email") .create() } func revert(on database: Database) async throws { try await database.schema(User.schema).delete() } }
} extension User { struct Create: Content { var email: String var password: String var firstName: String var lastName: String var phone: String? } struct Public: Content { var id: UUID? var email: String var firstName: String var lastName: String var phone: String? var role: UserRole var status: UserStatus var createdAt: Date? } func toPublic() -> Public { Public( id: id, email: email, firstName: firstName, lastName: lastName, phone: phone, role: role, status: status, createdAt: createdAt ) }
} extension User: ModelAuthenticatable { static let usernameKey = \User.$email static let passwordHashKey = \User.$passwordHash func verify(password: String) throws -> Bool { try Bcrypt.verify(password, created: self.passwordHash) }
} extension User { struct JWTToken: Content, JWTPayload { var id: UUID var email: String var role: UserRole var exp: ExpirationClaim func verify(using signer: JWTSigner) throws { try exp.verifyNotExpired() } } func generateToken() throws -> String { let expiration = ExpirationClaim(value: Date().addingTimeInterval(3600 * 24)) let token = JWTToken( id: try requireID(), email: email, role: role, exp: expiration ) return try JWTSigner.hs256(key: Environment.get("JWT_SECRET") ?? "").sign(token) }
} extension User { static func findByEmail(_ email: String, on db: Database) async throws -> User? { try await User.query(on: db) .filter(\.$email == email) .first() } static func register(userData: Create, on db: Database) async throws -> User { let hashedPassword = try Bcrypt.hash(userData.password) let user = User( email: userData.email, passwordHash: hashedPassword, firstName: userData.firstName, lastName: userData.lastName, phone: userData.phone ) try await user.save(on: db) return user } func updateLastLogin(on db: Database) async throws { lastLoginAt = Date() try await save(on: db) }
}

// app.post("register") { req -> User.Public in
//     let userData = try req.content.decode(User.Create.self)
//     let user = try await User.register(userData: userData, on: req.db)
//     return user.toPublic()
// }

// app.post("login") { req -> [String: String] in
//     let user = try req.auth.require(User.self)
//     try await user.updateLastLogin(on: req.db)
//     let token = try user.generateToken()
//     return ["token": token]
// }

// app.get("me") { req -> User.Public in
//     let user = try req.auth.require(User.self)
//     return user.toPublic()
// }

// app.patch("me") { req -> User.Public in
//     let user = try req.auth.require(User.self)
//     let updateData = try req.content.decode(User.Update.self)
    
//     if let phone = updateData.phone {
//         user.phone = phone
//     }
    
//     try await user.save(on: req.db)
//     return user.toPublic()
// }